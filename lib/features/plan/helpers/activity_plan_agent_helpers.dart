import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';
import 'package:travel_app/domain/services/i_travel_agent_service.dart';

// Helpers cho Travel Agent edit plan: build payload, map type, apply new plan lên repository.

Map<String, dynamic> buildCurrentPlanForAgent(
  PlanModel plan,
  List<PlanActivityModel> activities,
) {
  final list = <Map<String, dynamic>>[];
  for (var i = 0; i < activities.length; i++) {
    final a = activities[i];
    list.add({
      'order': i + 1,
      'name': a.name,
      'type': a.type,
      'time':
          '${a.time.hour.toString().padLeft(2, '0')}:${a.time.minute.toString().padLeft(2, '0')}',
      'date':
          '${a.time.year}-${a.time.month.toString().padLeft(2, '0')}-${a.time.day.toString().padLeft(2, '0')}',
      'address': a.addressText ?? '',
      'coordinates': '${a.latitude},${a.longitude}',
    });
  }
  return {
    'trip_info': {
      'name': plan.title,
      'destination': plan.destination,
      'start_date':
          '${plan.startDate.year}-${plan.startDate.month.toString().padLeft(2, '0')}-${plan.startDate.day.toString().padLeft(2, '0')}',
      'end_date':
          '${plan.endDate.year}-${plan.endDate.month.toString().padLeft(2, '0')}-${plan.endDate.day.toString().padLeft(2, '0')}',
      'total_days': plan.totalDays,
    },
    'activities': list,
  };
}

String mapActivityType(String? t) {
  if (t == null || t.isEmpty) return 'sightseeing';
  final lower = t.toLowerCase();
  if (lower.contains('restaurant') || lower.contains('food')) return 'restaurant';
  if (lower.contains('lodging') || lower.contains('hotel')) return 'lodging';
  if (lower.contains('tour')) return 'tour';
  return 'sightseeing';
}

Future<void> applyAgentPlanToRepository(
  IPlanRepository repo,
  String ownerId,
  String planId,
  List<PlanActivityModel> currentActivities,
  Map<String, dynamic> newPlan,
) async {
  for (final a in currentActivities) {
    await repo.deleteActivity(ownerId, planId, a.id);
  }
  final dailyPlans = newPlan['daily_plans'] as List<dynamic>? ?? [];
  for (final dayData in dailyPlans) {
    final dayMap = dayData as Map<String, dynamic>;
    final dateStr = dayMap['date'] as String? ?? '';
    final activities = dayMap['activities'] as List<dynamic>? ?? [];
    for (final act in activities) {
      final actMap = act as Map<String, dynamic>;
      final title = actMap['title'] as String? ??
          actMap['location'] as String? ??
          'plan.activity_default'.tr();
      final startTime = actMap['start_time'] as String? ?? '09:00';
      final coordsStr = actMap['coordinates'] as String? ?? '';
      double lat = 0, lon = 0;
      if (coordsStr.isNotEmpty) {
        final parts = coordsStr.split(',');
        if (parts.length >= 2) {
          lat = double.tryParse(parts[0].trim()) ?? 0;
          lon = double.tryParse(parts[1].trim()) ?? 0;
        }
      }
      final dateTime = DateTime.tryParse('$dateStr $startTime') ??
          DateTime.tryParse(dateStr) ??
          DateTime.now();
      final activityType = mapActivityType(actMap['activity_type'] as String?);
      final newActivity = PlanActivityModel(
        id: '',
        planId: planId,
        name: title,
        type: activityType,
        time: dateTime,
        latitude: lat,
        longitude: lon,
        addressText: actMap['address'] as String? ?? actMap['location'] as String?,
      );
      await repo.saveActivity(ownerId, planId, newActivity);
    }
  }
}

typedef AgentEditResult = ({
  bool success,
  String? error,
  bool isAskUser,
  List<Map<String, dynamic>> choices,
});

Future<AgentEditResult> applyAgentEditWithCommand(
  String command,
  ITravelAgentService travelAgentService,
  IUserRepository userRepository,
  IPlanRepository planRepository,
  PlanModel plan,
  List<PlanActivityModel> activities,
  String? effectiveOwnerId,
  void Function() onSuccess, {
  List<Map<String, String>> conversationHistory = const [],
}) async {
  try {
    final currentPlan = buildCurrentPlanForAgent(plan, activities);
    final result = await travelAgentService.editPlan(
      command: command,
      tripId: plan.id,
      conversationHistory: conversationHistory,
      currentPlan: currentPlan,
    );
    return _applyAgentEditResult(
      result: result,
      userRepository: userRepository,
      planRepository: planRepository,
      plan: plan,
      activities: activities,
      effectiveOwnerId: effectiveOwnerId,
      onSuccess: onSuccess,
    );
  } catch (e) {
    return (
      success: false,
      error: e.toString(),
      isAskUser: false,
      choices: <Map<String, dynamic>>[],
    );
  }
}

Future<AgentEditResult> _applyAgentEditResult({
  required EditPlanResult result,
  required IUserRepository userRepository,
  required IPlanRepository planRepository,
  required PlanModel plan,
  required List<PlanActivityModel> activities,
  required String? effectiveOwnerId,
  required void Function() onSuccess,
}) async {
  if (result.success) {
    final newPlan = result.newPlan;
    if (newPlan == null) {
      return (
        success: false,
        error: 'plan.no_new_plan_data'.tr(),
        isAskUser: false,
        choices: <Map<String, dynamic>>[],
      );
    }
    final user = await userRepository.getCurrentUser();
    final ownerId = effectiveOwnerId ?? user?.uid;
    if (ownerId == null || ownerId.isEmpty) {
      return (
        success: false,
        error: 'plan.not_logged_in'.tr(),
        isAskUser: false,
        choices: <Map<String, dynamic>>[],
      );
    }
    await applyAgentPlanToRepository(
      planRepository,
      ownerId,
      plan.id,
      activities,
      newPlan,
    );
    onSuccess();
    return (
      success: true,
      error: null,
      isAskUser: false,
      choices: <Map<String, dynamic>>[],
    );
  }
  if (result.isAskUser) {
    final msg = result.askUserQuestions.isNotEmpty
        ? '${result.message ?? ''}\n\n${result.askUserQuestions.join('\n')}'
        : (result.message ?? '');
    return (
      success: false,
      error: msg,
      isAskUser: true,
      choices: List<Map<String, dynamic>>.from(result.askUserChoices),
    );
  }
  return (
    success: false,
    error: result.error ?? result.message,
    isAskUser: false,
    choices: <Map<String, dynamic>>[],
  );
}
