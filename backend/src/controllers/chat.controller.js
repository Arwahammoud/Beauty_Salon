const Setting = require("../models/Setting");

const GEMINI_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent";

// DB value wins if set (so it can be changed from the admin app without
// touching .env), otherwise fall back to the environment variable.
const getGeminiApiKey = async () => {
    const setting = await Setting.findOne({ key: "GEMINI_API_KEY" });
    return setting ? setting.value : process.env.GEMINI_API_KEY;
};

const SYSTEM_PROMPT = `
You are a warm, helpful beauty assistant for Belle Beauty Salon.

Our services:
- Hair, Nails, Skincare, Laser, Spa, Makeup, Medical, Products

Working hours: Saturday-Thursday 9 AM - 9 PM, Friday 2 PM - 9 PM

Rules:
- Keep replies short and friendly (2-4 sentences max unless asked for more)
- Always reply in the same language the user writes in (Arabic or English)
- For booking, guide users to tap the "Booking" tab in the app
- If asked about prices, give approximate ranges in SP (Syrian Pound)
- Never make up appointments or confirm bookings yourself
`.trim();

class ChatController {
    // ==================== POST /chat/message ====================
    sendMessage = async (req, res) => {
        const apiKey = await getGeminiApiKey();
        if (!apiKey) {
            return res.status(500).json({
                error: { code: "CHAT_NOT_CONFIGURED", message: "GEMINI_API_KEY is not set on the server." },
            });
        }

        const { message, history } = req.body;
        if (!message || !message.trim()) {
            return res.status(400).json({
                error: { code: "MISSING_MESSAGE", message: "message is required" },
            });
        }

        const contents = [
            ...(Array.isArray(history) ? history : []).map((m) => ({
                role: m.role === "user" ? "user" : "model",
                parts: [{ text: m.content }],
            })),
            { role: "user", parts: [{ text: message }] },
        ];

        const geminiResponse = await fetch(`${GEMINI_ENDPOINT}?key=${apiKey}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
                contents,
                generationConfig: {
                    temperature: 0.75,
                    // Gemini 3.6's internal "thinking" tokens count against this budget
                    // too, so it needs headroom above what a short reply alone would need.
                    maxOutputTokens: 1024,
                },
            }),
        });

        if (!geminiResponse.ok) {
            return res.status(502).json({
                error: { code: "CHAT_UPSTREAM_ERROR", message: `Gemini responded with ${geminiResponse.status}` },
            });
        }

        const data = await geminiResponse.json();
        const reply = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim();

        if (!reply) {
            return res.status(502).json({
                error: { code: "CHAT_UPSTREAM_ERROR", message: "Gemini returned an empty response" },
            });
        }

        return res.status(200).json({ reply });
    };
}

module.exports = new ChatController();
