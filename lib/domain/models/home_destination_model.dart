// Model đại diện cho địa điểm trong Home feature
// Đây là domain model, không phụ thuộc vào data layer
class HomeDestination {
  final String country;
  final String name;
  final String city;
  final double rating;
  final int reviewCount;
  final String category;
  final String imagePath;
  final double latitude;
  final double longitude;
  final String address;

  HomeDestination({
    required this.imagePath,
    required this.country,
    required this.name,
    required this.city,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory HomeDestination.fromJson(Map<String, dynamic> json) {
    return HomeDestination(
      imagePath: json['imageUrl'] ?? '',
      country: json['country'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
      category: json['category'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
    );
  }
}

// Model cho Recommend Destination
class RecommendDestination {
  final String name;
  final String address;
  final double rating;
  final String category;
  final String imagePath;
  final double latitude;
  final double longitude;
  final int reviewCount;

  RecommendDestination({
    required this.imagePath,
    required this.name,
    required this.address,
    required this.rating,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.reviewCount,
  });

  factory RecommendDestination.fromJson(Map<String, dynamic> json) {
    return RecommendDestination(
      imagePath: json['imageUrl'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      category: json['category'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
    );
  }
}
