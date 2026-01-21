// Mục dích của file là định nghĩa hợp đồng cho các phương thức Explore
// UI sẽ tách rời và chỉ cần gọi không cần biết bên trong thực hiện như nào
// ViewModel sẽ phụ thuộc vào Interface này
import 'package:travel_app/features/explore/models/explore_destination.dart';

abstract class IExploreRepository {
  Future<List<ExploreDestination>> getDestinations({
    required int offset,
    required int limit,
  });

  Future<int> getTotalCount();

  Future<List<ExploreDestination>> searchDestinations(String query);
}
