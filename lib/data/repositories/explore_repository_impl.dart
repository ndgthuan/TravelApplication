import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/domain/repositories/i_explore_repository.dart';
import 'package:travel_app/features/explore/models/destination_model.dart';

// Implementation đọc dữ liệu từ file JSON local
class ExploreRepositoryImpl implements IExploreRepository {
  List<DestinationModel>? _cachedData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<DestinationModel>> getDestinations() async {
    if (_cachedData != null) return _cachedData!;

    try {
      final String response = await rootBundle.loadString(
        'lib/assets/data/explore_destinations.json',
      );
      final List<dynamic> data = json.decode(response);
      _cachedData = data.map((e) => DestinationModel.fromJson(e)).toList();
      return _cachedData!;
    } catch (e) {
      log("Lỗi load data: $e");
      return [];
    }
  }

  @override
  Future<List<DestinationModel>> getDestinationsByCategory(
    String category,
  ) async {
    final all = await getDestinations();
    if (category.isEmpty) return all;
    return all
        .where(
          (item) =>
              item.category.toLowerCase().contains(category.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final all = await getDestinations();

    // Lấy tất cả category không trùng lặp
    final uniqueCategories = all.map((e) => e.category).toSet().toList();

    // Thêm "Tất cả" vào đầu
    return ['', ...uniqueCategories]; // '' = Tất cả
  }

  @override
  Future<List<String>> getCities() async {
    final all = await getDestinations();
    final uniqueCities = all.map((e) => e.city).toSet().toList();
    uniqueCities.sort(); // Sắp xếp A-Z
    return ['', ...uniqueCities]; // '' = Tất cả
  }

  @override
  Future<List<DestinationModel>> getDestinationsByCategoryAndCity(
    String category,
    String city,
  ) async {
    final all = await getDestinations();

    return all.where((item) {
      final matchCategory =
          category.isEmpty ||
          item.category.toLowerCase().contains(category.toLowerCase());
      final matchCity =
          city.isEmpty || item.city.toLowerCase() == city.toLowerCase();
      return matchCategory && matchCity;
    }).toList();
  }

  @override
  Future<List<DestinationModel>> getSavedDestinations(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_destinations')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DestinationModel(
        name: data['name'] ?? '',
        address: data['address'] ?? '',
        city: data['city'] ?? '',
        country: data['country'] ?? 'Vietnam',
        latitude: (data['latitude'] ?? 0).toDouble(),
        longitude: (data['longitude'] ?? 0).toDouble(),
        rating: data['rating'] ?? '',
        reviewCount: data['reviewCount'] ?? '',
        category: data['category'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
      );
    }).toList();
  }

  @override
  Future<void> saveDestination(
    String userId,
    DestinationModel destination,
  ) async {
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
          'imageUrl': destination.imageUrl,
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
}
