import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:travel_app/screen/Account/services/weather_service.dart';
import 'package:travel_app/screen/Account/widgets/hourly_forecast_widget.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  // Các biến
  String _location = 'Hanoi';
  String _country = '';
  double _latitude = 0;
  double _longitude = 0;
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _weatherConfigs;
  bool _isLoading = true;

  // Search
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadWeatherConfigs();
      _initWeatherData();
    }
  }

  Future<void> _loadWeatherConfigs() async {
    final jsonString = await rootBundle.loadString(
      'lib/assets/data/supported_weather.json',
    );
    _weatherConfigs = json.decode(jsonString);
    setState(() {});
  }

  Future<void> _initWeatherData() async {
    setState(() => _isLoading = true);

    // 1. Lấy thông tin toạ độ & quốc gia của location mặc định (Hanoi)
    final results = await WeatherService.searchLocations(_location);
    if (results.isNotEmpty) {
      final loc = results.first;
      _location = loc['name'];
      _country = loc['country'] ?? '';
      _latitude = loc['latitude'] ?? 21.0285;
      _longitude = loc['longitude'] ?? 105.8542;
    } else {
      // Fallback
      _latitude = 21.0285;
      _longitude = 105.8542;
      _country = 'Vietnam';
    }

    // 2. Lấy thời tiết
    await _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    // Không set isLoading = true vì đã set ở _initWeatherData
    final data = await WeatherService.getForecast(
      latitude: _latitude,
      longitude: _longitude,
    );
    setState(() {
      _weatherData = data;
      _isLoading = false;
    });
  }

  // Function Search
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() => _searchResults = []);
        return;
      }

      setState(() => _isSearching = true);
      final results = await WeatherService.searchLocations(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    setState(() {
      _location = location['name'];
      _country = location['country'] ?? '';
      _latitude = location['latitude'] ?? 0.0;
      _longitude = location['longitude'] ?? 0.0;
      _searchResults = [];
      _searchController.clear();
    });
    _fetchWeather();
  }

  List<Map<String, dynamic>> _getHourlyData() {
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
          'icon': _getWeatherIconUrl(codes[i], isDay),
        });
      }
      if (hourlyList.length >= 24) break;
    }
    return hourlyList;
  }

  // Format giờ để tránh overflow
  String _formatHour(String timeStr) {
    final dateTime = DateTime.parse(timeStr);
    final now = DateTime.now();

    // Nếu là giờ hiện tại (trong vòng 1 tiếng)
    if (dateTime.difference(now).inHours.abs() < 1) {
      return 'weather.now'.tr();
    }

    // Format: "2 PM", "10 AM"
    final hour = dateTime.hour;
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }

  // Lấy daily data
  List<Map<String, dynamic>> _getDailyData() {
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
        'icon': _getWeatherIconUrl(codes[i], true),
        'low': '${minTemps[i].toInt()}°C',
        'high': '${maxTemps[i].toInt()}°C',
      });
    }
    return dailyList;
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF1C1C1D),
        centerTitle: true,
        title: Text(
          'weather.title'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFFAD35)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buid search bar
                  Stack(
                    children: [
                      Column(
                        children: [
                          // Search bar
                          TextFormField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            cursorColor: Color(0xFFFFAD35),
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Color(0xFFFFAD35),
                                  width: 1.5,
                                ),
                              ),
                              hintText: 'weather.search_hint'.tr(),
                              hintStyle: GoogleFonts.beVietnamPro(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              fillColor: Color(0xFF1C1C1D),
                              filled: true,
                            ),
                          ),

                          // Search Results Dropdown
                          if (_searchResults.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFF1C1C1D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFFFAD35),
                                  width: 1,
                                ),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final location = _searchResults[index];
                                  return ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: Color(0xFFFFAD35),
                                    ),
                                    title: Text(
                                      location['name'],
                                      style: GoogleFonts.beVietnamPro(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${location['region']}, ${location['country']}',
                                      style: GoogleFonts.beVietnamPro(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onTap: () => _selectLocation(location),
                                  );
                                },
                              ),
                            ),

                          // Loading indicator
                          if (_isSearching)
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFAD35),
                                strokeWidth: 2,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Hộp kết quả tìm kiếm
                  const SizedBox(height: 20),
                  // Current Weather Card
                  _buildCurrentWeatherCard(),
                  SizedBox(height: 20),

                  // Hourly Forecast
                  HourlyForecastWidget(hourlyData: _getHourlyData()),
                  SizedBox(height: 20),

                  // Daily Forecast
                  _buildDailyForecast(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    // Lấy data từ API
    final current = _weatherData?['current'];

    if (current == null) return Container();

    final tempC = current['temperature_2m']?.toInt() ?? 0;
    final code = current['weather_code'];
    final condition = _getWeatherText(code);
    final humidity = current['relative_humidity_2m'] ?? 0;
    final windKph = current['wind_speed_10m']?.toInt() ?? 0;
    final uv = current['uv_index']?.toInt() ?? 0;

    // Is Day? (6am - 6pm)
    final hour = DateTime.now().hour;
    final isDay = hour >= 6 && hour <= 18;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFFAD35), width: 1.2),
      ),
      child: Stack(
        children: [
          // Weather Icon positioned at top right
          Positioned(
            top: 10,
            right: 10,
            child: Lottie.network(
              _getWeatherIconUrl(code, isDay),
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          ),

          // Main Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Row
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Color(0xFFFFAD35),
                      size: 18,
                    ),
                    Expanded(
                      child: Text(
                        '$_location, $_country',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Temperature
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$tempC',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFAD35),
                          fontSize: 100,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          '°C',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFAD35),
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Condition
                Center(
                  child: Text(
                    condition,
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Weather Details Row with Dividers
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFFFAD35), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWeatherDetail(
                        Icons.water_drop,
                        'weather.humidity'.tr(),
                        '$humidity%',
                      ),
                      Container(width: 1, height: 43, color: Color(0xFFFFAD35)),
                      _buildWeatherDetail(
                        Icons.air,
                        'weather.wind'.tr(),
                        '$windKph km/h',
                      ),
                      Container(width: 1, height: 43, color: Color(0xFFFFAD35)),
                      _buildWeatherDetail(
                        Icons.wb_sunny_outlined,
                        'weather.uv_index'.tr(),
                        '$uv',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFFFAD35), size: 33),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'ProductSans',
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyForecast() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFFAD35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'weather.daily_forecast'.tr(),
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 15),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _getDailyData().length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey[800], height: 1),
            itemBuilder: (context, index) {
              final dailyData = _getDailyData();
              final item = dailyData[index];
              final isToday = item['day'] == 'weather.today'.tr();
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Day name
                    SizedBox(
                      width: 60,
                      child: Text(
                        item['day'],
                        style: GoogleFonts.beVietnamPro(
                          color: isToday ? Color(0xFFFFAD35) : Colors.white,
                          fontSize: 14,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    // Weather icon
                    Lottie.network(
                      item['icon'],
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error, color: Colors.white, size: 20),
                    ),
                    // Temperature range
                    Row(
                      children: [
                        Text(
                          item['low'],
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' / ',
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          item['high'],
                          style: GoogleFonts.beVietnamPro(
                            color: Color(0xFFFFAD35),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helpers
  String _getWeatherIconUrl(int code, bool isDay) {
    if (_weatherConfigs == null) return '';
    final baseUrl = _weatherConfigs!['base_url'];
    final codeData = _weatherConfigs!['weather_codes'][code.toString()];
    if (codeData == null) return '';

    String iconFile;
    if (codeData.containsKey('icon_day')) {
      iconFile = isDay ? codeData['icon_day'] : codeData['icon_night'];
    } else {
      iconFile = codeData['icon'];
    }
    return '$baseUrl/$iconFile';
  }

  String _getWeatherText(int code) {
    if (_weatherConfigs == null) return '';
    final lang = context.locale.languageCode;
    final codeData = _weatherConfigs!['weather_codes'][code.toString()];
    if (codeData != null) {
      return codeData[lang] ?? codeData['en'] ?? '';
    }
    return '';
  }
}
