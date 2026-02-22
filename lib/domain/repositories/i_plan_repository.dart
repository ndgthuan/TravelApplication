import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/models/plan_invite_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';

// Ref đến plan được share: load plan từ owner (realtime shared edit).
typedef SharedPlanRef = ({String ownerId, String planId});

abstract class IPlanRepository {
  Future<List<PlanModel>> getOngoingPlans(String? userId);
  Future<List<PlanModel>> getUpcomingPlans(String? userId);
  Future<List<PlanModel>> getPastPlans(String? userId);
  Future<List<PlanModel>> getAllPlans(String? userId);
  Future<PlanModel?> getPlan(String? userId, String planId);
  Future<PlanModel> createPlan(String? userId, PlanModel plan);
  // Optimistic locking: ghi chỉ thành công nếu version khớp; trả true/false.
  Future<bool> updatePlan(String? userId, PlanModel plan);
  Future<void> deletePlan(String? userId, String planId);

  Future<void> createInvite(PlanInviteModel invite);
  Future<List<PlanInviteModel>> getPendingInvitesForUser(String toUserId);
  Future<void> updateInviteStatus(String inviteId, String status);

  // Plan shared: user được mời không copy plan, chỉ lưu ref để đọc/ghi cùng doc với owner.
  Future<void> saveSharedPlanRef(String userId, String ownerId, String planId);
  Future<List<SharedPlanRef>> getSharedPlanRefs(String userId);

  // Realtime: stream plan và activities để nhiều người cùng edit thấy thay đổi ngay.
  Stream<PlanModel?> streamPlan(String? ownerId, String planId);
  Stream<List<PlanActivityModel>> streamActivities(String? ownerId, String planId);

  // Presence: ai đang xem plan. Gọi khi mở/đóng màn, timer refresh lastSeen.
  Future<void> setPresence(String ownerId, String planId, String userId, String displayName);
  Future<void> removePresence(String ownerId, String planId, String userId);
  Stream<List<({String userId, String displayName})>> streamViewers(String ownerId, String planId);

  // Collection: users/{userId}/plan_created/{planId}/activity_created
  Future<PlanActivityModel> saveActivity(
    String? userId,
    String planId,
    PlanActivityModel activity,
  );
  Future<PlanActivityModel> updateActivity(
    String? userId,
    String planId,
    PlanActivityModel activity,
  );
  Future<void> deleteActivity(
    String? userId,
    String planId,
    String activityId,
  );
  Future<List<PlanActivityModel>> getActivities(String? userId, String planId);
}
