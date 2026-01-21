// Model đại diện cho một địa điểm du lịch trong Explore
class ExploreDestination {
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
  bool isSaved;

  ExploreDestination({
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
    this.isSaved = false,
  });

  // Factory constructor để parse từ JSON
  factory ExploreDestination.fromJson(Map<String, dynamic> json) {
    return ExploreDestination(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      rating: json['rating']?.toString() ?? '0',
      reviewCount: json['reviewCount']?.toString() ?? '0',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  // Copy with để tạo bản sao có thể thay đổi isSaved
  ExploreDestination copyWith({
    String? name,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? rating,
    String? reviewCount,
    String? category,
    String? imageUrl,
    bool? isSaved,
  }) {
    return ExploreDestination(
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExploreDestination &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}
