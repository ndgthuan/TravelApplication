// Mục đích của file này quản lý state và logic cho WeatherForecastScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/shared/services/geocoding_service.dart';
import 'package:travel_app/features/utilities/weather_forecast/service/weather_service.dart';
import 'package:travel_app/features/utilities/weather_forecast/service/weather_config_service.dart';

class WeatherForecastViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final GeocodingService _geocodingService;
  final WeatherService _weatherService;
  final WeatherConfigService _weatherConfigService;

  WeatherForecastViewModel(
    this._geocodingService,
    this._weatherService,
    this._weatherConfigService,
  );

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  // Khai báo các biến từ UI
  String _location = 'Hanoi';
  String _country = '';
  double _latitude = 0;
  double _longitude = 0;
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  // Search
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  // Getters để UI đọc state
  String get location => _location;
  String get country => _country;
  double get latitude => _latitude;
  double get longitude => _longitude;
  Map<String, dynamic>? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  //==========================================================================//
  //                                  COMPUTED GETTERS                        //
  //==========================================================================//
  // Current weather computed data
  int get currentTemperature =>
      _weatherData?['current']?['temperature_2m']?.toInt() ?? 0;
  int get currentWeatherCode => _weatherData?['current']?['weather_code'] ?? 0;
  int get currentHumidity =>
      _weatherData?['current']?['relative_humidity_2m'] ?? 0;
  int get currentWindSpeed =>
      _weatherData?['current']?['wind_speed_10m']?.toInt() ?? 0;
  int get currentUvIndex => _weatherData?['current']?['uv_index']?.toInt() ?? 0;

  bool get isDay {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour <= 18;
  }

  String get currentIconUrl => getWeatherIconUrl(currentWeatherCode, isDay);

  String currentCondition(String langCode) =>
      getWeatherText(currentWeatherCode, langCode);

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Khởi tạo dữ liệu weather lúc mở screen
  Future<void> initWeatherData() async {
    _isLoading = true; // Gọi loading để xử lý UI loading
    notifyListeners();

    // Load config trước
    await _weatherConfigService.loadConfigs();

    // Lấy thông tin toạ độ & quốc gia của location mặc định (Hanoi)
    final results = await _geocodingService.searchCities(_location);
    // Đặt giá trị mặc định khi mới mở weather forecast screen
    if (results.isNotEmpty) {
      final loc = results.first;
      _location = loc['city'] ?? loc['name'] ?? 'Hanoi';
      _country = loc['country'] ?? '';
      _latitude = loc['latitude'] ?? 21.0285;
      _longitude = loc['longitude'] ?? 105.8542;
    }
    // Không thì lấy mặc định Việt Nam
    else {
      _latitude = 21.0285;
      _longitude = 105.8542;
      _country = 'Vietnam';
    }
    // Lấy thời tiết
    await fetchWeather();
  }

  // Fetch weather từ API bằng cách đẩy vào server --> service đẩy lên web
  Future<void> fetchWeather() async {
    final data = await _weatherService.getForecast(
      latitude: _latitude,
      longitude: _longitude,
    );
    _weatherData = data;
    _isLoading = false;
    notifyListeners();
  }

  // Tìm kiếm location (có debounce)
  void searchLocations(String query) {
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

  // Chọn location từ kết quả search
  void selectLocation(Map<String, dynamic> location) {
    _location = location['name'];
    _country = location['country'] ?? '';
    _latitude = location['latitude'] ?? 0.0;
    _longitude = location['longitude'] ?? 0.0;
    _searchResults = [];
    notifyListeners();
    fetchWeather();
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//

  // Lấy hourly data đã format
  List<Map<String, dynamic>> getHourlyData() {
    if (_weatherData == null || _weatherData!['hourly'] == null) return [];

    final hourly = _weatherData!['hourly'];
    final times = hourly['time'] as List;
    final temps = hourly['temperature_2m'] as List;
    final codes = hourly['weather_code'] as List;

    final List<Map<String, dynamic>> hourlyList = [];
    final now = DateTime.now();

    for (int i = 0; i < times.length; i++) {
      final timeStr = times[i];
      final hourTime = DateTime.parse(timeStr);

      if (hourTime.isAfter(now.subtract(Duration(hours: 1)))) {
        final isDay = hourTime.hour >= 6 && hourTime.hour <= 18;
        hourlyList.add({
          'time': _formatHour(timeStr),
          'temp': temps[i],
          'icon': getWeatherIconUrl(codes[i], isDay),
        });
      }
      if (hourlyList.length >= 24) break;
    }
    return hourlyList;
  }

  // Lấy daily data đã format
  List<Map<String, dynamic>> getDailyData() {
    if (_weatherData == null || _weatherData!['daily'] == null) return [];

    final daily = _weatherData!['daily'];
    final times = daily['time'] as List;
    final codes = daily['weather_code'] as List;
    final maxTemps = daily['temperature_2m_max'] as List;
    final minTemps = daily['temperature_2m_min'] as List;

    final List<Map<String, dynamic>> dailyList = [];

    for (int i = 0; i < times.length; i++) {
      final date = DateTime.parse(times[i]);
      final isToday = date.day == DateTime.now().day;

      dailyList.add({
        'day': isToday ? 'weather.today'.tr() : _formatDay(date),
        'icon': getWeatherIconUrl(codes[i], true),
        'low': '${minTemps[i].toInt()}°C',
        'high': '${maxTemps[i].toInt()}°C',
      });
    }
    return dailyList;
  }

  String _formatHour(String timeStr) {
    final dateTime = DateTime.parse(timeStr);
    final now = DateTime.now();

    if (dateTime.difference(now).inHours.abs() < 1) {
      return 'weather.now'.tr();
    }

    final hour = dateTime.hour;
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String getWeatherIconUrl(int code, bool isDay) {
    return _weatherConfigService.getWeatherIconUrl(code, isDay);
  }

  String getWeatherText(int code, String langCode) {
    return _weatherConfigService.getWeatherText(code, langCode);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
