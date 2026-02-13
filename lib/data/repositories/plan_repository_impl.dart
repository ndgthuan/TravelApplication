// Tạo một collection tên plan_created để lưu các plan đã tạo ra
import 'package:cloud_firestore/cloud_firestore.dart';
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
}
