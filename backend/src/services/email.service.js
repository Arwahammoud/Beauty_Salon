const BREVO_ENDPOINT = "https://api.brevo.com/v3/smtp/email";

// Delivery goes over HTTPS rather than SMTP because our host blocks outbound
// traffic to ports 25/465/587, which made every SMTP send hang until timeout.
const sendMail = async ({ to, subject, text, html }) => {
  if (!process.env.BREVO_API_KEY) {
    throw new Error("BREVO_API_KEY is not configured");
  }

  // Don't let a slow provider hold a request open indefinitely.
  const abort = AbortSignal.timeout(15_000);

  let response;
  try {
    response = await fetch(BREVO_ENDPOINT, {
      method: "POST",
      headers: {
        "api-key": process.env.BREVO_API_KEY,
        "content-type": "application/json",
        accept: "application/json",
      },
      body: JSON.stringify({
        sender: {
          name: process.env.EMAIL_FROM_NAME || "Beauty Salon",
          email: process.env.EMAIL_FROM,
        },
        to: [{ email: to }],
        subject,
        textContent: text,
        htmlContent: html,
      }),
      signal: abort,
    });
  } catch (error) {
    // Network failure or the 15s timeout above — fetch rejects rather than
    // returning a response, so there is no status code to report.
    throw new Error(`Email delivery failed: ${error.message}`);
  }

  if (!response.ok) {
    // Brevo describes failures as {code, message}; fall back to raw text so a
    // proxy error page doesn't get swallowed by a JSON parse failure.
    const detail = await response.text().catch(() => "");
    throw new Error(
      `Email delivery failed (${response.status}): ${detail || response.statusText}`,
    );
  }

  return response.json();
};

const sendPasswordResetEmail = async ({
  to,
  name,
  code,
}) => {
  return sendMail({
    to,
    subject: "Your Beauty Salon Password Reset Code",

    text: `
Hello ${name || "User"},

We received a request to reset the password for your Beauty Salon account.

Use the following code in the app to reset your password:

${code}

This code will expire in 15 minutes.

If you didn't request a password reset, you can safely ignore this email.

The Beauty Salon Team
   ` .trim(),

    html: `
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Password Reset</title>
</head>

<body style="margin:0;padding:0;background:#fdf2f8;font-family:Arial,Helvetica,sans-serif;">

<table width="100%" cellpadding="0" cellspacing="0" style="background:#fdf2f8;padding:40px 20px;">
<tr>
<td align="center">

<table width="600" cellpadding="0" cellspacing="0" style="
background:#ffffff;
border-radius:18px;
overflow:hidden;
box-shadow:0 10px 35px rgba(219,39,119,.08);
">

<tr>
<td align="center" style="background:#db2777;padding:40px;">

<div style="
width:80px;
height:80px;
background:#ffffff;
border-radius:50%;
display:flex;
align-items:center;
justify-content:center;
margin:auto;
font-size:38px;
">
:sparkles:
</div>

<h1 style="
margin:20px 0 0;
color:#ffffff;
font-size:32px;
font-weight:bold;
">
Beauty Salon
</h1>

<p style="
margin-top:10px;
font-size:16px;
color:#fce7f3;
">
Password Reset Request
</p>

</td>
</tr>

<tr>
<td style="padding:45px;">

<h2 style="
margin-top:0;
color:#1f2937;
font-size:26px;
">
Hello ${name || "User"},
</h2>

<p style="
font-size:16px;
line-height:1.8;
color:#4b5563;
">
We received a request to reset the password for your
<strong>Beauty Salon</strong> account.
</p>

<p style="
font-size:16px;
line-height:1.8;
color:#4b5563;
">
Enter the code below in the app to choose a new password:
</p>

<div style="
text-align:center;
margin:40px 0;
">

<div style="
display:inline-block;
background:#fdf2f8;
border:2px dashed #DB2777;
border-radius:14px;
padding:20px 35px;
font-size:36px;
font-weight:bold;
letter-spacing:12px;
color:#db2777;
">
${code}
</div>

</div>

<p style="
font-size:16px;
line-height:1.8;
color:#4b5563;
text-align:center;
">
For your security, this code will expire in
<strong>15 minutes</strong>.
</p>

<hr style="
margin:40px 0;
border:none;
border-top:1px solid #E5E7EB;
">

<p style="
font-size:15px;
line-height:1.8;
color:#6b7280;
">
If you didn't request this password reset, you can safely ignore this email.
Your password will remain unchanged.
</p>

</td>
</tr>

<tr>
<td style="
background:#f9fafb;
padding:30px;
text-align:center;
">

<p style="
margin:0;
font-size:15px;
font-weight:bold;
color:#374151;
">
Beauty Salon
</p>

<p style="
margin:10px 0;
font-size:14px;
color:#9ca3af;
">
Enhancing your natural beauty :sparkling_heart:
</p>

<p style="
margin-top:20px;
font-size:12px;
color:#9ca3af;
line-height:1.7;
">
This email was sent automatically.
Please do not reply to this message.
</p>
<p style="
margin-top:15px;
font-size:12px;
color:#9ca3af;
">
© ${new Date().getFullYear()} Beauty Salon. All rights reserved.
</p>

</td>
</tr>

</table>

</td>
</tr>
</table>

</body>
</html>
    `,
  });
};

