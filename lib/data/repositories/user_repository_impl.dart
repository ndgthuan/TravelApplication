// Mục đích của file này xử lý logic từ menu i_user_repository
// Bên cạnh đó xử lý logic có thay đổi gì thì chỉ cần chỉnh sửa tại đây
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/models/user_model.dart';

class UserRepositoryImpl implements IUserRepository {
  // Gọi user và data lưu trữ của Firebase
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  UserRepositoryImpl({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  //==========================================================================//
  //                            LẤY THÔNG TIN                                 //
  //==========================================================================//
  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data() ?? {}, user.uid);
  }

  //==========================================================================//
  //                            CẬP NHẬT THÔNG TIN                            //
  //==========================================================================//
  @override
  Future<void> updateUser(Map<String, dynamic> data) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update(data);
  }
}
