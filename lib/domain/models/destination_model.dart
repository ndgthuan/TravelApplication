// Tạo class để chứa dữ liệu từ file json
class DestinationModel {
  final String name;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String rating;
  final String reviewCount;
  final String category;
  final String imageUrl;

  DestinationModel({
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.imageUrl,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: json['rating']?.toString() ?? '0.0',
      reviewCount: json['reviewCount']?.toString() ?? '0',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
