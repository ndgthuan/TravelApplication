// Card hiển thị từng loại thông báo - thiết kế dark mode, góc bo 20px, accent cam

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/domain/models/notification_item.dart';

class NotificationCardWidget extends StatelessWidget {
  final NotificationItem item;

  const NotificationCardWidget({super.key, required this.item});

  static const _orange = Color(0xFFFF6D00);
  static const _cardBg = Color(0xFF1C1C1D);
  static const _cardRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (item.type) {
      case NotificationType.groupInvite:
        return _buildGroupInvite(context);
      case NotificationType.tripReminder:
        return _buildTripReminder(context);
      case NotificationType.progress:
        return _buildProgress(context);
      case NotificationType.weatherAlert:
        return _buildWeatherAlert(context);
    }
  }

  Widget _buildGroupInvite(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _orange.withValues(alpha: 0.3),
              child: Text(
                (item.inviterName ?? 'A').substring(0, 1).toUpperCase(),
                style: GoogleFonts.beVietnamPro(
                  color: _orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: item.onAccept,
                style: FilledButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Chấp nhận',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: item.onDecline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Từ chối',
                  style: GoogleFonts.beVietnamPro(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripReminder(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(CupertinoIcons.clock, color: _orange, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context) {
    final pct = (item.percent ?? 0).clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: GoogleFonts.beVietnamPro(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.subtitle,
          style: GoogleFonts.beVietnamPro(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(_orange),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAlert(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.amber, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
