// Interface lấy vị trí thiết bị (GPS).
// ViewModel gọi qua interface này, không trực tiếp dùng Geolocator.
abstract class ILocationService {
  // Lấy vị trí hiện tại của thiết bị.
  // Trả về (latitude, longitude) hoặc null nếu lỗi / không có quyền.
  Future<({double latitude, double longitude})?> getCurrentPosition();
}
