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
    price: "Prices vary by service and specialist. Open any service's details page to see its exact price, or check the offers section for current discounts!",
    booking: "Booking is easy! Pick a service, tap 'Book Now', then choose your favorite specialist and a time that works for you.",
    greeting: "Hello! 😊 I'm here to help with services, prices, offers, or booking an appointment.",
    thanks: "You're very welcome! Let me know if there's anything else I can help you with. 💕",
  },
  ar: {
    welcome: "أهلاً بكِ في صالون بيل! كيف يمكنني مساعدتك اليوم بخصوص خدماتنا أو مواعيدك؟",
    services: (names) => ` نقدّم خدمات رائعة مثل: ${names}. يمكنك تصفح قسم الخدمات وحجز موعدك مباشرة!`,
    offersActive: (count) => `يوجد حالياً ${count} عرضاً نشطاً في التطبيق! تصفّحي قسم العروض.`,
    offersNone: "لا توجد عروض نشطة حالياً، تابعينا قريباً!",
    hours: "صالون بيل مفتوح يومياً من الساعة 10:00 صباحاً حتى 8:00 مساءً.",
    price: "تختلف الأسعار حسب الخدمة والمتخصصة. افتحي صفحة تفاصيل أي خدمة لمعرفة سعرها بالتحديد، أو تصفّحي قسم العروض لأحدث الخصومات!",
    booking: "الحجز سهل جداً! اختاري الخدمة، اضغطي على 'حجز الآن'، ثم اختاري المتخصصة والوقت المناسب لك.",
    greeting: "أهلاً وسهلاً! 😊 أنا هنا لمساعدتك بخصوص الخدمات أو الأسعار أو العروض أو حجز موعد.",
    thanks: "على الرحب والسعة! أخبريني إن كان هناك أي شيء آخر يمكنني مساعدتك به. 💕",
  },
};

const KEYWORDS = {
  en: {
    service: ["service", "hair", "cut", "style", "salon", "treatment", "skin", "makeup", "nail", "spa", "facial", "recommend"],
    offer: ["offer", "discount", "deal", "sale", "promo"],
    hours: ["time", "hour", "work", "open", "close", "schedule"],
    price: ["price", "cost", "how much", "fee", "expensive", "cheap"],
    booking: ["book", "appointment", "reserve", "schedule an", "cancel"],
    greeting: ["hi", "hello", "hey", "good morning", "good evening"],
    thanks: ["thanks", "thank you", "thx"],
  },
  ar: {
    service: ["خدم", "شعر", "قص", "تسريح", "صالون", "بشرة", "مكياج", "أظافر", "سبا", "عناية", "اقترح", "علاج", "تجميل"],
    offer: ["عرض", "عروض", "خصم", "خصومات", "تخفيض"],
    hours: ["وقت", "ساعات", "ساعة", "دوام", "عمل", "مفتوح", "مغلق", "متى"],
    price: ["سعر", "أسعار", "كلفة", "تكلفة", "بكم", "كم سعر", "غالي", "رخيص"],
    booking: ["حجز", "موعد", "احجز", "احجزي", "إلغاء"],
    greeting: ["مرحبا", "مرحباً", "أهلا", "أهلاً", "هاي", "صباح الخير", "مساء الخير", "السلام عليكم"],
    thanks: ["شكرا", "شكراً", "متشكرة", "يعطيك العافية"],
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

    if (includesAny(lowerMsg, keywords.thanks)) {
      botReply = replies.thanks;
    } else if (includesAny(lowerMsg, keywords.greeting)) {
      botReply = replies.greeting;
    } else if (includesAny(lowerMsg, keywords.booking)) {
      botReply = replies.booking;
    } else if (includesAny(lowerMsg, keywords.price)) {
      botReply = replies.price;
    } else if (includesAny(lowerMsg, keywords.service)) {
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
