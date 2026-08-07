const Chat = require("../models/Chat");
const Service = require("../models/Service");
const Offer = require("../models/Offers");

class ChatController {
  //  Send message to AI bot and get reply
  sendMessage = async (req, res) => {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ status: "fail", message: "Please provide a message" });
    }

    const services = await Service.find({ isActive: true }).limit(5);
    const offers = await Offer.find({ isActive: true });

    let botReply = "Welcome to Belle Salon! How can I assist you today with our services or appointments?";

    const lowerMsg = message.toLowerCase();

    if (lowerMsg.includes("service") || lowerMsg.includes("hair") || lowerMsg.includes("cut")) {
      const serviceNames = services.map(s => s.name).join(", ");
      botReply =` We offer amazing services such as: ${serviceNames}. You can check the services section and book directly!`;
    } else if (lowerMsg.includes("offer") || lowerMsg.includes("discount")) {
      botReply = offers.length > 0 
        ? `There are currently ${offers.length} active offers available in the app! Check the offers section.` 
        : "There are no active offers at the moment, stay tuned!";
    } else if (lowerMsg.includes("time") || lowerMsg.includes("hour") || lowerMsg.includes("work")) {
      botReply = "Belle Salon is open every day from 10:00 AM to 8:00 PM.";
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