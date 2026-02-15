// Interface cho Geocoding: tìm kiếm thành phố + địa điểm cụ thể (Nominatim)
abstract class IGeocodingService {
  // Tìm kiếm thành phố theo [query] (open-meteo, dùng cho weather/world clock)
  // Mỗi item: city, country, timezone, latitude, longitude
  Future<List<Map<String, dynamic>>> searchCities(String query);

  // Tìm kiếm địa điểm POI
  // Giới hạn kết quả trong quốc gia
  Future<List<Map<String, dynamic>>> searchPlaces(
    String query, {
    String? countryCodes,
  });

  // Từ tên địa điểm mà truy ra mã quốc gia
  Future<String?> getCountryCodeForPlace(String placeName);
}
