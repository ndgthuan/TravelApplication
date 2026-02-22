// Các loại thông báo hiển thị trên màn Notification

import 'package:flutter/foundation.dart';

enum NotificationType { groupInvite, tripReminder, progress, weatherAlert }

class NotificationItem {
  final NotificationType type;
  final String id;
  final String title;
  final String subtitle;
  // groupInvite: tripName = plan.title, destination = plan.destination
  final String? inviterName;
  final String? tripName;
  final String? destination;
  final String?
  planId; // groupInvite: planId gốc; progress: planId của chuyến đi
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  // progress: title = plan.title (Trip Name)
  final int? percent;
  // weatherAlert
  final String? weatherLocation;
  final String? weatherMessage;

  NotificationItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.inviterName,
    this.tripName,
    this.destination,
    this.planId,
    this.onAccept,
    this.onDecline,
    this.percent,
    this.weatherLocation,
    this.weatherMessage,
  });
}
