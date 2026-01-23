// Mục dích của file là định nghĩa hợp đồng cho các phương thức Home
// UI sẽ tách rời và chỉ cần gọi không cần biết bên trong thực hiện như nào
// ViewModel sẽ phụ thuộc vào Interface này
import 'package:travel_app/features/home/models/destination_model.dart';

abstract class IHomeRepository {
  // Method để lấy các giá parse từ file destination json
  Future<List<Destination>> getPopularDestinations();

  // Method để lấy các giá trị parse từ file recommend json
  Future<List<RecommendDestination>> getRecommendDestinations();
}
