import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/domain/models/plan_model.dart';

CollectionReference planCreatedRef(FirebaseFirestore firestore, String? userId) {
  return firestore
      .collection('users')
      .doc(userId ?? '')
      .collection('plan_created');
}

List<PlanModel> docsToPlanList(List<QueryDocumentSnapshot> docs) {
  return docs.map((doc) {
    final data =
        Map<String, dynamic>.from(doc.data() as Map<String, dynamic>? ?? {});
    data['id'] = doc.id;
    return PlanModel.fromJson(data);
  }).toList();
}

Future<List<PlanModel>> getOngoingPlansOwned(
    FirebaseFirestore firestore, String userId) async {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final snapshot = await planCreatedRef(firestore, userId)
      .where('startDate', isLessThanOrEqualTo: now.toIso8601String())
      .where('endDate', isGreaterThanOrEqualTo: startOfToday.toIso8601String())
      .get();
  return docsToPlanList(snapshot.docs);
}

Future<List<PlanModel>> getUpcomingPlansOwned(
    FirebaseFirestore firestore, String userId) async {
  final now = DateTime.now();
  final snapshot = await planCreatedRef(firestore, userId)
      .where('startDate', isGreaterThan: now.toIso8601String())
      .orderBy('startDate')
      .get();
  return docsToPlanList(snapshot.docs);
}

Future<List<PlanModel>> getPastPlansOwned(
    FirebaseFirestore firestore, String userId) async {
  final startOfToday =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final snapshot = await planCreatedRef(firestore, userId)
      .where('endDate', isLessThan: startOfToday.toIso8601String())
      .orderBy('endDate', descending: true)
      .get();
  return docsToPlanList(snapshot.docs);
}

Future<List<PlanModel>> getAllPlansOwned(
    FirebaseFirestore firestore, String userId) async {
  final snapshot =
      await planCreatedRef(firestore, userId).orderBy('startDate').get();
  return docsToPlanList(snapshot.docs);
}

Future<PlanModel?> getPlanOwned(
    FirebaseFirestore firestore, String? userId, String planId) async {
  if (userId == null || userId.isEmpty || planId.isEmpty) return null;
  try {
    final doc = await planCreatedRef(firestore, userId).doc(planId).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
    data['id'] = doc.id;
    return PlanModel.fromJson(data).copyWith(ownerId: userId);
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') return null;
    rethrow;
  }
}

CollectionReference activityCreatedRef(
    FirebaseFirestore firestore, String? userId, String planId) {
  return planCreatedRef(firestore, userId)
      .doc(planId)
      .collection('activity_created');
}
