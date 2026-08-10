const Chat = require("../models/Chat");
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
  //  Send message to AI bot and get reply
  sendMessage = async (req, res) => {
    const { message, history } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({ status: "fail", message: "Please provide a message" });
    }

    const apiKey = await getGeminiApiKey();
    if (!apiKey) {
      return res.status(500).json({
        status: "fail",
        message: "GEMINI_API_KEY is not set on the server.",
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
          // Gemini's internal "thinking" tokens count against this budget too,
          // so it needs headroom above what a short reply alone would need.
          maxOutputTokens: 1024,
        },
      }),
    });

    if (!geminiResponse.ok) {
      return res.status(502).json({
        status: "fail",
        message: `Gemini responded with ${geminiResponse.status}`,
      });
    }

    const data = await geminiResponse.json();
    const botReply = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim();

    if (!botReply) {
      return res.status(502).json({
        status: "fail",
        message: "Gemini returned an empty response",
      });
    }

    let chat = await Chat.findOne({ userId: req.user._id });

    if (!chat) {
      chat = await Chat.create({
        userId: req.user._id,
        messages: [
          { sender: "user", text: message },
          { sender: "bot", text: botReply }
        ]
      });
    } else {
      chat.messages.push({ sender: "user", text: message });
      chat.messages.push({ sender: "bot", text: botReply });
      await chat.save();
    }

    res.status(200).json({
      status: "success",
      reply: botReply,
      chatHistory: chat.messages,
    });
  };

  // Get user chat history
  // @route   GET /api/v1/chat
  getChatHistory = async (req, res) => {
    const chat = await Chat.findOne({ userId: req.user._id });

    res.status(200).json({
      status: "success",
      items: chat ? chat.messages : [],
    });
  };
}

module.exports = new ChatController();
