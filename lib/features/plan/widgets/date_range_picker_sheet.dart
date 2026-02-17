import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/plan/viewmodels/plan_view_model.dart';

// Bottom sheet custom calendar để chọn date range.
// Những ngày nào được chọn sẽ có chấm tròn dưới ngày
class DateRangePickerSheet extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const DateRangePickerSheet({super.key, this.initialStart, this.initialEnd});

  @override
  State<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<DateRangePickerSheet> {
  late DateTime _focusedMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  static const _accent = Color(0xFFFF6D00);
  static const _bg = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialStart;
    _rangeEnd = widget.initialEnd;
    _focusedMonth = widget.initialStart ?? DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanViewModel>().fetchAllPlans();
    });
  }

  //==========================================================================//
  //                           SELECTION LOGIC                                //
  //==========================================================================//
  void _onDayTap(DateTime day) {
    setState(() {
      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = day;
        _rangeEnd = null;
      } else if (day.isBefore(_rangeStart!)) {
        _rangeEnd = _rangeStart;
        _rangeStart = day;
      } else {
        _rangeEnd = day;
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInRange(DateTime day) =>
      _rangeStart != null &&
      _rangeEnd != null &&
      !day.isBefore(_rangeStart!) &&
      !day.isAfter(_rangeEnd!);

  //==========================================================================//
  //                              BUILD                                    //
  //==========================================================================//
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlanViewModel>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          _buildMonthHeader(),
          const SizedBox(height: 8),
          _buildWeekdayRow(),
          const SizedBox(height: 8),
          _buildDaysGrid(vm),
          const SizedBox(height: 16),
          _buildRangeInfo(),
          _buildLegend(),
          const SizedBox(height: 12),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  //==========================================================================//
  //                        UI COMPONENTS                                  //
  //==========================================================================//
  Widget _buildDragHandle() => Container(
    width: 40,
    height: 4,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.grey[600],
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _buildMonthHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.white),
        onPressed: () => setState(() {
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
        }),
      ),
      Text(
        DateFormat.yMMMM(context.locale.toString()).format(_focusedMonth),
        style: GoogleFonts.beVietnamPro(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.chevron_right, color: Colors.white),
        onPressed: () => setState(() {
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
        }),
      ),
    ],
  );

  Widget _buildWeekdayRow() {
    final locale = context.locale.toString();
    // Generate Mon-Sun weekday abbreviations in current locale
    final weekdays = List.generate(7, (i) {
      // DateTime weekday: 1=Mon, 7=Sun -> Jan 5 2026 is a Monday
      final day = DateTime(2026, 1, 5 + i);
      return DateFormat.E(locale).format(day);
    });
    return Row(
      children: weekdays
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRangeInfo() {
    if (_rangeStart == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        _rangeEnd != null
            ? '${_rangeStart!.day}/${_rangeStart!.month} — ${_rangeEnd!.day}/${_rangeEnd!.month}'
            : 'plan.pick_end_date'.tr(),
        style: GoogleFonts.beVietnamPro(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildLegend() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _accent),
      ),
      const SizedBox(width: 6),
      Text(
        'plan.has_trip'.tr(),
        style: GoogleFonts.beVietnamPro(color: Colors.white54, fontSize: 12),
      ),
    ],
  );

  Widget _buildConfirmButton() => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: (_rangeStart != null && _rangeEnd != null)
          ? () => Navigator.pop(
              context,
              DateTimeRange(start: _rangeStart!, end: _rangeEnd!),
            )
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        disabledBackgroundColor: _accent.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'plan.confirm'.tr(),
        style: GoogleFonts.beVietnamPro(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
  //==========================================================================//
  //                          DAYS GRID                                  //
  //==========================================================================//

  Widget _buildDaysGrid(PlanViewModel vm) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday; // 1=Mon .. 7=Sun
    final totalCells = startWeekday - 1 + lastDay.day;
    final rows = (totalCells / 7).ceil();
    final today = DateTime.now();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final dayNum = row * 7 + col - (startWeekday - 1) + 1;
            if (dayNum < 1 || dayNum > lastDay.day) {
              return const Expanded(child: SizedBox(height: 44));
            }
            final day = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              dayNum,
            );
            return Expanded(child: _buildDayCell(day, today, vm));
          }),
        );
      }),
    );
  }

  Widget _buildDayCell(DateTime day, DateTime today, PlanViewModel vm) {
    final isToday = _isSameDay(day, today);
    final isStart = _rangeStart != null && _isSameDay(day, _rangeStart!);
    final isEnd = _rangeEnd != null && _isSameDay(day, _rangeEnd!);
    final inRange = _isInRange(day);
    final isBooked = vm.isDayBooked(day);
    final isPast = day.isBefore(DateTime(today.year, today.month, today.day));

    return GestureDetector(
      onTap: isPast ? null : () => _onDayTap(day),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _dayCellColor(isStart, isEnd, inRange),
          borderRadius: _dayCellRadius(isStart, isEnd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: GoogleFonts.beVietnamPro(
                color: _dayTextColor(isPast, isStart, isEnd, isToday),
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            // Chấm tròn màu vàng khi đã có trip
            if (isBooked)
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isStart || isEnd) ? Colors.black : _accent,
                ),
              )
            else
              const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
  //==========================================================================//
  //                        STYLE HELPERS                                     //
  //==========================================================================//

  Color? _dayCellColor(bool isStart, bool isEnd, bool inRange) {
    if (isStart || isEnd) return _accent;
    if (inRange) return _accent.withValues(alpha: 0.2);
    return null;
  }

  BorderRadius? _dayCellRadius(bool isStart, bool isEnd) {
    if (isStart && isEnd) return BorderRadius.circular(22);
    if (isStart) {
      return const BorderRadius.horizontal(left: Radius.circular(22));
    }
    if (isEnd) {
      return const BorderRadius.horizontal(right: Radius.circular(22));
    }
    return null;
  }

  Color _dayTextColor(bool isPast, bool isStart, bool isEnd, bool isToday) {
    if (isPast) return Colors.white24;
    if (isStart || isEnd) return Colors.black;
    if (isToday) return _accent;
    return Colors.white;
  }
}
