// Interface cho Weather API: lấy dự báo thời tiết theo tọa độ
abstract class IWeatherService {
  // Lấy dự báo thời tiết theo [latitude], [longitude]
  // Trả về raw map từ API hoặc null nếu lỗi
  Future<Map<String, dynamic>?> getForecast({
    required double latitude,
    required double longitude,
  });
}
