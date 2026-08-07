const Chat = require("../models/Chat");
const Service = require("../models/Service");
const Offer = require("../models/Offers");

// A message containing Arabic script always wins (the user is clearly
// writing Arabic); otherwise fall back to the app's current language
// (Accept-Language, set on req.lang by middlewares/lang.js).
const resolveLang = (message, req) => (/[؀-ۿ]/.test(message) ? "ar" : req.lang || "en");

const REPLIES = {
  en: {
    welcome: "Welcome to Belle Salon! How can I assist you today with our services or appointments?",
    services: (names) => ` We offer amazing services such as: ${names}. You can check the services section and book directly!`,
    offersActive: (count) => `There are currently ${count} active offers available in the app! Check the offers section.`,
    offersNone: "There are no active offers at the moment, stay tuned!",
    hours: "Belle Salon is open every day from 10:00 AM to 8:00 PM.",
  },
  ar: {
    welcome: "أهلاً بكِ في صالون بيل! كيف يمكنني مساعدتك اليوم بخصوص خدماتنا أو مواعيدك؟",
    services: (names) => ` نقدّم خدمات رائعة مثل: ${names}. يمكنك تصفح قسم الخدمات وحجز موعدك مباشرة!`,
    offersActive: (count) => `يوجد حالياً ${count} عرضاً نشطاً في التطبيق! تصفّحي قسم العروض.`,
    offersNone: "لا توجد عروض نشطة حالياً، تابعينا قريباً!",
    hours: "صالون بيل مفتوح يومياً من الساعة 10:00 صباحاً حتى 8:00 مساءً.",
  },
};

const KEYWORDS = {
  en: {
    service: ["service", "hair", "cut"],
    offer: ["offer", "discount"],
    hours: ["time", "hour", "work"],
  },
  ar: {
    service: ["خدم", "شعر", "قص"],
    offer: ["عرض", "عروض", "خصم"],
    hours: ["وقت", "ساعات", "ساعة", "دوام", "عمل"],
  },
};

const includesAny = (text, words) => words.some((w) => text.includes(w));

class ChatController {
  //  Send message to AI bot and get reply
  sendMessage = async (req, res) => {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ status: "fail", message: "Please provide a message" });
    }

    const services = await Service.find({ isActive: true }).limit(5);
    const offers = await Offer.find({ isActive: true });

    const lang = resolveLang(message, req);
    const replies = REPLIES[lang];
    const keywords = KEYWORDS[lang];
    const lowerMsg = message.toLowerCase();

    let botReply = replies.welcome;

    if (includesAny(lowerMsg, keywords.service)) {
      const serviceNames = services.map((s) => (lang === "ar" && s.nameAr ? s.nameAr : s.name)).join(", ");
      botReply = replies.services(serviceNames);
    } else if (includesAny(lowerMsg, keywords.offer)) {
      botReply = offers.length > 0 ? replies.offersActive(offers.length) : replies.offersNone;
    } else if (includesAny(lowerMsg, keywords.hours)) {
      botReply = replies.hours;
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

  //s Get user chat history
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
