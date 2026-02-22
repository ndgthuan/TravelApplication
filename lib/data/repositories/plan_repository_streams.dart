import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/data/repositories/plan_repository_queries.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';

const _presenceStaleSeconds = 60;

String _presenceRoomId(String ownerId, String planId) =>
    '${ownerId}_$planId'.replaceAll(RegExp(r'[/\\]'), '_');

CollectionReference _presenceViewersRef(
    FirebaseFirestore firestore, String ownerId, String planId) {
  return firestore
      .collection('plan_presence')
      .doc(_presenceRoomId(ownerId, planId))
      .collection('viewers');
}

Stream<PlanModel?> streamPlan(FirebaseFirestore firestore, String? ownerId,
    String planId) {
  if (ownerId == null || ownerId.isEmpty || planId.isEmpty) {
    return Stream.value(null);
  }
  return planCreatedRef(firestore, ownerId).doc(planId).snapshots().map((doc) {
    if (!doc.exists || doc.data() == null) return null;
    final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
    data['id'] = doc.id;
    return PlanModel.fromJson(data).copyWith(ownerId: ownerId);
  });
}

Stream<List<PlanActivityModel>> streamActivities(
    FirebaseFirestore firestore, String? ownerId, String planId) {
  if (ownerId == null || ownerId.isEmpty || planId.isEmpty) {
    return Stream.value([]);
  }
  return activityCreatedRef(firestore, ownerId, planId)
      .orderBy('time')
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final raw = doc.data();
            final data = raw is Map<String, dynamic>
                ? Map<String, dynamic>.from(raw)
                : <String, dynamic>{};
            data['id'] = doc.id;
            data['planId'] = planId;
            return PlanActivityModel.fromJson(data);
          }).toList());
}

Stream<List<({String userId, String displayName})>> streamViewers(
    FirebaseFirestore firestore, String ownerId, String planId) {
  if (ownerId.isEmpty || planId.isEmpty) return Stream.value([]);
  return _presenceViewersRef(firestore, ownerId, planId).snapshots().map((snap) {
    final now = DateTime.now();
    return snap.docs
        .where((doc) {
          final raw = doc.data();
          final data = raw is Map<String, dynamic> ? raw : null;
          if (data == null) return true;
          final lastSeen = data['lastSeen'];
          if (lastSeen == null) return true;
          final t = lastSeen is DateTime
              ? lastSeen
              : (lastSeen as Timestamp).toDate();
          return now.difference(t).inSeconds <= _presenceStaleSeconds;
        })
        .map((doc) {
          final raw = doc.data();
          final data =
              raw is Map<String, dynamic> ? raw : <String, dynamic>{};
          return (
            userId: doc.id,
            displayName: data['displayName'] as String? ?? doc.id,
          );
        })
        .toList();
  });
}

Future<void> setPresence(
  FirebaseFirestore firestore,
  String ownerId,
  String planId,
  String userId,
  String displayName,
) async {
  if (ownerId.isEmpty || planId.isEmpty || userId.isEmpty) return;
  await _presenceViewersRef(firestore, ownerId, planId).doc(userId).set({
    'displayName': displayName,
    'lastSeen': FieldValue.serverTimestamp(),
  });
}

Future<void> removePresence(
  FirebaseFirestore firestore,
  String ownerId,
  String planId,
  String userId,
) async {
  if (ownerId.isEmpty || planId.isEmpty || userId.isEmpty) return;
  await _presenceViewersRef(firestore, ownerId, planId).doc(userId).delete();
}
