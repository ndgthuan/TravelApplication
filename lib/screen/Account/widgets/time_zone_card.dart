import 'dart:async';
import 'package:flutter/material.dart';
import 'premium_analog_clock.dart';

class TimeZoneCard extends StatefulWidget {
  final String city;
  final String country;
  final String timezone;
  final int timezoneOffset;
  final VoidCallback? onDelete;

  const TimeZoneCard({
    super.key,
    required this.city,
    required this.country,
    required this.timezone,
    required this.timezoneOffset,
    this.onDelete,
  });

  @override
  State<TimeZoneCard> createState() => _TimeZoneCardState();
}

class _TimeZoneCardState extends State<TimeZoneCard> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now().toUtc().add(
        Duration(hours: widget.timezoneOffset),
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime() {
    final hour = _currentTime.hour;
    final minute = _currentTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _getOffsetText() {
    final localOffset = DateTime.now().timeZoneOffset.inHours;
    final diff = widget.timezoneOffset - localOffset;

    if (diff == 0) return 'Same time';

    final sign = diff > 0 ? '+' : '';
    return 'Today, $sign$diff HRS';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${widget.city}_${widget.country}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete?.call(),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF1C1C1D),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Tên thành phố, quốc gia
                      Text(
                        '${widget.city}, ${widget.country}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'ProductSans',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Giờ thế giới
                      Text(
                        _formatTime(),
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          color: Color(0xFFFFAD35),
                          fontSize: 40,
                        ),
                      ),

                      // Offset so với local
                      Text(
                        _getOffsetText(),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 100,
                  height: 100,
                  child: PremiumAnalogClock(
                    accentColor: Color(0xFFFFAD35),
                    dialColor: Color(0xFF2C2C2E),
                    timezoneOffset: widget.timezoneOffset,
                    showSecondHand: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
