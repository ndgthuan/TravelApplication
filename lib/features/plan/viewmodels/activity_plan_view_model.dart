import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';
import 'package:travel_app/domain/services/i_route_service.dart';

// ViewModel cho màn chi tiết chuyến đi dùng để thực hiện các logic sau UI
class ActivityPlanViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final IPlanRepository _planRepository;
  final IUserRepository _userRepository;
  final IRouteService _routeService;
  PlanModel _plan;

  ActivityPlanViewModel(
    this._planRepository,
    this._userRepository,
    this._routeService,
    PlanModel plan,
  ) : _plan = plan;

  PlanModel get plan => _plan;

  List<PlanActivityModel> _activities = [];
  List<LatLng> _routePoints = [];

  // Thứ tự theo thời gian của từng điểm trong route: _routeOrderIndices[i] = index trong _activities.
  List<int> _routeOrderIndices = [];
  List<List<LatLng>>? _routeSegments;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;

  List<PlanActivityModel> get activities => _activities;
  List<LatLng> get routePoints => _routePoints;
  List<List<LatLng>>? get routeSegments => _routeSegments;
  int get currentIndex => _currentIndex;

  // Index trên map (vị trí route của activity "current" - chưa check-in). Dùng để tô cam đoạn/điểm đang tới.
  int get mapCurrentIndex {
    if (_routePoints.isEmpty) return 0;
    if (_currentIndex >= _activities.length) return _routePoints.length;
    final idx = _routeOrderIndices.indexOf(_currentIndex);
    return idx >= 0 ? idx : _currentIndex.clamp(0, _routePoints.length - 1);
  }

  // Trạng thái check-in theo từng điểm trên route (theo thứ tự route = thứ tự thời gian).
  // Map layer dùng để tô màu xanh cho các điểm đã check-in.
  List<bool> get checkedInByRoutePoint {
    return List.generate(
      _routeOrderIndices.length,
      (r) => _activities[_routeOrderIndices[r]].isCheckedIn,
    );
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dùng để cập nhật plan khi thay đổi các giá trị mới trong lúc chỉnh sửa thông tin
  void updatePlan(PlanModel newPlan) {
    _plan = newPlan;
    notifyListeners();
  }

  // Load activities của plan
  Future<void> loadPlan() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      final userId = user?.uid;
      if (userId == null || userId.isEmpty) {
        _error = 'Chưa đăng nhập';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _activities = await _planRepository.getActivities(userId, _plan.id);
      _activities.sort((a, b) => a.time.compareTo(b.time));

      final pointsInTimeOrder = _activities
          .map((a) => LatLng(a.latitude, a.longitude))
          .where((p) => p.latitude.isFinite && p.longitude.isFinite)
          .toList();

      // Current = activity đầu tiên chưa check-in (theo model). Thêm/xóa activity không làm lệch trạng thái.
      _currentIndex = _activities.length;
      for (var i = 0; i < _activities.length; i++) {
        if (!_activities[i].isCheckedIn) {
          _currentIndex = i;
          break;
        }
      }

      if (pointsInTimeOrder.length >= 2) {
        _routePoints = pointsInTimeOrder;
        _routeOrderIndices = List.generate(pointsInTimeOrder.length, (i) => i);

        // Vẽ đường đi theo đúng thứ tự
        _routeSegments = await _routeService.buildSegments(pointsInTimeOrder);
      } else {
        _routePoints = pointsInTimeOrder;
        _routeOrderIndices = List.generate(pointsInTimeOrder.length, (i) => i);
        _routeSegments = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Khi bấm check in ngay thì trên firestore sẽ cập nhật giá trị checkin sẽ = true
  // Lúc này current sẽ nhảy từ vị trí này tới vị trí tiếp đó
  Future<void> checkIn() async {
    if (_activities.isEmpty) return;
    if (_currentIndex >= _activities.length) return;
    final user = await _userRepository.getCurrentUser();
    final userId = user?.uid;
    if (userId == null || userId.isEmpty) return;
    final activity = _activities[_currentIndex];
    final updated = await _planRepository.updateActivity(
      userId,
      _plan.id,
      activity.copyWith(isCheckedIn: true),
    );
    _activities[_currentIndex] = updated;
    var next = _currentIndex + 1;
    while (next < _activities.length && _activities[next].isCheckedIn) {
      next++;
    }
    _currentIndex = next;
    notifyListeners();
  }

  // Bỏ check-in tại activity trên firebase isCheckedIn = false
  // Lúc này checkin ngay sẽ nhảy về vị trí trước đó
  Future<void> uncheckIn(PlanActivityModel activity) async {
    if (!activity.isCheckedIn) return;
    final user = await _userRepository.getCurrentUser();
    final userId = user?.uid;
    if (userId == null || userId.isEmpty) return;
    final updated = await _planRepository.updateActivity(
      userId,
      _plan.id,
      activity.copyWith(isCheckedIn: false),
    );
    final idx = _activities.indexWhere((a) => a.id == activity.id);
    if (idx >= 0) {
      _activities[idx] = updated;
      _currentIndex = idx;
      notifyListeners();
    }
  }

  // Xoá activity và load lại plan sau khi xóa thành công
  Future<bool> deleteActivity(String activityId) async {
    if (activityId.isEmpty) return false;
    try {
      final user = await _userRepository.getCurrentUser();
      final userId = user?.uid;
      if (userId == null || userId.isEmpty) return false;
      await _planRepository.deleteActivity(userId, _plan.id, activityId);
      await loadPlan();
      return true;
    } catch (_) {
      return false;
    }
  }
}
