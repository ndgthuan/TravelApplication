import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/data/repositories/plan_repository_queries.dart';
import 'package:travel_app/data/repositories/plan_repository_streams.dart'
    as plan_repository_streams;
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/models/plan_invite_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';

class PlanRepositoryImpl implements IPlanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _planInvitesCollection = 'plan_invites';
  static const _planSharedCollection = 'plan_shared';

  CollectionReference _planSharedRef(String? userId) {
    return _firestore
        .collection('users')
        .doc(userId ?? '')
        .collection(_planSharedCollection);
  }

  bool _isOngoing(PlanModel p, DateTime now, DateTime startOfToday) {
    return !p.startDate.isAfter(now) && !p.endDate.isBefore(startOfToday);
  }

  bool _isUpcoming(PlanModel p, DateTime now) => p.startDate.isAfter(now);
  bool _isPast(PlanModel p, DateTime startOfToday) =>
      p.endDate.isBefore(startOfToday);

  Future<List<PlanModel>> _mergeWithSharedPlans(
    String userId,
    List<PlanModel> owned,
    bool Function(PlanModel p) filter,
  ) async {
    final refs = await getSharedPlanRefs(userId);
    final shared = <PlanModel>[];
    for (final ref in refs) {
      final p = await getPlan(ref.ownerId, ref.planId);
      if (p != null && filter(p)) shared.add(p.copyWith(ownerId: ref.ownerId));
    }
    final seen = <String>{};
    final result = <PlanModel>[];
    for (final p in [...owned, ...shared]) {
      final key = '${p.ownerId ?? userId}_${p.id}';
      if (seen.contains(key)) continue;
      seen.add(key);
      result.add(p);
    }
    return result;
  }
  @override
  Future<List<PlanModel>> getOngoingPlans(String? userId) async {
    if (userId == null || userId.isEmpty) return [];
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final owned = await getOngoingPlansOwned(_firestore, userId);
    return _mergeWithSharedPlans(
        userId, owned, (p) => _isOngoing(p, now, startOfToday)    );
  }
  @override
  Future<List<PlanModel>> getUpcomingPlans(String? userId) async {
    if (userId == null || userId.isEmpty) return [];
    final now = DateTime.now();
    final owned = await getUpcomingPlansOwned(_firestore, userId);
    final merged = await _mergeWithSharedPlans(
        userId, owned, (p) => _isUpcoming(p, now));
    merged.sort((a, b) => a.startDate.compareTo(b.startDate));
    return merged;
  }
  @override
  Future<List<PlanModel>> getPastPlans(String? userId) async {
    if (userId == null || userId.isEmpty) return [];
    final startOfToday =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final owned = await getPastPlansOwned(_firestore, userId);
    final merged =
        await _mergeWithSharedPlans(userId, owned, (p) => _isPast(p, startOfToday));
    merged.sort((a, b) => b.endDate.compareTo(a.endDate));
    return merged;
  }
  @override
  Future<List<PlanModel>> getAllPlans(String? userId) async {
    if (userId == null || userId.isEmpty) return [];
    final owned = await getAllPlansOwned(_firestore, userId);
    final merged = await _mergeWithSharedPlans(userId, owned, (_) => true);
    merged.sort((a, b) => a.startDate.compareTo(b.startDate));
    return merged;
  }
  @override
  Future<PlanModel?> getPlan(String? userId, String planId) async {
    return getPlanOwned(_firestore, userId, planId);
  }
  @override
  Future<PlanModel> createPlan(String? userId, PlanModel plan) async {
    if (userId == null || userId.isEmpty) {
      throw StateError('userId required to create plan');
    }
    final ref = await planCreatedRef(_firestore, userId).add(plan.toJson());
    return plan.copyWith(id: ref.id);
  }
  @override
  Future<bool> updatePlan(String? userId, PlanModel plan) async {
    if (userId == null || userId.isEmpty || plan.id.isEmpty) return false;
    final ref = planCreatedRef(_firestore, userId).doc(plan.id);
    try {
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final snapData = snap.data() as Map<String, dynamic>?;
        if (!snap.exists || snapData == null) {
          throw StateError('plan_not_found');
        }
        final currentVersion = (snapData['version'] as num?)?.toInt() ?? 1;
        if (currentVersion != plan.version) {
          throw StateError('version_conflict');
        }
        final data = Map<String, dynamic>.from(plan.toJson());
        data.remove('id');
        data['version'] = plan.version + 1;
        tx.set(ref, data, SetOptions(merge: true));
      });
      return true;
    } on StateError catch (e) {
      if (e.message == 'version_conflict') return false;
      rethrow;
    }
  }
  @override
  Future<void> deletePlan(String? userId, String planId) async {
    if (userId == null || userId.isEmpty) return;
    final activityRef = activityCreatedRef(_firestore, userId, planId);
    final snapshot = await activityRef.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    if (snapshot.docs.isNotEmpty) await batch.commit();
    await planCreatedRef(_firestore, userId).doc(planId).delete();
  }
  @override
  Future<PlanActivityModel> saveActivity(
    String? userId,
    String planId,
    PlanActivityModel activity,
  ) async {
    if (userId == null || userId.isEmpty) {
      throw StateError('userId required to save activity');
    }
    final data = activity.toJson();
    data.remove('id');
    final ref = await activityCreatedRef(_firestore, userId, planId).add(data);
    return PlanActivityModel(
      id: ref.id,
      planId: planId,
      name: activity.name,
      type: activity.type,
      time: activity.time,
      latitude: activity.latitude,
      longitude: activity.longitude,
      addressText: activity.addressText,
      isCheckedIn: activity.isCheckedIn,
    );
  }
  @override
  Future<PlanActivityModel> updateActivity(
    String? userId,
    String planId,
    PlanActivityModel activity,
  ) async {
    if (userId == null || userId.isEmpty) {
      throw StateError('userId required to update activity');
    }
    if (activity.id.isEmpty) {
      throw StateError('activity.id required to update');
    }
    final data = activity.toJson();
    data.remove('id');
    await activityCreatedRef(_firestore, userId, planId).doc(activity.id).set(data);
    return activity;
  }
  @override
  Future<void> deleteActivity(
    String? userId,
    String planId,
    String activityId,
  ) async {
    if (userId == null || userId.isEmpty) return;
    await activityCreatedRef(_firestore, userId, planId).doc(activityId).delete();
  }

  @override
  Future<List<PlanActivityModel>> getActivities(
    String? userId,
    String planId,
  ) async {
    if (userId == null || userId.isEmpty) return [];
    final snapshot = await activityCreatedRef(_firestore, userId, planId)
        .orderBy('time')
        .get();
    return snapshot.docs.map((doc) {
      final raw = doc.data();
      final data = raw is Map<String, dynamic>
          ? Map<String, dynamic>.from(raw)
          : <String, dynamic>{};
      data['id'] = doc.id;
      data['planId'] = planId;
      return PlanActivityModel.fromJson(data);
    }).toList();
  }

  @override
  Future<void> createInvite(PlanInviteModel invite) async {
    await _firestore.collection(_planInvitesCollection).add(invite.toJson());
  }

  @override
  Future<List<PlanInviteModel>> getPendingInvitesForUser(
    String toUserId,
  ) async {
    if (toUserId.isEmpty) return [];
    final snapshot = await _firestore
        .collection(_planInvitesCollection)
        .where('toUserId', isEqualTo: toUserId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return PlanInviteModel.fromJson(data, doc.id);
    }).toList();
  }

  @override
  Future<void> updateInviteStatus(String inviteId, String status) async {
    if (inviteId.isEmpty) return;
    await _firestore.collection(_planInvitesCollection).doc(inviteId).update({
      'status': status,
    });
  }

  @override
  Future<void> saveSharedPlanRef(
    String userId,
    String ownerId,
    String planId,
  ) async {
    if (userId.isEmpty || ownerId.isEmpty || planId.isEmpty) return;
    await _planSharedRef(userId).doc(planId).set({'ownerId': ownerId});
  }

  @override
  Future<List<SharedPlanRef>> getSharedPlanRefs(String userId) async {
    if (userId.isEmpty) return [];
    final snapshot = await _planSharedRef(userId).get();
    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          final ownerId = data?['ownerId'] as String? ?? '';
          return (ownerId: ownerId, planId: doc.id);
        })
        .where((ref) => ref.ownerId.isNotEmpty)
        .toList();
  }

  @override
  Stream<PlanModel?> streamPlan(String? ownerId, String planId) =>
      plan_repository_streams.streamPlan(_firestore, ownerId, planId);

  @override
  Stream<List<PlanActivityModel>> streamActivities(
          String? ownerId, String planId) =>
      plan_repository_streams.streamActivities(
          _firestore, ownerId, planId);

  @override
  Future<void> setPresence(
    String ownerId,
    String planId,
    String userId,
    String displayName,
  ) =>
      plan_repository_streams.setPresence(
          _firestore, ownerId, planId, userId, displayName);

  @override
  Future<void> removePresence(
          String ownerId, String planId, String userId) =>
      plan_repository_streams.removePresence(
          _firestore, ownerId, planId, userId);

  @override
  Stream<List<({String userId, String displayName})>> streamViewers(
          String ownerId, String planId) =>
      plan_repository_streams.streamViewers(_firestore, ownerId, planId);
}
