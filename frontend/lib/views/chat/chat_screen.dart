import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/chat/chat_controller.dart';
import 'package:belle_beauty_salon/views/chat/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _MessageList(controller: controller)),
          _TypingIndicator(controller: controller),
          _InputBar(controller: controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            // Bot avatar
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  color: AppColors.white, size: 20.sp),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chat_header_title'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'chat_header_subtitle'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Clear chat button
        Obx(() {
          final ctrl = Get.find<ChatController>();
          if (ctrl.messages.length <= 1) return const SizedBox.shrink();
          return IconButton(
            onPressed: () => _showClearDialog(ctrl),
            icon: Icon(Icons.delete_outline_rounded,
                color: AppColors.textFaint, size: 20.sp),
            tooltip: 'chat_clear_tooltip'.tr,
          );
        }),
        SizedBox(width: 6.w),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Divider(height: 1, color: AppColors.line),
      ),
    );
  }

  void _showClearDialog(ChatController ctrl) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: const BoxDecoration(
                  color: AppColors.chip,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: AppColors.primary, size: 24.sp),
              ),
              SizedBox(height: 14.h),
              Text(
                'chat_clear_dialog_title'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'chat_clear_dialog_body'.tr,
                style: GoogleFonts.outfit(
                    fontSize: 12.sp, color: AppColors.textMuted),
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Center(
                          child: Text(
                            'cancel'.tr,
                            style: GoogleFonts.outfit(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        ctrl.clearChat();
                      },
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'chat_clear_btn'.tr,
                            style: GoogleFonts.outfit(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Message list ─────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final ChatController controller;
  const _MessageList({required this.controller});

  List<String> get _suggestions => [
    'chat_suggestion_1'.tr,
    'chat_suggestion_2'.tr,
    'chat_suggestion_3'.tr,
    'chat_suggestion_4'.tr,
    'chat_suggestion_5'.tr,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msgs = controller.messages;
      final showSuggestions = msgs.length == 1; // only welcome message
      return ListView.builder(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
        itemCount: msgs.length + (showSuggestions ? 1 : 0),
        itemBuilder: (_, i) {
          if (i < msgs.length) {
            return _ChatBubble(message: msgs[i]);
          }
          // Suggestion chips after welcome message
          return _SuggestionChips(
            suggestions: _suggestions,
            onTap: (text) {
              controller.inputController.text =
                  text.substring(2).trim(); // strip emoji
              controller.sendMessage();
            },
          );
        },
      );
    });
  }
}

// ── Suggestion chips ─────────────────────────────────────────────────────────

class _SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;
  const _SuggestionChips(
      {required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'chat_quick_questions'.tr,
            style: GoogleFonts.outfit(
                fontSize: 11.sp, color: AppColors.textFaint),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: suggestions
                .map((s) => GestureDetector(
                      onTap: () => onTap(s),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 13.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(999.r),
                          border:
                              Border.all(color: AppColors.primarySoft, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.07),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Chat bubble ───────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _BotAvatar(),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  constraints: BoxConstraints(maxWidth: 270.w),
                  decoration: BoxDecoration(
                    gradient:
                        isUser ? AppColors.primaryGradient : null,
                    color: isUser
                        ? null
                        : message.isError
                            ? const Color(0xFFFFF3CD)
                            : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.r),
                      topRight: Radius.circular(18.r),
                      bottomLeft: isUser
                          ? Radius.circular(18.r)
                          : Radius.circular(4.r),
                      bottomRight: isUser
                          ? Radius.circular(4.r)
                          : Radius.circular(18.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? AppColors.primary.withValues(alpha: 0.22)
                            : AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: isUser ? 10 : 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: !isUser
                        ? Border.all(color: AppColors.line, width: 0.8)
                        : null,
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      height: 1.55,
                      color: isUser
                          ? AppColors.white
                          : message.isError
                              ? const Color(0xFF856404)
                              : AppColors.text,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  message.formattedTime,
                  style: GoogleFonts.outfit(
                      fontSize: 9.sp, color: AppColors.textFaint),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8.w),
            _UserAvatar(),
          ],
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.r,
      height: 28.r,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child:
          Icon(Icons.auto_awesome_rounded, color: AppColors.white, size: 14.sp),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.r,
      height: 28.r,
      decoration: BoxDecoration(
        color: AppColors.chip,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primarySoft, width: 1.5),
      ),
      child: Icon(Icons.person_rounded, color: AppColors.primary, size: 15.sp),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  final ChatController controller;
  const _TypingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isTyping.value) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        child: Row(
          children: [
            _BotAvatar(),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const _BouncingDots(),
            ),
          ],
        ),
      );
    });
  }
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final phase = (_ctrl.value + i / 3) % 1.0;
            final t = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
            return Transform.translate(
              offset: Offset(0, -5 * t),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                width: 7.r,
                height: 7.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.4 + t * 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final ChatController controller;
  const _InputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w,
          MediaQuery.of(context).padding.bottom + 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxHeight: 120.h),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.line),
              ),
              child: TextField(
                controller: controller.inputController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(),
                style: GoogleFonts.outfit(
                    fontSize: 13.sp, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'chat_input_hint'.tr,
                  hintStyle: GoogleFonts.outfit(
                      fontSize: 13.sp, color: AppColors.textFaint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Send button
          Obx(() {
            final typing = controller.isTyping.value;
            return GestureDetector(
              onTap: typing ? null : controller.sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  gradient:
                      typing ? null : AppColors.primaryGradient,
                  color: typing ? AppColors.line : null,
                  shape: BoxShape.circle,
                  boxShadow: typing
                      ? null
                      : [
                          BoxShadow(
                            color:
                                AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: typing
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      )
                    : Icon(Icons.send_rounded,
                        color: AppColors.white, size: 18.sp),
              ),
            );
          }),
        ],
      ),
    );
  }
}
