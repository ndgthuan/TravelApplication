// Lời mời tham gia plan - lưu tại Firestore collection plan_invites
class PlanInviteModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String planId;
  final String planOwnerId;
  final String tripName;
  final String destination;
  final String status; // 'pending' | 'accepted' | 'declined'
  final DateTime createdAt;

  PlanInviteModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.planId,
    required this.planOwnerId,
    required this.tripName,
    required this.destination,
    this.status = 'pending',
    required this.createdAt,
  });

  factory PlanInviteModel.fromJson(Map<String, dynamic> json, String id) {
    return PlanInviteModel(
      id: id,
      fromUserId: json['fromUserId'] as String? ?? '',
      fromUserName: json['fromUserName'] as String? ?? '',
      toUserId: json['toUserId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      planOwnerId: json['planOwnerId'] as String? ?? '',
      tripName: json['tripName'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'toUserId': toUserId,
        'planId': planId,
        'planOwnerId': planOwnerId,
        'tripName': tripName,
        'destination': destination,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}
