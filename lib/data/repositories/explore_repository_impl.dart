// Repository để load dữ liệu destinations từ JSON file
// Sử dụng pattern lazy loading với pagination
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/domain/repositories/i_explore_repository.dart';
import 'package:travel_app/features/explore/models/explore_destination.dart';

// Implementation của IExploreRepository
class ExploreRepositoryImpl implements IExploreRepository {
  // Cache dữ liệu đã load từ JSON để tránh đọc file nhiều lần
  List<ExploreDestination>? _cachedDestinations;

  // Load toàn bộ dữ liệu từ JSON và cache lại
  Future<List<ExploreDestination>> _loadAllDestinations() async {
    if (_cachedDestinations != null) {
      return _cachedDestinations!;
    }

    try {
      // Đọc file JSON từ assets
      final String jsonString = await rootBundle.loadString(
        'lib/assets/data/explore_destinations.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Parse tất cả destinations
      _cachedDestinations = jsonList
          .map((json) => ExploreDestination.fromJson(json))
          .toList();

      return _cachedDestinations!;
    } catch (e) {
      // Trả về list rỗng nếu có lỗi
      return [];
    }
  }

  @override
  Future<List<ExploreDestination>> getDestinations({
    required int offset,
    required int limit,
  }) async {
    final allDestinations = await _loadAllDestinations();

    // Kiểm tra bounds
    if (offset >= allDestinations.length) {
      return [];
    }

    // Tính end index (không vượt quá length)
    final endIndex = (offset + limit).clamp(0, allDestinations.length);

    // Trả về sublist với pagination
    return allDestinations.sublist(offset, endIndex);
  }

  @override
  Future<int> getTotalCount() async {
    final allDestinations = await _loadAllDestinations();
    return allDestinations.length;
  }

  @override
  Future<List<ExploreDestination>> searchDestinations(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final allDestinations = await _loadAllDestinations();
    final lowerQuery = query.toLowerCase();

    // Tìm kiếm theo name, city, country, hoặc category
    return allDestinations.where((destination) {
      return destination.name.toLowerCase().contains(lowerQuery) ||
          destination.city.toLowerCase().contains(lowerQuery) ||
          destination.country.toLowerCase().contains(lowerQuery) ||
          destination.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Clear cache nếu cần reload dữ liệu
  void clearCache() {
    _cachedDestinations = null;
  }
}
