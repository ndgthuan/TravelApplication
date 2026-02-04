import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/domain/repositories/i_explore_repository.dart';
import 'package:travel_app/domain/models/destination_model.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';
import 'package:travel_app/domain/services/i_location_service.dart';

class ExploreViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final IExploreRepository _repository;
  final IUserRepository _userRepository;
  final ILocationService _locationService;

  ExploreViewModel(
    this._repository,
    this._userRepository,
    this._locationService,
  );

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  List<DestinationModel> _destinations = [];
  List<DestinationModel> _savedFromFirestore = [];
  List<String> _categories = [];
  String _selectedCategory = '';
  String _searchQuery = '';
  bool _isLoading = true;
  List<String> _cities = [];
  String _selectedCity = '';
  Set<String> _savedIds = {}; // Lưu danh sách ID đã save
  String? _errorMessage; // Thêm biến để kiểm tra lỗi
  double? _currentLocationLat;
  double? _currentLocationLng;

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  List<DestinationModel> get destinations => _destinations;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  List<String> get cities => _cities;
  String get selectedCity => _selectedCity;
  bool get isLoading => _isLoading;
  Set<String> get savedIds => _savedIds;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  double? get currentLocationLat => _currentLocationLat;
  double? get currentLocationLng => _currentLocationLng;
  bool get hasCurrentLocation =>
      _currentLocationLat != null &&
      _currentLocationLng != null &&
      _currentLocationLat!.isFinite &&
      _currentLocationLng!.isFinite;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//

  // Lấy vị trí hiện tại của thiết bị (cho Explore Map).
  Future<void> loadCurrentLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos != null) {
      _currentLocationLat = pos.latitude;
      _currentLocationLng = pos.longitude;
    } else {
      _currentLocationLat = null;
      _currentLocationLng = null;
    }
    notifyListeners();
  }

  // Cập nhật loadData
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await refreshSavedDestinations();
      _categories = await _repository.getCategories();
      _cities = await _repository.getCities();
      _destinations = await _repository.getDestinations();
    } catch (e) {
      _errorMessage = 'explore.load_error'.tr();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Lấy danh sách địa điểm đã save (dùng cho SaveScreen)
  List<DestinationModel> get savedDestinations {
    return _savedFromFirestore.where((d) {
      final matchSearch =
          _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery) ||
          d.city.toLowerCase().contains(_searchQuery);
      final matchCategory =
          _selectedCategory.isEmpty ||
          d.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchCity =
          _selectedCity.isEmpty ||
          d.city.toLowerCase() == _selectedCity.toLowerCase();
      return matchSearch && matchCategory && matchCity;
    }).toList();
  }

  // Lấy danh sách địa điểm chưa save (dùng cho ExploreScreen)
  List<DestinationModel> get unsavedDestinations {
    return _destinations.where((d) {
      final matchSaved = !_savedIds.contains(d.name);
      final matchSearch =
          _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery) ||
          d.city.toLowerCase().contains(_searchQuery);
      final matchCategory =
          _selectedCategory.isEmpty ||
          d.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchCity =
          _selectedCity.isEmpty ||
          d.city.toLowerCase() == _selectedCity.toLowerCase();
      return matchSaved && matchSearch && matchCategory && matchCity;
    }).toList();
  }

  // Phân loại
  void selectCategory(String category) {
    _selectedCategory = category;
    _filterDestinations();
  }

  // Thêm method chọn city
  void selectCity(String city) {
    _selectedCity = city;
    _filterDestinations();
  }

  // Cập nhật _filterDestinations để kết hợp cả 2 filter
  Future<void> _filterDestinations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Bọc try/catch để bắt lỗi khi filter
    try {
      _destinations = await _repository.getDestinationsByCategoryAndCity(
        _selectedCategory,
        _selectedCity,
      );
    } catch (e) {
      _errorMessage = 'explore.filter_error'.tr();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Kiểm tra xem địa điểm có được save chưa
  bool isSaved(String name) {
    return _savedIds.contains(name);
  }

  // Toggle save/unsave
  Future<void> toggleSave(String name) async {
    final user = await _userRepository.getCurrentUser();
    if (user == null) return;

    _errorMessage = null;
    try {
      if (_savedIds.contains(name)) {
        _savedIds.remove(name);
        _savedFromFirestore.removeWhere((d) => d.name == name);
        await _repository.unsaveDestination(user.uid, name);
      } else {
        final destination = _destinations.firstWhere(
          (d) => d.name == name,
          orElse: () => _savedFromFirestore.firstWhere((d) => d.name == name),
        );
        _savedIds.add(name);
        _savedFromFirestore.add(destination);
        await _repository.saveDestination(user.uid, destination);
      }
    } catch (e) {
      _errorMessage = 'explore.save_error'.tr();
    }
    notifyListeners();
  }

  // Load từ Firestore - gọi khi cần refresh saved list
  Future<void> refreshSavedDestinations() async {
    final user = await _userRepository.getCurrentUser();
    if (user == null) return;

    _errorMessage = null;
    try {
      _savedFromFirestore = await _repository.getSavedDestinations(user.uid);
      _savedIds = _savedFromFirestore.map((d) => d.name).toSet();
    } catch (e) {
      _errorMessage = 'explore.load_saved_error'.tr();
    }
    notifyListeners();
  }

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//
  // Tìm kiếm destination
  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  // Ấn x để xoá các từ đã gõ
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Reset tất cả filters về mặc định
  void resetFilters() {
    _selectedCategory = '';
    _selectedCity = '';
    _searchQuery = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
