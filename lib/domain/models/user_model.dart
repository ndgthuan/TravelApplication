// Mục đích của file là load và ghi thông tin từ Firestore
// Nếu có hiệu chỉnh bên UI thì cũng không ảnh hưởng tới các thông tin được lưu
class UserModel {
  // Liệt kê các thông tin từ Firebase Firestore
  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? backgroundUrl;
  final DateTime? createAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.backgroundUrl,
    this.createAt,
  });

  // Lấy các thông tin từ dạng Json của Firestore
  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    // gán từng phần vào UserModal
    return UserModel(
      uid: uid,
      name: json['name'] ?? '', // Gán thông tin có value là name
      email: json['email'] ?? '', // Gán thông tin có value là email
      avatarUrl: json['avatarUrl'], // Gán thông tin có value là avatarUrl
      backgroundUrl:
          json['backgroundUrl'], // Gán thông tin có value là backgroundUrl
    );
  }

  // Ghi ngược vào thông tin Json của Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name, // Ghi vào value là name
      'email': email, // Ghi vào value là email
      'avatarUrl': avatarUrl, // Ghi vào value là avatarUrl
      'backgroundUrl': backgroundUrl, // Ghi vào value là backgroundUrl
    };
  }
}
