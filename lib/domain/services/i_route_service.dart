import 'package:latlong2/latlong.dart';

// Domain-level service để tính các đoạn đường đi giữa các điểm theo thứ tự thời gian.
// ViewModel chỉ gọi service này, không phụ thuộc trực tiếp vào OpenRouteService hay dotenv.
abstract class IRouteService {
  // Nhận danh sách điểm theo thứ tự thời gian và trả về danh sách các đoạn polyline
  // [i] = đoạn từ points[i] → points[i + 1].
  // - Ưu tiên dùng đường đi theo đường bộ (OpenRouteService).
  //   sang đoạn thẳng [start, end] để luôn có gì đó hiển thị trên map.
  Future<List<List<LatLng>>> buildSegments(List<LatLng> pointsInTimeOrder);
}
