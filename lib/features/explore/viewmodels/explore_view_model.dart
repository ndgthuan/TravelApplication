import 'package:flutter/material.dart';
import 'package:travel_app/data/repositories/explore_repository_impl.dart';
import 'package:travel_app/domain/repositories/i_explore_repository.dart';
import 'package:travel_app/features/explore/models/destination_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExploreViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final IExploreRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ExploreViewModel({IExploreRepository? repository})
    : _repository = repository ?? ExploreRepositoryImpl();

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

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Cập nhật loadData
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await refreshSavedDestinations(); // Load saved data from Firestore
    _categories = await _repository.getCategories();
    _cities = await _repository.getCities();
    _destinations = await _repository.getDestinations();

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
    notifyListeners();
    _destinations = await _repository.getDestinationsByCategoryAndCity(
      _selectedCategory,
      _selectedCity,
    );
    _isLoading = false;
    notifyListeners();
  }

  // Kiểm tra xem địa điểm có được save chưa
  bool isSaved(String name) {
    return _savedIds.contains(name);
  }

  // Toggle save/unsave
  Future<void> toggleSave(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_savedIds.contains(name)) {
      // Unsave
      _savedIds.remove(name);
      _savedFromFirestore.removeWhere((d) => d.name == name);
      await _repository.unsaveDestination(user.uid, name);
    } else {
      // Save - tìm destination trong list
      final destination = _destinations.firstWhere(
        (d) => d.name == name,
        orElse: () => _savedFromFirestore.firstWhere((d) => d.name == name),
      );
      _savedIds.add(name);
      _savedFromFirestore.add(destination);
      await _repository.saveDestination(user.uid, destination);
    }
    notifyListeners();
  }

  // Load từ Firestore - gọi khi cần refresh saved list
  Future<void> refreshSavedDestinations() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _savedFromFirestore = await _repository.getSavedDestinations(user.uid);
    _savedIds = _savedFromFirestore.map((d) => d.name).toSet();
    notifyListeners();
  }

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//
  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

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
}
