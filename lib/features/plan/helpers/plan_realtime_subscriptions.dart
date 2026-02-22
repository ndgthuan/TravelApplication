import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';

class PlanRealtimeSubs {
  PlanRealtimeSubs(
    this.planSub,
    this.activitiesSub,
    this.presenceTimer,
    this.viewersSub,
    this.authSub,
  );
  final StreamSubscription<PlanModel?> planSub;
  final StreamSubscription<List<PlanActivityModel>> activitiesSub;
  final Timer presenceTimer;
  final StreamSubscription<List<({String userId, String displayName})>> viewersSub;
  final StreamSubscription<User?> authSub;
}

Future<PlanRealtimeSubs> subscribePlanRealtime({
  required IPlanRepository repo,
  required String ownerId,
  required String planId,
  required String userUid,
  required String userDisplayName,
  required void Function(PlanModel? p) onPlan,
  required void Function(List<PlanActivityModel>) onActivities,
  required void Function(List<({String userId, String displayName})>) onViewers,
  required void Function() onError,
  required void Function() onUserLogout,
}) async {
  await repo.setPresence(ownerId, planId, userUid, userDisplayName);
  final planSub =
      repo.streamPlan(ownerId, planId).listen(onPlan, onError: (_) => onError());
  final activitiesSub = repo
      .streamActivities(ownerId, planId)
      .listen(onActivities, onError: (_) => onError());
  final presenceTimer = Timer.periodic(const Duration(seconds: 25), (_) {
    repo.setPresence(ownerId, planId, userUid, userDisplayName);
  });
  final viewersSub = repo
      .streamViewers(ownerId, planId)
      .listen(onViewers, onError: (_) => onError());
  final authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) onUserLogout();
  });
  return PlanRealtimeSubs(planSub, activitiesSub, presenceTimer, viewersSub, authSub);
}
