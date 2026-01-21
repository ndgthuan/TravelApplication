import 'package:travel_app/features/explore/models/explore_destination.dart';

abstract class ISavedDestinationRepository {
  // Lưu destination
  Future<void> saveDestination(ExploreDestination destination);

  // Xóa destination đã lưu
  Future<void> unsaveDestination(ExploreDestination destination);

  // Lấy danh sách ID đã lưu (để check khi load)
  Future<Set<String>> getSavedIds();
}
