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

  // Đã check-in tại điểm này chưa. Lưu trên Firestore để thêm/xóa activity không làm lệch trạng thái.
  final bool isCheckedIn;

  PlanActivityModel({
    required this.id,
    required this.planId,
    required this.name,
    required this.type,
    required this.time,
    required this.latitude,
    required this.longitude,
    this.addressText,
    this.isCheckedIn = false,
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
    'isCheckedIn': isCheckedIn,
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
      isCheckedIn: json['isCheckedIn'] as bool? ?? false,
    );
  }

  PlanActivityModel copyWith({
    String? id,
    String? planId,
    String? name,
    String? type,
    DateTime? time,
    double? latitude,
    double? longitude,
    String? addressText,
    bool? isCheckedIn,
  }) {
    return PlanActivityModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      name: name ?? this.name,
      type: type ?? this.type,
      time: time ?? this.time,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressText: addressText ?? this.addressText,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
    );
  }
}
