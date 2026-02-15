// Lưu các giá trị mà activities khởi tạo
class PlanActivityModel {
  final String id;
  final String planId;
  final String name;
  final String type;
  final DateTime time;
  final double latitude;
  final double longitude;
  final String? addressText;

  PlanActivityModel({
    required this.id,
    required this.planId,
    required this.name,
    required this.type,
    required this.time,
    required this.latitude,
    required this.longitude,
    this.addressText,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'planId': planId,
    'name': name,
    'type': type,
    'time': time.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'addressText': addressText,
  };

  factory PlanActivityModel.fromJson(Map<String, dynamic> json) {
    return PlanActivityModel(
      id: json['id'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'sightseeing',
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      addressText: json['addressText'] as String?,
    );
  }
}
