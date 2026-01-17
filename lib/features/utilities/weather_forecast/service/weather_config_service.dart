// WeatherConfigService chỉ lo load và xử lý weather config từ JSON
// Cung cấp icon URL và text cho các weather code

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class WeatherConfigService {
  Map<String, dynamic>? _weatherConfigs;

  // Getter để biết config đã load chưa
  bool get isLoaded => _weatherConfigs != null;

  // Load config từ JSON file
  Future<void> loadConfigs() async {
    if (_weatherConfigs != null) return; // Đã load rồi thì bỏ qua

    final jsonString = await rootBundle.loadString(
      'lib/assets/data/supported_weather.json',
    );
    _weatherConfigs = json.decode(jsonString);
  }

  // Lấy URL icon theo weather code
  String getWeatherIconUrl(int code, bool isDay) {
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

  // Lấy text mô tả thời tiết theo weather code và ngôn ngữ
  String getWeatherText(int code, String langCode) {
    if (_weatherConfigs == null) return '';

    final codeData = _weatherConfigs!['weather_codes'][code.toString()];
    if (codeData != null) {
      return codeData[langCode] ?? codeData['en'] ?? '';
    }
    return '';
  }
}
