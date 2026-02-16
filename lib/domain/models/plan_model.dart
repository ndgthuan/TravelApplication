import 'package:intl/intl.dart';

// Thông tin người dùng - email + avatar + quyền trong plan (owner / editor / spectator)
class PlanMember {
  final String email;
  final String avatarUrl;
  final String role; // 'owner' | 'editor' | 'spectator'. Người tạo = owner, thêm vào mặc định = spectator.

  PlanMember({
    required this.email,
    required this.avatarUrl,
    this.role = 'spectator',
  });

  factory PlanMember.fromJson(Map<String, dynamic> json) => PlanMember(
    email: json['email'] as String? ?? '',
    avatarUrl: json['avatarUrl'] as String? ?? '',
    role: json['role'] as String? ?? 'spectator',
  );
  Map<String, dynamic> toJson() =>
      {'email': email, 'avatarUrl': avatarUrl, 'role': role};

  PlanMember copyWith({String? email, String? avatarUrl, String? role}) {
    return PlanMember(
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }
}

class PlanModel {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final List<PlanMember> members;
  final double budget;
  final String destination;
  PlanModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    this.members = const [],
    this.budget = 0,
    this.destination = '',
  });
  int get totalDays => endDate.difference(startDate).inDays + 1;

  // currentDay tính khi hiển thị, không lưu trong Firestore
  int get currentDay {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return totalDays;
    return now.difference(startDate).inDays + 1;
  }

  String dateRangeText([String locale = 'en']) {
    final fmt = DateFormat.MMMd(locale);
    return '${fmt.format(startDate)} - ${fmt.format(endDate)}';
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final start = json['startDate'];
    final end = json['endDate'];
    return PlanModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startDate: start is DateTime
          ? start
          : DateTime.tryParse(start.toString()) ?? DateTime.now(),
      endDate: end is DateTime
          ? end
          : DateTime.tryParse(end.toString()) ?? DateTime.now(),
      imageUrl: json['imageUrl'] as String? ?? '',
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => PlanMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      destination: json['destination'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'imageUrl': imageUrl,
    'members': members.map((m) => m.toJson()).toList(),
    'budget': budget,
    'destination': destination,
  };

  PlanModel copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? imageUrl,
    List<PlanMember>? members,
    double? budget,
    String? destination,
  }) {
    return PlanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      members: members ?? this.members,
      budget: budget ?? this.budget,
      destination: destination ?? this.destination,
    );
  }
}
