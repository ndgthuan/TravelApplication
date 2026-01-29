import 'package:travel_app/domain/models/destination_model.dart';

// Interface định nghĩa các method mà Repository phải có
abstract class IExploreRepository {
  // Lấy tất cả địa điểm
  Future<List<DestinationModel>> getDestinations();

  // Lấy địa điểm theo category
  Future<List<DestinationModel>> getDestinationsByCategory(String category);

  // Lấy danh sách category
  Future<List<String>> getCategories();

  // Lấy danh sách tất cả cities (không trùng lặp)
  Future<List<String>> getCities();

  // Lấy địa điểm theo category VÀ city
  Future<List<DestinationModel>> getDestinationsByCategoryAndCity(
    String category,
    String city,
  );

  // Saved destinations (Firestore)
  Future<List<DestinationModel>> getSavedDestinations(String userId);
  Future<void> saveDestination(String userId, DestinationModel destination);
  Future<void> unsaveDestination(String userId, String name);
}
