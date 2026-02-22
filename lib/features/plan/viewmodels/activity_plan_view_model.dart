import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';
import 'package:travel_app/domain/services/i_route_service.dart';
import 'package:travel_app/domain/services/i_travel_agent_service.dart';
import 'package:travel_app/features/plan/helpers/activity_plan_agent_helpers.dart';
import 'package:travel_app/features/plan/helpers/plan_realtime_subscriptions.dart';

class ActivityPlanViewModel extends ChangeNotifier {
  final IPlanRepository _planRepository;
  final IUserRepository _userRepository;
  final IRouteService _routeService;
  final ITravelAgentService _travelAgentService;
  PlanModel _plan;

  bool _disposed = false;
  String? _effectiveOwnerId;
  StreamSubscription<PlanModel?>? _planSub;
  StreamSubscription<List<PlanActivityModel>>? _activitiesSub;
  StreamSubscription<List<({String userId, String displayName})>>? _viewersSub;
  StreamSubscription<User?>? _authSub;
  Timer? _presenceTimer;
  final _onRemoteUpdateController = StreamController<void>.broadcast();
  DateTime? _lastLocalWriteAt;
  int _planEmissionCount = 0;
  int _activitiesEmissionCount = 0;
  DateTime? _lastRemoteHintAt;

  List<String> _viewerNames = [];

  Stream<void> get onRemoteUpdate => _onRemoteUpdateController.stream;
  List<String> get viewerNames => List.unmodifiable(_viewerNames);

  void _cancelPlanStreams() {
    _planSub?.cancel();
    _planSub = null;
    _activitiesSub?.cancel();
    _activitiesSub = null;
    _viewersSub?.cancel();
    _viewersSub = null;
    _presenceTimer?.cancel();
    _presenceTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _authSub?.cancel();
    _cancelPlanStreams();
    if (_effectiveOwnerId != null && _plan.id.isNotEmpty) {
      _userRepository.getCurrentUser().then((user) {
        if (user != null) {
          _planRepository.removePresence(_effectiveOwnerId!, _plan.id, user.uid);
        }
      });
    }
    _onRemoteUpdateController.close();
    super.dispose();
  }

  bool _isRemoteUpdate() {
    if (_lastLocalWriteAt == null) return true;
    return DateTime.now().difference(_lastLocalWriteAt!).inMilliseconds > 2000;
  }

  void _maybeEmitRemoteHint() {
    if (!_isRemoteUpdate()) {
      return;
    }
    if (_lastRemoteHintAt != null &&
        DateTime.now().difference(_lastRemoteHintAt!).inSeconds < 3) {
      return;
    }
    _lastRemoteHintAt = DateTime.now();
    if (!_onRemoteUpdateController.isClosed) _onRemoteUpdateController.add(null);
  }

  void _notifyIfNotDisposed() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  ActivityPlanViewModel(
    this._planRepository,
    this._userRepository,
    this._routeService,
    this._travelAgentService,
    PlanModel plan,
  ) : _plan = plan;

  PlanModel get plan => _plan;
  List<PlanActivityModel> _activities = [];
  List<LatLng> _routePoints = [];

  List<int> _routeOrderIndices = [];
  List<List<LatLng>>? _routeSegments;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;
  String? _currentUserRole;

  List<PlanActivityModel> get activities => _activities;
  String? get currentUserRole => _currentUserRole;
  List<LatLng> get routePoints => _routePoints;
  List<List<LatLng>>? get routeSegments => _routeSegments;
  int get currentIndex => _currentIndex;
  int get mapCurrentIndex {
    if (_routePoints.isEmpty) return 0;
    if (_currentIndex >= _activities.length) return _routePoints.length;
    final idx = _routeOrderIndices.indexOf(_currentIndex);
    return idx >= 0 ? idx : _currentIndex.clamp(0, _routePoints.length - 1);
  }

