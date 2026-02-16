// Đây là item sẽ hiển thị trong bảng nội dung sau khi tạo activty trong activity plan screen
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';

typedef ActivityCallback = void Function(PlanActivityModel activity);

class ActivityTimelineItem extends StatelessWidget {
  final PlanActivityModel activity;
  final bool isCurrent;
  final bool isPast;
  final String timeStr;
  final Color textColor;
  final Color timeColor;
  final double lineHeight;
  final Color lineColor;
  final ActivityCallback? onUncheckIn;
  final ActivityCallback? onEditActivity;
  final ActivityCallback? onDeleteActivity;
  final VoidCallback? onCheckIn;

  const ActivityTimelineItem({
    super.key,
    required this.activity,
    required this.isCurrent,
    required this.isPast,
    required this.timeStr,
    required this.textColor,
    required this.timeColor,
    required this.lineHeight,
    required this.lineColor,
    this.onUncheckIn,
    this.onEditActivity,
    this.onDeleteActivity,
    this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vẽ thời gian
              Text(
                timeStr,
                style: GoogleFonts.beVietnamPro(color: timeColor, fontSize: 18),
              ),
              Container(height: lineHeight, color: Colors.transparent),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            // Nếu là đã check in thì icon sẽ hiện màu xanh
            if (isPast)
              GestureDetector(
                onTap: () => onUncheckIn?.call(activity),
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              )
            // Nếu chưa check in và trong khoản đang thực hiện thì sẽ là màu cam hoặc màu xám
            else
              Icon(
                CupertinoIcons.circle_fill,
                color: isCurrent
                    ? const Color(0xFFFF6D00)
                    : Colors.white.withValues(alpha: 0.3),
                size: 25,
              ),
            Container(
              height: lineHeight,
              width: 2,
              decoration: BoxDecoration(color: lineColor),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      timeStr,
                      style: GoogleFonts.beVietnamPro(
                        color: timeColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (onEditActivity != null || onDeleteActivity != null)
                    SizedBox(
                      width: 36,
                      height: 32,
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Icon(
                          Icons.more_horiz,
                          color: Colors.white70,
                          size: 20,
                        ),
                        items: [
                          if (onEditActivity != null)
                            DropdownMenuItem(
                              value: 'edit',
                              child: Text(
                                'Sửa',
                                style: GoogleFonts.beVietnamPro(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          if (onDeleteActivity != null)
                            DropdownMenuItem(
                              value: 'delete',
                              child: Text(
                                'Xóa',
                                style: GoogleFonts.beVietnamPro(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == 'edit') {
                            onEditActivity?.call(activity);
                          } else if (value == 'delete') {
                            onDeleteActivity?.call(activity);
                          }
                        },
                        buttonStyleData: const ButtonStyleData(
                          height: 32,
                          width: 36,
                          padding: EdgeInsets.zero,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF2A2A2A),
                          ),
                          offset: const Offset(0, -4),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 16,
                          iconEnabledColor: Colors.white70,
                          iconDisabledColor: Colors.grey,
                        ),
                        underline: const SizedBox(),
                      ),
                    ),
                ],
              ),
              // Các phần nội dung
              Text(
                activity.name,
                style: GoogleFonts.beVietnamPro(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (activity.addressText != null &&
                  activity.addressText!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(CupertinoIcons.pin, color: timeColor, size: 16),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        activity.addressText!,
                        style: GoogleFonts.beVietnamPro(color: timeColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              // Nếu mà đang ở mục tiếp theo phải check in thì hiện box check in
              if (isCurrent) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onCheckIn,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6D00),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Check-in ngay',
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
