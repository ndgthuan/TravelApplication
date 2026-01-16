import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/features/home/models/destination_model.dart';

class DestinationService {
  // Load popular destinations
  static Future<List<Destination>> loadPopularDestination() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/popular_destinations.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    // Thêm index vào mỗi item để tạo đường dẫn ảnh local
    return jsonList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value as Map<String, dynamic>;
      // Ghi đè imageUrl bằng đường dẫn local
      item['imageUrl'] = 'lib/assets/images/destination/popular/$index.jpg';
      return Destination.fromJson(item);
    }).toList();
  }

  // Load recommend destination
  static Future<List<RecommendDestination>> loadRecommendDestination() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/daily_recommendations.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> jsonList = jsonData['recommendations'];
    // Thêm index vào mỗi item để tạo đường dẫn ảnh local
    return jsonList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value as Map<String, dynamic>;
      // Ghi đè imageUrl bằng đường dẫn local
      item['imageUrl'] = 'lib/assets/images/destination/recommend/$index.jpg';
      return RecommendDestination.fromJson(item);
    }).toList();
  }
}
