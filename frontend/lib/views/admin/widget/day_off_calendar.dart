import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Month calendar for marking whole-salon or per-specialist days off, with an
// optional note/reason. Tapping a date opens a dialog to view/add/remove
// day-off entries for that date, and to deal with any bookings already on it.
class DayOffCalendar extends StatelessWidget {
  final AdminController ctrl;
  const DayOffCalendar({super.key, required this.ctrl});

  static const _monthKeys = [
    'admin_month_1', 'admin_month_2', 'admin_month_3', 'admin_month_4',
    'admin_month_5', 'admin_month_6', 'admin_month_7', 'admin_month_8',
    'admin_month_9', 'admin_month_10', 'admin_month_11', 'admin_month_12',
  ];

  static const _weekDayKeys = [
    'day_mon', 'day_tue', 'day_wed', 'day_thu', 'day_fri', 'day_sat', 'day_sun',
  ];

  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final month = ctrl.calendarMonth.value;
      final firstOfMonth = DateTime(month.year, month.month, 1);
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final leadingBlanks = (firstOfMonth.weekday - 1) % 7;
      final totalCells = leadingBlanks + daysInMonth;
      final today = DateTime.now();

      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'day_off_calendar_title'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => ctrl.changeCalendarMonth(-1),
                  child: Icon(Icons.chevron_left_rounded,
                      color: AppColors.textMuted, size: 22.sp),
                ),
                SizedBox(width: 6.w),
                Text(
                  '${_monthKeys[month.month - 1].tr} ${month.year}',
                  style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () => ctrl.changeCalendarMonth(1),
                  child: Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted, size: 22.sp),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: List.generate(
                7,
                (i) => Expanded(
                  child: Center(
                    child: Text(
                      _weekDayKeys[i].tr,
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textFaint,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalCells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemBuilder: (context, index) {
                if (index < leadingBlanks) return const SizedBox.shrink();
                final dayNum = index - leadingBlanks + 1;
                final date = DateTime(month.year, month.month, dayNum);
                final iso = isoDate(date);
                final entries = ctrl.dayOffsFor(iso);
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final isWholeSalonOff = entries.any((e) => e.specialistId == null);

                Color bg;
                Color fg;
                if (isWholeSalonOff) {
                  bg = AppColors.danger;
                  fg = AppColors.white;
                } else if (entries.isNotEmpty) {
                  bg = AppColors.warn.withValues(alpha: 0.18);
                  fg = AppColors.text;
                } else if (isToday) {
                  bg = AppColors.chip;
                  fg = AppColors.primary;
                } else {
                  bg = Colors.transparent;
                  fg = AppColors.text;
                }

                return GestureDetector(
                  onTap: () => _showDayDialog(context, date),
                  child: Container(
                    margin: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      border: isToday && !isWholeSalonOff
                          ? Border.all(color: AppColors.primary, width: 1.2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                _LegendDot(color: AppColors.danger, label: 'day_off_whole_salon'.tr),
                SizedBox(width: 14.w),
                _LegendDot(
                  color: AppColors.warn.withValues(alpha: 0.5),
                  label: 'field_specialist'.tr,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showDayDialog(BuildContext context, DateTime date) {
    Get.dialog(_DayOffDialog(ctrl: ctrl, date: date));
  }
}

// Small "are you sure?" gate for the two destructive actions in the day-off
// dialog below (removing an entry, cancelling real bookings).
Future<bool> _confirmAction(String title, String body, String confirmLabel) async {
  final result = await Get.dialog<bool>(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.text),
            ),
            SizedBox(height: 6.h),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 12.sp, color: AppColors.textMuted, height: 1.4),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(result: false),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Center(
                        child: Text('keep_it'.tr,
                            style: GoogleFonts.outfit(
                                fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(result: true),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(confirmLabel,
                            style: GoogleFonts.outfit(
                                fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
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
    barrierDismissible: false,
  );
  return result ?? false;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(label,
            style: GoogleFonts.outfit(fontSize: 10.sp, color: AppColors.textMuted)),
      ],
    );
  }
}

class _DayOffDialog extends StatefulWidget {
  final AdminController ctrl;
  final DateTime date;
  const _DayOffDialog({required this.ctrl, required this.date});

  @override
  State<_DayOffDialog> createState() => _DayOffDialogState();
}

class _DayOffDialogState extends State<_DayOffDialog> {
  final _noteCtrl = TextEditingController();
  String? _selectedSpecialistId; // null = whole salon
  List<AdminBooking>? _affected; // set once the admin taps save & bookings exist
  bool _saving = false;

  String get _iso => DayOffCalendar.isoDate(widget.date);

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSaveTapped() async {
    final affected = widget.ctrl
        .bookingsOnDate(_iso, specialistId: _selectedSpecialistId);
    if (affected.isNotEmpty && _affected == null) {
      setState(() => _affected = affected);
      return;
    }
    await _finishSave();
  }

  Future<void> _finishSave() async {
    setState(() => _saving = true);
    final ok = await widget.ctrl.addDayOff(
      date: _iso,
      specialistId: _selectedSpecialistId,
      note: _noteCtrl.text.trim(),
    );
    setState(() => _saving = false);
    if (ok) Get.back();
  }

  Future<void> _cancelAllAndSave() async {
    final ok = await _confirmAction(
      'day_off_cancel_all_confirm_title'.tr,
      'day_off_cancel_all_confirm_body'.trParams({'count': '${_affected?.length ?? 0}'}),
      'yes_cancel'.tr,
    );
    if (!ok) return;

    setState(() => _saving = true);
    await widget.ctrl.cancelBookingsOnDate(_iso, specialistId: _selectedSpecialistId);
    Get.snackbar('success'.tr, 'day_off_cancelled_all'.tr);
    await _finishSave();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final existing = ctrl.dayOffsFor(_iso);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _iso,
                style: GoogleFonts.outfit(
                    fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              SizedBox(height: 14.h),

              // Existing day-off entries for this date
              Text('day_off_existing_title'.tr,
                  style: GoogleFonts.outfit(
                      fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              SizedBox(height: 6.h),
              if (existing.isEmpty)
                Text('day_off_none_for_date'.tr,
                    style: GoogleFonts.outfit(fontSize: 12.sp, color: AppColors.textFaint))
              else
                ...existing.map((e) => Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.specialistId == null
                                      ? 'day_off_whole_salon'.tr
                                      : (e.specialistName ?? ''),
                                  style: GoogleFonts.outfit(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text),
                                ),
                                if (e.note.trim().isNotEmpty)
                                  Text(
                                    e.note,
                                    style: GoogleFonts.outfit(
                                        fontSize: 10.sp, color: AppColors.textMuted),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final ok = await _confirmAction(
                                'day_off_remove_confirm_title'.tr,
                                'day_off_remove_confirm_body'.tr,
                                'yes_remove'.tr,
                              );
                              if (ok) ctrl.removeDayOff(e.id);
                            },
                            child: Text(
                              'day_off_remove_btn'.tr,
                              style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger),
                            ),
                          ),
                        ],
                      ),
                    )),

              SizedBox(height: 16.h),
              Divider(color: AppColors.line, height: 1),
              SizedBox(height: 16.h),

              Text('day_off_add_title'.tr,
                  style: GoogleFonts.outfit(
                      fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.text)),
              SizedBox(height: 10.h),

              if (_affected == null) ...[
                Text('day_off_scope_label'.tr,
                    style: GoogleFonts.outfit(
                        fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                SizedBox(height: 6.h),
                DropdownButtonFormField<String?>(
                  initialValue: _selectedSpecialistId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.bg,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('day_off_whole_salon'.tr)),
                    ...ctrl.specialists.map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedSpecialistId = v),
                ),
                SizedBox(height: 12.h),
                Text('day_off_note_label'.tr,
                    style: GoogleFonts.outfit(
                        fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                SizedBox(height: 6.h),
                TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.bg,
                    hintText: 'day_off_note_hint'.tr,
                    hintStyle: GoogleFonts.outfit(fontSize: 12.sp, color: AppColors.textFaint),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  style: GoogleFonts.outfit(fontSize: 12.sp, color: AppColors.text),
                ),
                SizedBox(height: 18.h),
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
                              child: Text('cancel'.tr,
                                  style: GoogleFonts.outfit(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted))),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: _saving ? null : _onSaveTapped,
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: _saving
                                ? SizedBox(
                                    width: 16.r,
                                    height: 16.r,
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text('day_off_save_btn'.tr,
                                    style: GoogleFonts.outfit(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Existing bookings found for this date/scope — let the admin
                // choose what happens to them before the day off is saved.
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.warn.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'day_off_affected_bookings'.trParams({'count': '${_affected!.length}'}),
                    style: GoogleFonts.outfit(
                        fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.text),
                  ),
                ),
                SizedBox(height: 10.h),
                ..._affected!.map((b) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${b.clientName.isEmpty ? 'admin_unknown_client'.tr : b.clientName} · ${b.time}',
                              style: GoogleFonts.outfit(fontSize: 11.sp, color: AppColors.textMuted),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await ctrl.updateBookingStatus(b.id, 'cancelled');
                              setState(() => _affected = widget.ctrl
                                  .bookingsOnDate(_iso, specialistId: _selectedSpecialistId));
                            },
                            child: Text('cancel'.tr,
                                style: GoogleFonts.outfit(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.danger)),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: _saving ? null : _cancelAllAndSave,
                  child: Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                        child: Text('day_off_cancel_all_btn'.tr,
                            style: GoogleFonts.outfit(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger))),
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: _saving ? null : _finishSave,
                  child: Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: _saving
                          ? SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text('day_off_keep_bookings_btn'.tr,
                              style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
