// Mục đích của file này quản lý state và logic cho WorldClockScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travel_app/shared/services/geocoding_service.dart';
import '../services/timezone_storage_service.dart';
import '../services/timezone_util_service.dart';

class WorldClockViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final GeocodingService _geocodingService;
  final TimezoneStorageService _storageService;
  final TimezoneUtilService _utilService;

  WorldClockViewModel(
    this._geocodingService,
    this._storageService,
    this._utilService,
  );

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  List<Map<String, dynamic>> _timezones = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  // Getters để UI đọc state
  List<Map<String, dynamic>> get timezones => _timezones;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  List<Map<String, dynamic>> get popularCities => _popularCities;

  // Popular cities to show by default
  final List<Map<String, dynamic>> _popularCities = [
    {
      'city': 'Tokyo',
      'country': 'Japan',
      'timezone': 'Asia/Tokyo',
      'latitude': 35.6762,
      'longitude': 139.6503,
    },
    {
      'city': 'London',
      'country': 'United Kingdom',
      'timezone': 'Europe/London',
      'latitude': 51.5074,
      'longitude': -0.1278,
    },
    {
      'city': 'New York',
      'country': 'United States',
      'timezone': 'America/New_York',
      'latitude': 40.7128,
      'longitude': -74.0060,
    },
    {
      'city': 'Paris',
      'country': 'France',
      'timezone': 'Europe/Paris',
      'latitude': 48.8566,
      'longitude': 2.3522,
    },
    {
      'city': 'Sydney',
      'country': 'Australia',
      'timezone': 'Australia/Sydney',
      'latitude': -33.8688,
      'longitude': 151.2093,
    },
    {
      'city': 'Singapore',
      'country': 'Singapore',
      'timezone': 'Asia/Singapore',
      'latitude': 1.3521,
      'longitude': 103.8198,
    },
    {
      'city': 'Dubai',
      'country': 'United Arab Emirates',
      'timezone': 'Asia/Dubai',
      'latitude': 25.2048,
      'longitude': 55.2708,
    },
    {
      'city': 'Seoul',
      'country': 'South Korea',
      'timezone': 'Asia/Seoul',
      'latitude': 37.5665,
      'longitude': 126.9780,
    },
    {
      'city': 'Moscow',
      'country': 'Russia',
      'timezone': 'Europe/Moscow',
      'latitude': 55.7558,
      'longitude': 37.6173,
    },
    {
      'city': 'Los Angeles',
      'country': 'United States',
      'timezone': 'America/Los_Angeles',
      'latitude': 34.0522,
      'longitude': -118.2437,
    },
  ];

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Load danh sách đã lưu
  Future<void> loadTimezones() async {
    _isLoading = true;
    notifyListeners();

    final timezones = await _storageService.getSavedTimezones();
    _timezones = timezones;
    _isLoading = false;
    notifyListeners();
  }

  // Tìm kiếm thành phố (có debounce)
  void searchCities(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        _searchResults = [];
        notifyListeners();
        return;
      }

      _isSearching = true;
      notifyListeners();

      final results = await _geocodingService.searchCities(query);
      _searchResults = results;
      _isSearching = false;
      notifyListeners();
    });
  }

  // Thêm timezone vào danh sách
  Future<void> addTimezone(Map<String, dynamic> tz) async {
    await _storageService.addTimezone(tz);
    await loadTimezones();
    _searchResults = [];
    notifyListeners();
  }

  // Xóa timezone khỏi danh sách
  Future<void> removeTimezone(int index) async {
    await _storageService.removeTimezone(index);
    await loadTimezones();
  }

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//
  // Lấy timezone offset
  int getTimezoneOffset(String timezone) {
    return _utilService.getTimezoneOffset(timezone);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
