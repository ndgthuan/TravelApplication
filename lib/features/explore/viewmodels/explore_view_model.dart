// ViewModel quản lý state và logic cho ExploreScreen
// Sử dụng infinite loop scroll pattern
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travel_app/domain/repositories/i_explore_repository.dart';
import 'package:travel_app/domain/repositories/i_saved_destination_repository.dart';
import 'package:travel_app/features/explore/models/explore_destination.dart';

class ExploreViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final IExploreRepository _exploreRepository;
  final ISavedDestinationRepository _savedRepo;

  ExploreViewModel(this._exploreRepository, this._savedRepo);

  //==========================================================================//
  //                        CONSTANTS                                         //
  //==========================================================================//
  // Số lượng items load mỗi lần
  static const int pageSize = 8;

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  // Danh sách destinations đã load (có thể lặp lại)
  List<ExploreDestination> _destinations = [];

  // Master list - dữ liệu gốc từ JSON (không lặp)
  List<ExploreDestination> _masterList = [];

  // Loading states
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;

  // Infinite scroll - luôn có thể load thêm
  int _currentIndex = 0;

  // Search
  String _searchQuery = '';
  List<ExploreDestination> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  Set<String> _savedIds = {};

  // Tab index
  int _currentTabIndex = 0;

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  List<ExploreDestination> get destinations {
    if (_searchQuery.isNotEmpty) {
      // Khi search hiện tất cả (kể cả saved)
      return _searchResults;
    }
    // Khi không search: ẩn những cái đã saved
    return _destinations.where((d) => !d.isSaved).toList();
  }

  List<ExploreDestination> get savedDestinations {
    // Lấy unique saved destinations từ master list
    return _masterList.where((d) => d.isSaved).toList();
  }

  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;

  // Infinite scroll
  bool get hasMore => _searchQuery.isEmpty && _masterList.isNotEmpty;

  int get totalCount => _masterList.length;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  int get currentTabIndex => _currentTabIndex;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Khởi tạo dữ liệu khi mở screen
  Future<void> initData() async {
    _isInitialLoading = true;
    notifyListeners();

    // Load toàn bộ data vào master list
    _masterList = await _exploreRepository.getDestinations(
      offset: 0,
      limit: 9999, // Load all
    );

    _savedIds = await _savedRepo.getSavedIds();
    // Cập nhật isSaved cho masterList
    for (var d in _masterList) {
      final id = '${d.name}_${d.latitude}_${d.longitude}'.replaceAll(' ', '_');
      d.isSaved = _savedIds.contains(id);
    }

    // Load batch đầu tiên
    _loadNextBatch();

    _isInitialLoading = false;
    notifyListeners();
  }

  // Load thêm destinations (infinite loop scroll)
  Future<void> loadMore() async {
    // Không load nếu đang loading, đang search, hoặc không có data
    if (_isLoadingMore || _searchQuery.isNotEmpty || _masterList.isEmpty) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    // Simulate network delay để UX mượt hơn
    await Future.delayed(const Duration(milliseconds: 300));

    _loadNextBatch();

    _isLoadingMore = false;
    notifyListeners();
  }

  // Load batch tiếp theo (infinite loop - quay lại đầu khi hết)
  void _loadNextBatch() {
    if (_masterList.isEmpty) return;

    for (int i = 0; i < pageSize; i++) {
      // Dùng modulo để loop vô hạn
      final index = (_currentIndex + i) % _masterList.length;
      // Tạo copy để mỗi item trong list có thể có state riêng
      _destinations.add(_masterList[index].copyWith());
    }

    _currentIndex = (_currentIndex + pageSize) % _masterList.length;
  }

  // Tìm kiếm destinations với debounce
  void search(String query) {
    _searchQuery = query;
    notifyListeners();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        _searchResults = [];
        _isSearching = false;
        notifyListeners();
        return;
      }

      _isSearching = true;
      notifyListeners();

      _searchResults = await _exploreRepository.searchDestinations(query);

      _isSearching = false;
      notifyListeners();
    });
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  // Toggle save/unsave destination
  void toggleSave(ExploreDestination destination) async {
    // Tìm trong master list và cập nhật
    final masterIndex = _masterList.indexWhere(
      (d) => d.name == destination.name && d.latitude == destination.latitude,
    );
    if (masterIndex != -1) {
      _masterList[masterIndex].isSaved = !_masterList[masterIndex].isSaved;
      if (_masterList[masterIndex].isSaved) {
        await _savedRepo.saveDestination(_masterList[masterIndex]);
      } else {
        await _savedRepo.unsaveDestination(_masterList[masterIndex]);
      }
    }

    // Cập nhật tất cả instances trong destinations list
    for (int i = 0; i < _destinations.length; i++) {
      if (_destinations[i].name == destination.name &&
          _destinations[i].latitude == destination.latitude) {
        _destinations[i].isSaved = _masterList[masterIndex].isSaved;
      }
    }

    // Cập nhật trong search results nếu có
    for (int i = 0; i < _searchResults.length; i++) {
      if (_searchResults[i].name == destination.name &&
          _searchResults[i].latitude == destination.latitude) {
        _searchResults[i].isSaved = _masterList[masterIndex].isSaved;
      }
    }

    notifyListeners();
  }

  // Đổi tab
  void changeTab(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    _destinations = [];
    _currentIndex = 0;
    _searchQuery = '';
    _searchResults = [];

    await initData();
  }

  //==========================================================================//
  //                        DISPOSE                                           //
  //==========================================================================//
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
