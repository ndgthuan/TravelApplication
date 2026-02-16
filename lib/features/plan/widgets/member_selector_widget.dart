// Widget dùng để hiện thị các người sử dụng dùng để add các thành viên vào plan trong lúc tạo plan sheet
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/models/user_model.dart';
import 'package:travel_app/features/plan/viewmodels/plan_view_model.dart';
import 'package:travel_app/features/plan/widgets/member_search_sheet.dart';

// Widget hiển thị và quản lý danh sách thành viên đồng hành
class MemberSelectorWidget extends StatelessWidget {
  final List<PlanMember> members;
  final VoidCallback onAddPressed;
  final ValueChanged<int> onRemoveMember;

  const MemberSelectorWidget({
    super.key,
    required this.members,
    required this.onAddPressed,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'plan.companions'.tr(),
            style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Nút Add member
              GestureDetector(
                onTap: onAddPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6D00),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'plan.add'.tr(),
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Avatars đã chọn
              if (members.isNotEmpty)
                SizedBox(
                  width: (members.length.clamp(0, 5) - 1) * 16.0 + 44,
                  height: 44,
                  child: Stack(
                    children: [
                      for (int i = 0; i < members.length.clamp(0, 5); i++)
                        Positioned(
                          left: i * 16.0,
                          child: GestureDetector(
                            onLongPress: () => onRemoveMember(i),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFFFF6D00),
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                child: members[i].avatarUrl.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 18,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                              members[i].avatarUrl,
                                            ),
                                      )
                                    : Text(
                                        members[i].email[0].toUpperCase(),
                                        style: GoogleFonts.beVietnamPro(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              // Hiện thêm số lượng nếu > 5
              if (members.length > 5)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '+${members.length - 5}',
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  //=====================================================================//
  //                          HELPER FUNCTION                            //
  //=====================================================================//
  // Hiển thị search sheet để tìm kiếm và chọn thành viên khi số lượng người dùng quá nhiều
  static void showSearchSheet({
    required BuildContext context,
    required List<PlanMember> currentMembers,
    required ValueChanged<List<UserModel>> onConfirm,
  }) async {
    final vm = context.read<PlanViewModel>();
    if (vm.allUsers.isEmpty) {
      await vm.fetchAllUsers();
    }

    if (!context.mounted) return;

    final availableUsers = vm.allUsers
        .where((u) => u.uid != vm.currentUid)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => MemberSearchSheet(
        availableUsers: availableUsers,
        selectedEmails: currentMembers.map((m) => m.email).toSet(),
        onConfirm: onConfirm,
      ),
    );
  }
}