const sendSignupVerificationEmail = async ({
  to,
  name,
  verificationCode,
}) => {
  return sendMail({
    to,
    subject: "Verify Your Beauty Salon Account",

    text: `
Hello ${name || "User"},

Thank you for registering with Beauty Salon.

Use the following verification code to complete your registration:

${verificationCode}

This code will expire in 10 minutes.

Do not share this code with anyone.

If you didn't create a Beauty Salon account, you can safely ignore this email.

The Beauty Salon Team
    `.trim(),

    html: `
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Email Verification</title>
</head>

<body style="margin:0;padding:0;background:#fdf2f8;font-family:Arial,Helvetica,sans-serif;">

<table width="100%" cellpadding="0" cellspacing="0" style="background:#fdf2f8;padding:40px 20px;">
<tr>
<td align="center">

<table width="600" cellpadding="0" cellspacing="0" style="
background:#ffffff;
border-radius:18px;
overflow:hidden;
box-shadow:0 10px 35px rgba(219,39,119,.08);
">

<!-- Header -->
<tr>
<td align="center" style="background:#db2777;padding:40px;">

<div style="
width:80px;
height:80px;
background:#ffffff;
border-radius:50%;
display:flex;
align-items:center;
justify-content:center;
margin:auto;
font-size:38px;
">
:sparkles:
</div>

<h1 style="
margin:20px 0 0;
color:#ffffff;
font-size:32px;
font-weight:bold;
">
Beauty Salon
</h1>

<p style="
margin-top:10px;
font-size:16px;
color:#fce7f3;
">
Email Verification
</p>

</td>
</tr>

<!-- Body -->
<tr>
<td style="padding:45px;">

<h2 style="
margin-top:0;
color:#1f2937;
font-size:26px;
">
Hello ${name || "User"},
</h2>

<p style="
font-size:16px;
line-height:1.8;
color:#4b5563;
">
Thank you for creating an account with
<strong>Beauty Salon</strong>.
</p>

<p style="
font-size:16px;
line-height:1.8;
color:#4b5563;
">
Enter the verification code below to complete your registration:
</p>

<div style="
text-align:center;
margin:40px 0;
">

<div style="
display:inline-block;
background:#fdf2f8;
border:2px dashed #DB2777;
border-radius:14px;
padding:20px 35px;
font-size:36px;
font-weight:bold;
letter-spacing:12px;
color:#db2777;
">
${verificationCode}
</div>

</div>

<p style="
font-size:16px;
line-height:1.8;
color:#4b5563;
text-align:center;
">
This verification code will expire in
<strong>10 minutes</strong>.
</p>

<div style="
background:#fff1f2;
border:1px solid #FECDD3;
border-radius:10px;
padding:16px;
margin-top:30px;
">

<p style="
margin:0;
font-size:14px;
line-height:1.7;
color:#be123c;
">
<strong>Security notice:</strong>
Never share this verification code with anyone.
Beauty Salon will never ask you for this code by phone or message.
</p>

</div>

<hr style="
margin:40px 0;
border:none;
border-top:1px solid #E5E7EB;
">

<p style="
font-size:15px;
line-height:1.8;
color:#6b7280;
">
If you didn't create a Beauty Salon account, you can safely ignore this email.
No account will be created without entering the verification code.
</p>

</td>
</tr>

<!-- Footer -->
<tr>
<td style="
background:#f9fafb;
padding:30px;
text-align:center;
">

<p style="
margin:0;
font-size:15px;
font-weight:bold;
color:#374151;
">
Beauty Salon
</p>

<p style="
margin:10px 0;
font-size:14px;
color:#9ca3af;
">
Enhancing your natural beauty :sparkling_heart:
</p>

<p style="
margin-top:20px;
font-size:12px;
color:#9ca3af;
line-height:1.7;
">
This email was sent automatically.
Please do not reply to this message.
</p>

<p style="
margin-top:15px;
font-size:12px;
color:#9ca3af;
">
© ${new Date().getFullYear()} Beauty Salon. All rights reserved.
</p>

</td>
</tr>

</table>

</td>
</tr>
</table>

</body>
</html>
    `,
  });
};

module.exports = {
  sendPasswordResetEmail,
  sendSignupVerificationEmail,
};