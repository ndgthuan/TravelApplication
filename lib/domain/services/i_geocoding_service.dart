// Interface cho Geocoding: tìm kiếm thành phố theo tên
abstract class IGeocodingService {
  // Tìm kiếm thành phố theo [query]
  // Mỗi item: city, country, timezone, latitude, longitude
  Future<List<Map<String, dynamic>>> searchCities(String query);
}
