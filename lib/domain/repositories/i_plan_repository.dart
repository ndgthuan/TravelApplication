import 'package:travel_app/domain/models/plan_model.dart';

abstract class IPlanRepository {
  Future<List<PlanModel>> getOngoingPlans(String? userId);
  Future<List<PlanModel>> getUpcomingPlans(String? userId);
  Future<List<PlanModel>> getAllPlans(String? userId);
  Future<PlanModel> createPlan(String? userId, PlanModel plan);
  Future<void> deletePlan(String? userId, String planId);
}
