import 'package:travel_app/domain/models/plan_model.dart';

abstract class IPlanRepository {
  Future<PlanModel?> getOngoingPlan(String? userId);
  Future<List<PlanModel>> getUpcomingPlans(String? userId);
  Future<PlanModel> createPlan(String? userId, PlanModel plan);
  Future<void> deletePlan(String? userId, String planId);
}
