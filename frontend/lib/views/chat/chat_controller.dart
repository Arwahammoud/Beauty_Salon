import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:belle_beauty_salon/views/chat/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// The chat used to call Groq's API directly from this file with a hardcoded
// key — that key was committed to git history and is now compromised. The
// backend now owns the LLM key and this screen just talks to our own API.
// See backend/src/controllers/chat.controller.js and POST /api/v1/chat.
class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;

  final inputController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    messages.add(ChatMessage(
      text: 'chat_welcome_message'.tr,
      isUser: false,
    ));
  }

  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    inputController.clear();
    messages.add(ChatMessage(text: text, isUser: true));
    isTyping.value = true;
    _scrollToBottom();

    try {
      final data = await ApiService.post(
        '/chat',
        auth: true,
        body: {
          'message': text,
          'history': _buildHistory(),
        },
      );
      messages.add(ChatMessage(text: (data['reply'] as String).trim(), isUser: false));
    } on ApiException catch (e) {
      messages.add(ChatMessage(text: e.message, isUser: false, isError: true));
    } catch (_) {
      messages.add(ChatMessage(
        text: 'chat_connection_failed'.tr,
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
      text: 'chat_cleared_message'.tr,
      isUser: false,
    ));
  }

  // Conversation history for context, excluding the welcome message and
  // any error bubbles (the backend adds its own system prompt).
  List<Map<String, String>> _buildHistory() {
    return messages
        .skip(1)
        .where((m) => !m.isError)
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();
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
