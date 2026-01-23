// Mục đích của file là implement các method từ i_home_repositor
// Tác dụng của các file này là thực hiện các method ẩn mà bên UI chỉ có việc gọi lại các method
// Dùng để trả về các hành động cho i_home_repository
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/domain/repositories/i_home_repository.dart';
import 'package:travel_app/features/home/models/destination_model.dart';

class HomeRepositoryImpl implements IHomeRepository {
  @override
  Future<List<Destination>> getPopularDestinations() async {
    final String jsonString = await rootBundle.loadString(
      // Các dạng string được load từ json
      'lib/assets/data/popular_destinations.json',
    );

    // Sử dụng List dynamic để decode các string vào bên trong List
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => Destination.fromJson(item)).toList();
  }

  @override
  Future<List<RecommendDestination>> getRecommendDestinations() async {
    final String jsonString = await rootBundle.loadString(
      // Các dạng string được load từ json
      'lib/assets/data/daily_recommendations.json',
    );
    // Sử dụng Map để decode ra phần List cần được parse
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    // Parse các dữ liệu từ file json
    final List<dynamic> jsonList = jsonData['recommendations'];
    return jsonList.map((item) => RecommendDestination.fromJson(item)).toList();
  }
}
