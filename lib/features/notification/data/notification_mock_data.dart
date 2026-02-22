// Mock data cho màn Notification - có thể chỉnh sửa hoặc generate bằng prompt

import 'package:travel_app/domain/models/notification_item.dart';

List<NotificationItem> getNotificationMockItems() {
  return [
    // Lời mời nhóm chỉ hiện khi có dữ liệu thật từ backend, không dùng mock.
    NotificationItem(
      type: NotificationType.tripReminder,
      id: 'reminder_1',
      title: 'Nhắc chuyến đi',
      subtitle: 'Chuyến đi đến Hà Nội bắt đầu trong 24 giờ!',
    ),
    NotificationItem(
      type: NotificationType.progress,
      id: 'progress_1',
      title: 'Tiến độ hành trình',
      subtitle: '65% chuyến đi của bạn đã hoàn thành',
      percent: 65,
    ),
    NotificationItem(
      type: NotificationType.weatherAlert,
      id: 'weather_1',
      title: 'Cảnh báo thời tiết',
      subtitle: 'Dự báo mưa lớn tại Đà Nẵng ngày mai',
      weatherLocation: 'Đà Nẵng',
      weatherMessage: 'Mưa lớn dự kiến - chuẩn bị áo mưa!',
    ),
  ];
}
