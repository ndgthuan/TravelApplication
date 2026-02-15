// Tạo một collection tên plan_created để lưu các plan đã tạo ra
// Dưới mỗi plan: collection activity_created để lưu các activity của plan đó
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';

class PlanRepositoryImpl implements IPlanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _planCreatedRef(String? userId) {
    return _firestore
        .collection('users')
        .doc(userId ?? '')
        .collection('plan_created');
  }

  // users/{userId}/plan_created/{planId}/activity_created
  CollectionReference _activityCreatedRef(String? userId, String planId) {
    return _planCreatedRef(userId).doc(planId).collection('activity_created');
  }

  @override
  Future<List<PlanModel>> getOngoingPlans(String? userId) async {
    if (userId == null || userId.isEmpty) return [];
    final now = DateTime.now();
    final snapshot = await _planCreatedRef(userId)
        .where('startDate', isLessThanOrEqualTo: now.toIso8601String())
        .where('endDate', isGreaterThanOrEqualTo: now.toIso8601String())
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return PlanModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<PlanModel>> getUpcomingPlans(String? userId) async {
    if (userId == null || userId.isEmpty) return [];
    final now = DateTime.now();
    final snapshot = await _planCreatedRef(userId)
        .where('startDate', isGreaterThan: now.toIso8601String())
        .orderBy('startDate')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return PlanModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<PlanModel>> getAllPlans(String? userId) async {
    if (userId == null || userId.isEmpty) return [];
    final snapshot = await _planCreatedRef(userId).orderBy('startDate').get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return PlanModel.fromJson(data);
    }).toList();
  }

  @override
  Future<PlanModel> createPlan(String? userId, PlanModel plan) async {
    final ref = await _planCreatedRef(userId).add(plan.toJson());
    return plan.copyWith(id: ref.id);
  }

  @override
  Future<void> deletePlan(String? userId, String planId) async {
    await _planCreatedRef(userId).doc(planId).delete();
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
    data.remove('id'); // id do Firestore gán qua doc ref
    final ref = await _activityCreatedRef(userId, planId).add(data);
    return PlanActivityModel(
      id: ref.id,
      planId: planId,
      name: activity.name,
      type: activity.type,
      time: activity.time,
      latitude: activity.latitude,
      longitude: activity.longitude,
      addressText: activity.addressText,
    );
  }

  // Lấy các activity đã được tạo để gọi trong viewmodel
  @override
  Future<List<PlanActivityModel>> getActivities(
    String? userId,
    String planId,
  ) async {
    if (userId == null || userId.isEmpty) return [];
    final snapshot = await _activityCreatedRef(
      userId,
      planId,
    ).orderBy('time').get();
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
}
