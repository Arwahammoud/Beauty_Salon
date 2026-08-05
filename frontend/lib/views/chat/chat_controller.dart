// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  HOW TO GET YOUR FREE GROQ API KEY (works worldwide + Syria):
//
//  1. Open your browser and go to:
//     https://console.groq.com
//  2. Sign up with Google or GitHub — NO credit card needed
//  3. Click "API Keys" → "Create API Key"
//  4. Copy the key (starts with gsk_...)
//  5. Paste it below (replace the placeholder)
//  6. Run the app — the chat will work!
//
//  ✅ Completely FREE — no credit card, no billing
//  ✅ Works in Syria and all countries
//  ✅ 30 requests/minute on the free plan
//  ✅ Uses Meta Llama 3 — very smart AI model
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'dart:convert';
import 'package:belle_beauty_salon/views/chat/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  // ── Paste your Groq API key here (get it free at console.groq.com) ─────────
  static const _apiKey = 'REDACTED_ROTATE_THIS_KEY';
  // ──────────────────────────────────────────────────────────────────────────

  // Groq endpoint — OpenAI-compatible format
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  // Model options (all free on Groq):
  //   llama-3.1-8b-instant  → fastest, great for simple chat
  //   llama-3.3-70b-versatile → smarter, slightly slower
  //   mixtral-8x7b-32768    → good multilingual (Arabic + English)
  static const _model = 'llama-3.3-70b-versatile';

  // What the AI knows about the salon — edit this to match your real salon info
  static const _systemPrompt = '''
You are a warm, helpful beauty assistant for Belle Beauty Salon.

Our services:
• Hair — Haircut & Style, Deep Conditioning, Coloring, Keratin Treatment
• Nails — Nail Art, Classic Manicure, Gel Nails, Pedicure
• Skincare — Facial Treatment, Chemical Peel, Hydra Facial
• Laser — Laser Hair Removal, Skin Rejuvenation
• Spa — Swedish Massage, Hot Stone Massage, Body Wrap
• Makeup — Bridal Makeup, Party Makeup, Natural Glow Look
• Medical — Skin Consultation, Botox, Fillers
• Products — Skincare, Haircare, Nail Products

Working hours: Saturday–Thursday 9 AM – 9 PM, Friday 2 PM – 9 PM
Location: Available in-app booking

Rules:
- Keep replies short and friendly (2–4 sentences max unless asked for more)
- Always reply in the same language the user writes in (Arabic or English)
- For booking, guide users to tap the "Booking" tab in the app
- If asked about prices, give approximate ranges (SP 5,000–85,000 depending on service)
- Never make up appointments or confirm bookings yourself
''';

  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  bool get hasApiKey => _apiKey != 'YOUR_GROQ_API_KEY_HERE' && _apiKey.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    // Initial greeting from the bot
    messages.add(ChatMessage(
      text: hasApiKey
          ? 'Hi! 👋 I\'m your Belle Beauty Assistant.\n\nAsk me anything about our services, prices, or beauty tips. I\'m here to help! ✨'
          : '⚠️ API key not set yet.\n\nTo activate the chat:\n1. Open lib/views/chat/chat_controller.dart\n2. Replace YOUR_GROQ_API_KEY_HERE with your key\n3. Get a FREE key at: console.groq.com (no credit card)',
      isUser: false,
    ));
  }

  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    if (!hasApiKey) {
      Get.snackbar(
        'API Key Missing',
        'Add your Groq API key in chat_controller.dart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFF3CD),
        colorText: const Color(0xFF856404),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    inputController.clear();
    messages.add(ChatMessage(text: text, isUser: true));
    isTyping.value = true;
    _scrollToBottom();

    try {
      // Groq uses Authorization: Bearer header (OpenAI-compatible format)
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': _buildHistory(),
              'max_tokens': 400,
              'temperature': 0.75,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        // Groq response: choices[0].message.content
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reply =
            data['choices'][0]['message']['content'] as String;
        messages.add(ChatMessage(text: reply.trim(), isUser: false));
      } else if (response.statusCode == 429) {
        messages.add(ChatMessage(
          text: '⏳ Too many requests. Wait 1 minute then try again.\n(Free plan: 30 requests/minute)',
          isUser: false,
          isError: true,
        ));
      } else if (response.statusCode == 401) {
        messages.add(ChatMessage(
          text: 'Invalid API key (401). Get a free key at console.groq.com and paste it in chat_controller.dart.',
          isUser: false,
          isError: true,
        ));
      } else if (response.statusCode == 400) {
        messages.add(ChatMessage(
          text: 'Bad request (400). Please try again.',
          isUser: false,
          isError: true,
        ));
      } else {
        messages.add(ChatMessage(
          text: 'Error ${response.statusCode}. Please try again.',
          isUser: false,
          isError: true,
        ));
      }
    } on Exception {
      messages.add(ChatMessage(
        text: 'Connection failed. Please check your internet and try again.',
        isUser: false,
        isError: true,
      ));
    }

    isTyping.value = false;
    _scrollToBottom();
  }

  void clearChat() {
    messages.clear();
    messages.add(ChatMessage(
      text: 'Chat cleared! 🌸 How can I help you?',
      isUser: false,
    ));
  }

  // Build the messages array for Groq (OpenAI format):
  // [ {role: system, content: ...}, {role: user, ...}, {role: assistant, ...} ]
  List<Map<String, dynamic>> _buildHistory() {
    return [
      // System prompt is the first message — tells the AI who it is
      {'role': 'system', 'content': _systemPrompt},
      // Conversation history (skip welcome message at index 0, skip errors)
      ...messages
          .skip(1)
          .where((m) => !m.isError)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              }),
    ];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
