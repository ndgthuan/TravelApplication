import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/domain/repositories/i_home_repository.dart';
import 'package:travel_app/features/home/models/destination_model.dart';

class HomeViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final IHomeRepository _homeRepo;

  HomeViewModel(this._homeRepo);

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Destination> _allApiDestinations = []; // Cache toàn bộ data từ API
  List<Destination> _top5Display = []; // Top 5 theo reviewCount
  List<Destination> _top10Display = []; // Top 10 Cafe/Restaurant theo rating
  Set<String> _savedIds = {}; // Các ID đã save
  bool isSaved(String name) => _savedIds.contains(name);
  bool _isLoading = true;

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  bool get isLoading => _isLoading;
  List<Destination> get top5Display => _top5Display;
  List<Destination> get top10Display => _top10Display;
  Set<String> get savedIds => _savedIds;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Load data khi khởi tạo
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    // 1. Load saved IDs từ Firestore trước
    await _loadSavedIds();

    // 2. Load all data từ API
    final rawData = await _homeRepo.getAllFromApi();

    // 3. Deduplicate by name (giữ cái đầu tiên cho mỗi tên)
    final seenNames = <String>{};
    _allApiDestinations = rawData.where((d) {
      if (seenNames.contains(d.name)) return false;
      seenNames.add(d.name);
      return true;
    }).toList();

    // 4. Lọc ra những cái chưa save để làm pool
    final unsavedPool = _allApiDestinations
        .where((d) => !_savedIds.contains(d.name))
        .toList();

    // 5. Lấy Top 5 (sort by reviewCount) - tất cả category
    final sortedByReview = List<Destination>.from(unsavedPool)
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    _top5Display = sortedByReview.take(5).toList();

    // 6. Lấy Top 10 (sort by rating) - chỉ Cafe và Restaurant
    final cafeRestaurantPool = unsavedPool
        .where((d) => d.category == 'Cafe' || d.category == 'Restaurant')
        .toList();
    final sortedByRating = List<Destination>.from(cafeRestaurantPool)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    _top10Display = sortedByRating.take(10).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSavedIds() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final saved = await _homeRepo.getSavedDestinations(user.uid);
    _savedIds = saved.map((d) => d.name).toSet();
  }

  Future<void> toggleSave(String name, bool isTop10) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_savedIds.contains(name)) {
      // Unsave
      _savedIds.remove(name);
      await _homeRepo.unsaveDestination(user.uid, name);
    } else {
      // Save
      _savedIds.add(name);

      // Tìm destination để save vào Firestore
      final destination = _allApiDestinations.firstWhere((d) => d.name == name);
      await _homeRepo.saveDestination(user.uid, destination);

      // Xóa khỏi display list và thay bằng card random
      if (isTop10) {
        _top10Display.removeWhere((d) => d.name == name);
        _replaceWithRandom(_top10Display, 10, cafeRestaurantOnly: true);
      } else {
        _top5Display.removeWhere((d) => d.name == name);
        _replaceWithRandom(_top5Display, 5);
      }
    }
    notifyListeners();
  }

  void _replaceWithRandom(
    List<Destination> displayList,
    int maxSize, {
    bool cafeRestaurantOnly = false,
  }) {
    // Pool = tất cả chưa save và chưa có trong displayList
    final currentNames = displayList.map((d) => d.name).toSet();
    var pool = _allApiDestinations
        .where(
          (d) => !_savedIds.contains(d.name) && !currentNames.contains(d.name),
        )
        .toList();

    // Nếu là Top 10, chỉ lấy Cafe/Restaurant
    if (cafeRestaurantOnly) {
      pool = pool
          .where((d) => d.category == 'Cafe' || d.category == 'Restaurant')
          .toList();
    }

    if (pool.isNotEmpty && displayList.length < maxSize) {
      final random = Random();
      final randomItem = pool[random.nextInt(pool.length)];
      displayList.add(randomItem);
    }
  }
}
