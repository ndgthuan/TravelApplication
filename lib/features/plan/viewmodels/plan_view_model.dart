import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:travel_app/domain/models/plan_invite_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/models/user_model.dart';
import 'package:travel_app/domain/repositories/i_plan_repository.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';
import 'package:travel_app/domain/services/i_cloudinary_service.dart';

class PlanViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final IPlanRepository _planRepository;
  final IUserRepository _userRepository;
  final ICloudinaryService _cloudinaryService;
  PlanViewModel(
    this._planRepository,
    this._userRepository,
    this._cloudinaryService,
  );

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  List<PlanModel> _ongoingPlans = [];
  List<PlanModel> _upcomingPlans = [];
  List<PlanModel> _pastPlans = [];
  bool _isLoading = false;
  String? _error;

  // Tất cả users (cho member search)
  List<UserModel> _allUsers = [];

  // Tất cả plans (cho calendar highlighting)
  List<PlanModel> _allPlans = [];

  // Cache uid của user hiện tại (dùng cho member filter)
  String? _currentUid;

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  List<PlanModel> get ongoingPlans => _ongoingPlans;
  List<PlanModel> get upcomingPlans => _upcomingPlans;
  List<PlanModel> get pastPlans => _pastPlans;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUid => _currentUid;
  List<UserModel> get allUsers => _allUsers;
  List<PlanModel> get allPlans => _allPlans;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  Future<void> loadPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _userRepository.getCurrentUser();
      final userId = user?.uid;
      _currentUid = userId;

      _ongoingPlans = await _planRepository.getOngoingPlans(userId);
      _upcomingPlans = await _planRepository.getUpcomingPlans(userId);
      _pastPlans = await _planRepository.getPastPlans(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlanModel?> createPlan(PlanModel plan) async {
    try {
      final user = await _userRepository.getCurrentUser();
      final userId = _currentUid ?? user?.uid;
      var members = List<PlanMember>.from(plan.members);
      final hasOwner = members.any((m) => m.role == 'owner');
      if (!hasOwner && user != null) {
        members.insert(
          0,
          PlanMember(
            email: user.email,
            avatarUrl: user.avatarUrl ?? '',
            role: 'owner',
          ),
        );
      }
      final planToCreate = plan.copyWith(members: members);
      final created = await _planRepository.createPlan(userId, planToCreate);
      await loadPlans();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<PlanModel?> updatePlan(PlanModel plan) async {
    try {
      final userId =
          _currentUid ?? (await _userRepository.getCurrentUser())?.uid;
      final targetUserId = plan.ownerId ?? userId;
      if (targetUserId == null || targetUserId.isEmpty) return null;
      final latest = await _planRepository.getPlan(targetUserId, plan.id);
      if (latest == null) return null;
      final toSave = latest.version == plan.version
          ? plan
          : latest.copyWith(
              members: plan.members,
              bannedEmails: plan.bannedEmails,
              pendingInviteEmails: plan.pendingInviteEmails,
            );
      final ok = await _planRepository.updatePlan(targetUserId, toSave);
      if (!ok) {
        _error = 'Plan đã bị thay đổi bởi người khác. Vui lòng thử lại.';
        notifyListeners();
        return null;
      }
      await loadPlans();
      return toSave;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Gửi lời mời tham gia plan. Lưu plan_invites và thêm email vào plan.pendingInviteEmails.
  Future<bool> sendInvite(PlanModel plan, UserModel toUser) async {
    try {
      final user = await _userRepository.getCurrentUser();
      final fromUserId = user?.uid;
      if (fromUserId == null || fromUserId.isEmpty) return false;
      if (toUser.email.isEmpty) return false;
      final invite = PlanInviteModel(
        id: '',
        fromUserId: fromUserId,
        fromUserName: user!.name.isNotEmpty ? user.name : user.email,
        toUserId: toUser.uid,
        planId: plan.id,
        planOwnerId: fromUserId,
        tripName: plan.title,
        destination: plan.destination,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      await _planRepository.createInvite(invite);
      final latest = await _planRepository.getPlan(fromUserId, plan.id);
      final base = latest ?? plan;
      final updated = base.copyWith(
        pendingInviteEmails: [...base.pendingInviteEmails, toUser.email],
      );
      final ok = await _planRepository.updatePlan(fromUserId, updated);
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlan(String planId) async {
    try {
      final userId =
          _currentUid ?? (await _userRepository.getCurrentUser())?.uid;
      await _planRepository.deletePlan(userId, planId);
      await loadPlans();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Lấy tất cả users cho member search
  Future<void> fetchAllUsers() async {
    try {
      _allUsers = await _userRepository.getAllUsers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Lấy tất cả plans
  Future<void> fetchAllPlans() async {
    try {
      final userId =
          _currentUid ?? (await _userRepository.getCurrentUser())?.uid;
      _allPlans = await _planRepository.getAllPlans(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Kiểm tra ngày có nằm trong khoảng thời gian của plan nào không
  bool isDayBooked(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    for (final plan in _allPlans) {
      final start = DateTime(
        plan.startDate.year,
        plan.startDate.month,
        plan.startDate.day,
      );
      final end = DateTime(
        plan.endDate.year,
        plan.endDate.month,
        plan.endDate.day,
      );
      if (!d.isBefore(start) && !d.isAfter(end)) return true;
    }
    return false;
  }

  // Upload ảnh bìa lên Cloudinary, trả về URL
  Future<String?> uploadCoverImage(File imageFile) async {
    try {
      return await _cloudinaryService.uploadImage(imageFile);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//
  // Format số tiền: cứ 3 chữ số thì thêm dấu chấm
  // VD: "1000000" -> "1.000.000"
  static String formatMoney(String value) {
    // Xoá hết ký tự không phải số
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    // Thêm dấu . mỗi 3 số từ phải sang trái
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
