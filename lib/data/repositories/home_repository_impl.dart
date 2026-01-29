// Mục đích của file là implement các method từ i_home_repository
// Tác dụng của các file này là thực hiện các method ẩn mà bên UI chỉ có việc gọi lại các method
// Dùng để trả về các hành động cho i_home_repository
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/domain/repositories/i_home_repository.dart';
import 'package:travel_app/domain/models/home_destination_model.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeRepositoryImpl implements IHomeRepository {
  static const String _apiUrl =
      'https://api.npoint.io/de217cd3d6eebe3e9379'; // Gọi data api địa điểm
  List<HomeDestination>? _cachedApiData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<HomeDestination>> getPopularDestinations() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/assets/data/popular_destinations.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => HomeDestination.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load popular destinations: $e');
    }
  }

  @override
  Future<List<RecommendDestination>> getRecommendDestinations() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/assets/data/daily_recommendations.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> jsonList = jsonData['recommendations'];
      return jsonList
          .map((item) => RecommendDestination.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load recommend destinations: $e');
    }
  }

  @override
  Future<List<HomeDestination>> getTop10Destinations() async {
    // Fetch từ API nếu chưa cache
    if (_cachedApiData == null) {
      await _fetchAndCacheApiData();
    }

    // Sort theo rating giảm dần và lấy 10 đầu
    final sorted = List<HomeDestination>.from(_cachedApiData!)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(10).toList();
  }

  @override
  Future<List<HomeDestination>> getTop5Destinations() async {
    if (_cachedApiData == null) {
      await _fetchAndCacheApiData();
    }

    // Sort theo reviewCount và lấy 5 đầu
    final sorted = List<HomeDestination>.from(_cachedApiData!)
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sorted.take(5).toList();
  }

  @override
  Future<List<HomeDestination>> getSavedDestinations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_destinations')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HomeDestination(
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          city: data['city'] ?? '',
          country: data['country'] ?? 'Vietnam',
          latitude: (data['latitude'] ?? 0).toDouble(),
          longitude: (data['longitude'] ?? 0).toDouble(),
          rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
          reviewCount:
              int.tryParse(data['reviewCount']?.toString() ?? '0') ?? 0,
          category: data['category'] ?? '',
          imagePath: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get saved destinations: $e');
    }
  }

  @override
  Future<void> saveDestination(
    String userId,
    HomeDestination destination,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_destinations')
          .add({
            'name': destination.name,
            'address': destination.address,
            'city': destination.city,
            'country': destination.country,
            'latitude': destination.latitude,
            'longitude': destination.longitude,
            'rating': destination.rating,
            'reviewCount': destination.reviewCount,
            'category': destination.category,
            'imageUrl': destination.imagePath,
            'savedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to save destination: $e');
    }
  }

  @override
  Future<void> unsaveDestination(String userId, String name) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_destinations')
          .where('name', isEqualTo: name)
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to unsave destination: $e');
    }
  }

  @override
  Future<List<HomeDestination>> getAllFromApi() async {
    if (_cachedApiData == null) {
      await _fetchAndCacheApiData();
    }
    return _cachedApiData!;
  }

  /// Private method để fetch và cache data từ API
  Future<void> _fetchAndCacheApiData() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode != 200) {
        throw Exception('API returned status code: ${response.statusCode}');
      }
      final List<dynamic> data = json.decode(response.body);
      _cachedApiData = data.map((e) => HomeDestination.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch data from API: $e');
    }
  }
}
