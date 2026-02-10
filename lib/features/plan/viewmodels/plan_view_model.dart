import 'package:flutter/foundation.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';

class PlanViewModel extends ChangeNotifier {
  final IPlanRepository _planRepository;

  PlanViewModel(this._planRepository);

  PlanModel? _ongoingPlan;
  List<PlanModel> _upcomingPlans = [];
  bool _isLoading = false;
  String? _error;

  PlanModel? get ongoingPlan => _ongoingPlan;
  List<PlanModel> get upcomingPlans => _upcomingPlans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlans(String? userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _ongoingPlan = await _planRepository.getOngoingPlan(userId);
      _upcomingPlans = await _planRepository.getUpcomingPlans(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlanModel?> createPlan(String? userId, PlanModel plan) async {
    try {
      final created = await _planRepository.createPlan(userId, plan);
      await loadPlans(userId);
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deletePlan(String? userId, String planId) async {
    try {
      await _planRepository.deletePlan(userId, planId);
      await loadPlans(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