  List<bool> get checkedInByRoutePoint {
    return List.generate(
      _routeOrderIndices.length,
      (r) => _activities[_routeOrderIndices[r]].isCheckedIn,
    );
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  void updatePlan(PlanModel newPlan) {
    _plan = newPlan;
    _notifyIfNotDisposed();
  }

  String? get effectiveOwnerId => _effectiveOwnerId;
  Future<void> loadPlan() async {
    _isLoading = true;
    _error = null;
    _notifyIfNotDisposed();

    try {
      final user = await _userRepository.getCurrentUser();
      final userId = user?.uid;
      if (userId == null || userId.isEmpty) {
        _error = 'plan.not_logged_in'.tr();
        _isLoading = false;
        _notifyIfNotDisposed();
        return;
      }
      _effectiveOwnerId = _plan.ownerId ?? userId;
      final currentUser = user!;
      _currentUserRole = currentUser.email.isNotEmpty ? _plan.getRoleForEmail(currentUser.email) : null;

      await _planSub?.cancel();
      await _activitiesSub?.cancel();
      _authSub?.cancel();

      final subs = await subscribePlanRealtime(
        repo: _planRepository,
        ownerId: _effectiveOwnerId!,
        planId: _plan.id,
        userUid: currentUser.uid,
        userDisplayName:
            currentUser.name.isNotEmpty ? currentUser.name : currentUser.email,
        onPlan: (p) {
          if (_disposed || p == null) return;
          _plan = p;
          _currentUserRole = currentUser.email.isNotEmpty
              ? _plan.getRoleForEmail(currentUser.email)
              : null;
          if (_planEmissionCount++ > 0) _maybeEmitRemoteHint();
          _notifyIfNotDisposed();
        },
        onActivities: (list) {
          if (_disposed) return;
          _applyActivities(list);
          if (_activitiesEmissionCount++ > 0) _maybeEmitRemoteHint();
          _notifyIfNotDisposed();
        },
        onViewers: (list) {
          if (_disposed) return;
          _viewerNames =
              list.map((e) => e.displayName).where((n) => n.isNotEmpty).toList();
          _notifyIfNotDisposed();
        },
        onError: _cancelPlanStreams,
        onUserLogout: () {
          if (!_disposed) _cancelPlanStreams();
        },
      );
      _planSub = subs.planSub;
      _activitiesSub = subs.activitiesSub;
      _presenceTimer = subs.presenceTimer;
      _viewersSub = subs.viewersSub;
      _authSub = subs.authSub;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notifyIfNotDisposed();
    }
  }

  void _applyActivities(List<PlanActivityModel> list) {
    _activities = List.from(list);
    _activities.sort((a, b) => a.time.compareTo(b.time));

    final pointsInTimeOrder = _activities
        .map((a) => LatLng(a.latitude, a.longitude))
        .where((p) => p.latitude.isFinite && p.longitude.isFinite)
        .toList();

    _currentIndex = _activities.length;
    for (var i = 0; i < _activities.length; i++) {
      if (!_activities[i].isCheckedIn) {
        _currentIndex = i;
        break;
      }
    }

    _routePoints = pointsInTimeOrder;
    _routeOrderIndices = List.generate(pointsInTimeOrder.length, (i) => i);
    if (pointsInTimeOrder.length >= 2) {
      _routeService.buildSegments(pointsInTimeOrder).then((segments) {
        if (_disposed) return;
        _routeSegments = segments;
        _notifyIfNotDisposed();
      });
    } else {
      _routeSegments = null;
    }
    _notifyIfNotDisposed();
  }
  Future<void> checkIn() async {
    if (_activities.isEmpty) return;
    if (_currentIndex >= _activities.length) return;
    final ownerId = _effectiveOwnerId ?? (await _userRepository.getCurrentUser())?.uid;
    if (ownerId == null || ownerId.isEmpty) return;
    final activity = _activities[_currentIndex];
    final updated = await _planRepository.updateActivity(
      ownerId,
      _plan.id,
      activity.copyWith(isCheckedIn: true),
    );
    _activities[_currentIndex] = updated;
    var next = _currentIndex + 1;
    while (next < _activities.length && _activities[next].isCheckedIn) {
      next++;
    }
    _currentIndex = next;
    _lastLocalWriteAt = DateTime.now();
    _notifyIfNotDisposed();
  }
  Future<void> uncheckIn(PlanActivityModel activity) async {
    if (!activity.isCheckedIn) return;
    final ownerId = _effectiveOwnerId ?? (await _userRepository.getCurrentUser())?.uid;
    if (ownerId == null || ownerId.isEmpty) return;
    final updated = await _planRepository.updateActivity(
      ownerId,
      _plan.id,
      activity.copyWith(isCheckedIn: false),
    );
    final idx = _activities.indexWhere((a) => a.id == activity.id);
    if (idx >= 0) {
      _activities[idx] = updated;
      _currentIndex = idx;
      _lastLocalWriteAt = DateTime.now();
      _notifyIfNotDisposed();
    }
  }
  Future<AgentEditResult> applyAgentEdit(
    String command, {
    List<Map<String, String>> conversationHistory = const [],
  }) {
    return applyAgentEditWithCommand(
      command,
      _travelAgentService,
      _userRepository,
      _planRepository,
      _plan,
      _activities,
      _effectiveOwnerId,
      () => _lastLocalWriteAt = DateTime.now(),
      conversationHistory: conversationHistory,
    );
  }
  Future<bool> deleteActivity(String activityId) async {
    if (activityId.isEmpty) return false;
    try {
      final ownerId = _effectiveOwnerId ?? (await _userRepository.getCurrentUser())?.uid;
      if (ownerId == null || ownerId.isEmpty) return false;
      await _planRepository.deleteActivity(ownerId, _plan.id, activityId);
      _lastLocalWriteAt = DateTime.now();
      return true;
    } catch (_) {
      return false;
    }
  }
}
