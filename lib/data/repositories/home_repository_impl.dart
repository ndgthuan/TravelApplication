// Mục đích của file là implement các method từ i_home_repositor
// Tác dụng của các file này là thực hiện các method ẩn mà bên UI chỉ có việc gọi lại các method
// Dùng để trả về các hành động cho i_home_repository
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/domain/repositories/i_home_repository.dart';
import 'package:travel_app/features/home/models/destination_model.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeRepositoryImpl implements IHomeRepository {
  static const String _apiUrl =
      'https://api.npoint.io/de217cd3d6eebe3e9379'; // Gọi data api địa điểm
  List<Destination>? _cachedApiData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  @override
  Future<List<Destination>> getTop10Destinations() async {
    // Fetch từ API nếu chưa cache
    if (_cachedApiData == null) {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedApiData = data.map((e) => Destination.fromJson(e)).toList();
      } else {
        return [];
      }
    }

    // Sort theo rating giảm dần và lấy 10 đầu
    final sorted = List<Destination>.from(_cachedApiData!)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(10).toList();
  }

  @override
  Future<List<Destination>> getTop5Destinations() async {
    if (_cachedApiData == null) {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedApiData = data.map((e) => Destination.fromJson(e)).toList();
      } else {
        return [];
      }
    }

    // Sort theo reviewCount và lấy 5 đầu
    final sorted = List<Destination>.from(_cachedApiData!)
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sorted.take(5).toList();
  }

  @override
  Future<List<Destination>> getSavedDestinations(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_destinations')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Destination(
        name: data['name'] ?? '',
        address: data['address'] ?? '',
        city: data['city'] ?? '',
        country: data['country'] ?? 'Vietnam',
        latitude: (data['latitude'] ?? 0).toDouble(),
        longitude: (data['longitude'] ?? 0).toDouble(),
        rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
        reviewCount: int.tryParse(data['reviewCount']?.toString() ?? '0') ?? 0,
        category: data['category'] ?? '',
        imagePath: data['imageUrl'] ?? '',
        // ... parse các field khác
      );
    }).toList();
  }

  @override
  Future<void> saveDestination(String userId, Destination destination) async {
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
  }

  @override
  Future<void> unsaveDestination(String userId, String name) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_destinations')
        .where('name', isEqualTo: name)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<List<Destination>> getAllFromApi() async {
    if (_cachedApiData == null) {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedApiData = data.map((e) => Destination.fromJson(e)).toList();
      } else {
        return [];
      }
    }
    return _cachedApiData!;
  }
}
