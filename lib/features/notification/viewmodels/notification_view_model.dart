// ViewModel cho màn Notification - load và quản lý danh sách thông báo

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_app/domain/models/plan_invite_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';
import 'package:travel_app/domain/services/i_geocoding_service.dart';
import 'package:travel_app/domain/services/i_weather_service.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';
import 'package:travel_app/domain/models/notification_item.dart';
import 'package:travel_app/domain/models/user_model.dart';
import 'package:travel_app/features/notification/data/notification_mock_data.dart';

class NotificationViewModel extends ChangeNotifier {
  final IPlanRepository _planRepository;
  final IUserRepository _userRepository;
  final IWeatherService _weatherService;
  final IGeocodingService _geocodingService;

  NotificationViewModel(
    this._planRepository,
    this._userRepository,
    this._geocodingService,
    this._weatherService,
  );

  List<NotificationItem> _items = [];
  bool _isLoading = true;

  List<NotificationItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    final items = <NotificationItem>[];
    final user = await _userRepository.getCurrentUser();
    final userId = user?.uid;

    if (userId == null || userId.isEmpty) {
      _items = getNotificationMockItems();
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Lời mời vào nhóm từ Firestore plan_invites
    final invites = await _planRepository.getPendingInvitesForUser(userId);
    for (final invite in invites) {
      items.add(NotificationItem(
        type: NotificationType.groupInvite,
        id: invite.id,
        title: 'Lời mời vào nhóm ${invite.tripName}',
        subtitle: '${invite.fromUserName} mời bạn tham gia chuyến đi ${invite.destination}',
        inviterName: invite.fromUserName,
        tripName: invite.tripName,
        destination: invite.destination,
        planId: invite.planId,
        onAccept: () => _acceptInvite(invite, user!, items),
        onDecline: () => _declineInvite(invite, items),
      ));
    }

    // Trip reminder + Progress từ ongoing plans
    final ongoing = await _planRepository.getOngoingPlans(userId);
    for (final plan in ongoing) {
      final hoursToStart = plan.startDate.difference(DateTime.now()).inHours;
      if (hoursToStart > 0 && hoursToStart <= 24) {
        items.add(NotificationItem(
          type: NotificationType.tripReminder,
          id: 'reminder_${plan.id}',
          title: 'plan.trip_reminder'.tr(),
          subtitle: 'Chuyến đi đến ${plan.destination} bắt đầu trong 24 giờ!',
        ));
      }

      // Progress: checked-in / total, title = Trip Name (plan.title)
      final activities = await _planRepository.getActivities(userId, plan.id);
      if (activities.isNotEmpty) {
        final checked = activities.where((a) => a.isCheckedIn).length;
        final pct = (checked * 100 / activities.length).round();
        items.add(NotificationItem(
          type: NotificationType.progress,
          id: 'progress_${plan.id}',
          title: plan.title,
          subtitle: '$pct% chuyến đi đã hoàn thành',
          percent: pct,
          planId: plan.id,
        ));
      }
    }

    // Weather alert - check forecast cho destination của plan sắp tới
    for (final plan in ongoing) {
      final alert = await _fetchWeatherAlert(plan);
      if (alert != null) items.add(alert);
    }

    _items = items;
    _isLoading = false;
    notifyListeners();
  }

  // Chấp nhận lời mời: lưu plan_shared ref trước, rồi thêm member vào plan.
  Future<void> _acceptInvite(
    PlanInviteModel invite,
    UserModel user,
    List<NotificationItem> items,
  ) async {
    try {
      await _planRepository.saveSharedPlanRef(user.uid, invite.planOwnerId, invite.planId);
      final ownerPlan = await _planRepository.getPlan(invite.planOwnerId, invite.planId);
      if (ownerPlan == null) {
        await _planRepository.updateInviteStatus(invite.id, 'accepted');
        _items = items.where((i) => i.id != invite.id).toList();
        notifyListeners();
        return;
      }
      final inviteeMember = PlanMember(
        email: user.email,
        avatarUrl: user.avatarUrl ?? '',
        role: 'spectator',
      );
      final pendingWithoutMe = ownerPlan.pendingInviteEmails
          .where((e) => e != user.email)
          .toList();
      final ownerPlanUpdated = ownerPlan.copyWith(
        members: [...ownerPlan.members, inviteeMember],
        pendingInviteEmails: pendingWithoutMe,
      );
      await _planRepository.updatePlan(invite.planOwnerId, ownerPlanUpdated);
      await _planRepository.updateInviteStatus(invite.id, 'accepted');
      _items = items.where((i) => i.id != invite.id).toList();
      notifyListeners();
    } catch (_) {}
  }

  void _declineInvite(PlanInviteModel invite, List<NotificationItem> items) async {
    try {
      await _planRepository.updateInviteStatus(invite.id, 'declined');
      _items = items.where((i) => i.id != invite.id).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<NotificationItem?> _fetchWeatherAlert(PlanModel plan) async {
    if (plan.destination.isEmpty) return null;
    try {
      final cities = await _geocodingService.searchCities(plan.destination);
      if (cities.isEmpty) return null;
      final lat = (cities.first['latitude'] as num?)?.toDouble() ?? 0.0;
      final lon = (cities.first['longitude'] as num?)?.toDouble() ?? 0.0;
      if (lat == 0 && lon == 0) return null;

      final data = await _weatherService.getForecast(latitude: lat, longitude: lon);
      if (data == null) return null;

      // Open-Meteo WMO codes: 61-67=mưa, 80-82=mưa rào, 95-99=dông
      final daily = data['daily'] as Map<String, dynamic>?;
      if (daily == null) return null;
      final codes = daily['weather_code'] as List?;
      if (codes == null || codes.isEmpty) return null;

      final severeCodes = [61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99];
      for (var i = 0; i < codes.length && i < 3; i++) {
        final code = (codes[i] as num?)?.toInt() ?? 0;
        if (severeCodes.contains(code)) {
          return NotificationItem(
            type: NotificationType.weatherAlert,
            id: 'weather_${plan.id}_$i',
            title: 'weather.alert'.tr(),
            subtitle: 'Mưa/giông dự báo tại ${plan.destination} trong vài ngày tới',
            weatherLocation: plan.destination,
            weatherMessage: 'Dự báo mưa hoặc giông - chuẩn bị áo mưa nhé!',
          );
        }
      }
    } catch (_) {}
    return null;
  }

}
