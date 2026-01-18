class Destination {
  final String country;
  final String name;
  final String city;
  final double rating;
  final int reviewCount;
  final String category;
  final String imagePath;

  Destination({
    required this.imagePath,
    required this.country,
    required this.name,
    required this.city,
    required this.rating,
    required this.reviewCount,
    required this.category,
  });

  // Parse từ file json
  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      imagePath: json['imageUrl'] ?? '',
      country: json['country'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
      category: json['category'] ?? '',
    );
  }
}

class RecommendDestination {
  final String name;
  final String address;
  final double rating;
  final String category;
  final String imagePath;

  RecommendDestination({
    required this.imagePath,
    required this.name,
    required this.address,
    required this.rating,
    required this.category,
  });

  // Parse từ file json
  factory RecommendDestination.fromJson(Map<String, dynamic> json) {
    return RecommendDestination(
      imagePath: json['imageUrl'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      category: json['category'] ?? '',
    );
  }
}
