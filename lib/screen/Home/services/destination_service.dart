import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/screen/Home/models/destination_model.dart';

class DestinationService {
  // Load popular destinations
  static Future<List<Destination>> loadPopularDestination() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/result.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((item) => Destination.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Load recommend destination
  static Future<List<RecommendDestination>> loadRecommendDestination() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/daily_recommendations.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> jsonList = jsonData['recommendations'];
    return jsonList
        .map(
          (item) => RecommendDestination.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
