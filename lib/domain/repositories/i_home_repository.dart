// Mục dích của file là định nghĩa hợp đồng cho các phương thức Home
// UI sẽ tách rời và chỉ cần gọi không cần biết bên trong thực hiện như nào
// ViewModel sẽ phụ thuộc vào Interface này
import 'package:travel_app/domain/models/home_destination_model.dart';

abstract class IHomeRepository {
  // Lấy danh sách địa điểm phổ biến từ local JSON
  // Throws [Exception] nếu có lỗi
  Future<List<HomeDestination>> getPopularDestinations();

  // Lấy danh sách địa điểm gợi ý hằng ngày từ local JSON
  // Throws [Exception] nếu có lỗi
  Future<List<RecommendDestination>> getRecommendDestinations();

  // Lấy Top 10 địa điểm từ API (sort by rating)
  // Throws [Exception] nếu API call thất bại
  Future<List<HomeDestination>> getTop10Destinations();

  // Lấy Top 5 địa điểm từ API (sort by reviewCount)
  // Throws [Exception] nếu API call thất bại
  Future<List<HomeDestination>> getTop5Destinations();

  // Lấy danh sách địa điểm đã save từ Firestore
  // [userId] - ID của user
  // Throws [Exception] nếu Firestore operation thất bại
  Future<List<HomeDestination>> getSavedDestinations(String userId);

  // Save một địa điểm vào Firestore
  // [userId] - ID của user
  // [destination] - Địa điểm cần save
  // Throws [Exception] nếu Firestore operation thất bại
  Future<void> saveDestination(String userId, HomeDestination destination);

  // Xóa một địa điểm khỏi danh sách đã save
  // [userId] - ID của user
  // [name] - Tên địa điểm cần xóa
  // Throws [Exception] nếu Firestore operation thất bại
  Future<void> unsaveDestination(String userId, String name);

  // Lấy tất cả địa điểm từ API
  // Throws [Exception] nếu API call thất bại
  Future<List<HomeDestination>> getAllFromApi();
}
