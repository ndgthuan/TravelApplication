import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';
import 'package:travel_app/domain/services/i_geocoding_service.dart';

// Viewmodel cho phần thêm đến để gọi thông qua backend không trực tiếp trên UI
// Quản lý state form và gọi repository lưu activity vào plan_created/{planId}/activity_created.
class PlanSectionViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final IPlanRepository _planRepository;
  final IUserRepository _userRepository;
  final IGeocodingService _geocodingService;

  PlanSectionViewModel(
    this._planRepository,
    this._userRepository,
    this._geocodingService,
  );

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  String? _planId;
  String? _destination;
  String? _countryCode;
  DateTime? _planStartDate;
  DateTime? _planEndDate;
  String _activityType = 'sightseeing';
  LatLng _pinPosition = const LatLng(21.0285, 105.8542);
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 30);
  DateTime _date = DateTime(2023, 10, 12);
  bool _isSaving = false;
  bool _isSearchingLocation = false;
  List<Map<String, dynamic>> _placeSearchResults = [];
  String? _errorMessage;

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  String? get planId => _planId;
  String? get destination => _destination;
  String? get countryCode => _countryCode;
  DateTime? get planStartDate => _planStartDate;
  DateTime? get planEndDate => _planEndDate;
  String get activityType => _activityType;
  LatLng get pinPosition => _pinPosition;
  TimeOfDay get time => _time;
  DateTime get date => _date;
  bool get isSaving => _isSaving;
  bool get isSearchingLocation => _isSearchingLocation;
  List<Map<String, dynamic>> get placeSearchResults => _placeSearchResults;
  String? get errorMessage => _errorMessage;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  void setPlanId(String? value) {
    if (_planId == value) return;
    _planId = value;
    notifyListeners();
  }

  // Tự nhận diện mã quốc gia dựa trên các ký tự đánh trong điểm đến
  void setDestination(String? value) {
    if (_destination == value) return;
    _destination = value?.trim().isEmpty == true ? null : value?.trim();
    _countryCode = null;
    notifyListeners();
    if (_destination == null || _destination!.isEmpty) return;
    _geocodingService.getCountryCodeForPlace(_destination!).then((code) {
      _countryCode = code;
      notifyListeners();
    });
  }

  // Khoảng thời gian của plan
  void setPlanDateRange(DateTime? start, DateTime? end) {
    if (_planStartDate == start && _planEndDate == end) return;
    _planStartDate = start;
    _planEndDate = end;
    if (start != null && end != null) {
      _date = _clampDateToPlanRange(_date, start, end);
    } else if (start != null) {
      _date = DateTime(start.year, start.month, start.day);
    }
    notifyListeners();
  }

  void setActivityType(String value) {
    if (_activityType == value) return;
    _activityType = value;
    notifyListeners();
  }

  void setPinPosition(LatLng value) {
    if (_pinPosition == value) return;
    _pinPosition = value;
    notifyListeners();
  }

  void setTime(TimeOfDay value) {
    if (_time == value) return;
    _time = value;
    notifyListeners();
  }

  void setDate(DateTime value) {
    if (_date == value) return;
    _date = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  // Tìm địa điểm cụ thể (Nominatim)
  Future<void> searchPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      _placeSearchResults = [];
      notifyListeners();
      return;
    }
    _isSearchingLocation = true;
    _placeSearchResults = [];
    notifyListeners();
    try {
      _placeSearchResults = await _geocodingService.searchPlaces(
        q,
        countryCodes: _countryCode,
      );
    } catch (_) {
      _placeSearchResults = [];
    } finally {
      _isSearchingLocation = false;
      notifyListeners();
    }
  }

  // Chọn một kết quả từ search để cập nhật pin, xoá, list trả về toạ độ và tên địa chỉ
  ({LatLng latLng, String displayName})? selectPlaceResult(int index) {
    if (index < 0 || index >= _placeSearchResults.length) return null;
    final item = _placeSearchResults[index];
    final lat = (item['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (item['longitude'] as num?)?.toDouble() ?? 0.0;
    final point = LatLng(lat, lng);
    final displayName = item['displayName'] as String? ?? '';
    _pinPosition = point;
    _placeSearchResults = [];
    notifyListeners();
    return (latLng: point, displayName: displayName);
  }

  // Validate và lưu activity, trả về PlanActivityModel đã lưu hoặc null nếu lỗi
  Future<PlanActivityModel?> saveActivity(
    String activityName,
    String customActivityTypeText,
    String addressText,
  ) async {
    final name = activityName.trim();
    if (name.isEmpty) {
      _errorMessage = 'Vui lòng nhập tên hoạt động';
      notifyListeners();
      return null;
    }
    if (_activityType == 'other' && customActivityTypeText.trim().isEmpty) {
      _errorMessage = 'Khi chọn Khác, vui lòng nhập loại hoạt động';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      final userId = user?.uid;
      if (userId == null || userId.isEmpty) {
        _errorMessage = 'Chưa đăng nhập';
        return null;
      }

      final planId = _planId ?? '';
      final dateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );
      final typeValue = _resolveActivityType(customActivityTypeText);

      final activity = PlanActivityModel(
        id: '',
        planId: planId,
        name: name,
        type: typeValue.isEmpty ? 'other' : typeValue,
        time: dateTime,
        latitude: _pinPosition.latitude,
        longitude: _pinPosition.longitude,
        addressText: addressText.trim().isEmpty ? null : addressText.trim(),
      );

      final saved = await _planRepository.saveActivity(
        userId,
        planId,
        activity,
      );
      _isSaving = false;
      notifyListeners();
      return saved;
    } catch (e) {
      _errorMessage = e.toString();
      _isSaving = false;
      notifyListeners();
      return null;
    }
  }

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//
  DateTime _clampDateToPlanRange(DateTime date, DateTime start, DateTime end) {
    final d = DateTime(date.year, date.month, date.day);
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    if (d.isBefore(startDate)) return startDate;
    if (d.isAfter(endDate)) return endDate;
    return d;
  }

  // Trả về giá trị type để lưu, nếu loại "other" thì dùng customActivityTypeText, không thì dùng _activityType.
  String _resolveActivityType(String customActivityTypeText) {
    if (_activityType == 'other' && customActivityTypeText.trim().isNotEmpty) {
      return customActivityTypeText.trim();
    }
    return _activityType;
  }
}
