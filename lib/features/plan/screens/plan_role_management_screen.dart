import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/features/plan/viewmodels/plan_view_model.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';

// Màn hình quản lý role của các thành viên khi được add vào plan
class PlanRoleManagementScreen extends StatefulWidget {
  final PlanModel plan;

  const PlanRoleManagementScreen({super.key, required this.plan});

  @override
  State<PlanRoleManagementScreen> createState() =>
      _PlanRoleManagementScreenState();
}

class _PlanRoleManagementScreenState extends State<PlanRoleManagementScreen> {
  late List<PlanMember> _members;

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.plan.members);
  }

  Future<void> _save() async {
    final vm = context.read<PlanViewModel>();
    final updated = await vm.updatePlan(
      widget.plan.copyWith(members: _members),
    );
    if (!mounted || updated == null) return;
    Navigator.of(context).pop(updated);
  }

  static const _orange = Color(0xFFFFAD35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const AppBarWidget(title: 'Quản lý quyền'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
            child: Text(
              'Owner: toàn quyền. Editor: chỉnh sửa. Spectator: chỉ xem.',
              style: GoogleFonts.beVietnamPro(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ),
          // Bắt đầu thực hiện phân quyền hạn
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ..._members.asMap().entries.map((e) {
                  final i = e.key;
                  final m = e.value;
                  final isOwner = m.role == 'owner';
                  final roleTextStyle = GoogleFonts.beVietnamPro(
                    color: _orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  );
                  return Card(
                    color: const Color(0xFF2A2A2A),
                    margin: const EdgeInsets.only(bottom: 8),
                    clipBehavior: Clip.none,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        m.email,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        isOwner
                            ? 'Chủ sở hữu'
                            : (m.role == 'editor'
                                  ? 'Có thể chỉnh sửa'
                                  : 'Chỉ xem'),
                        style: GoogleFonts.beVietnamPro(
                          color: _orange,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isOwner
                          ? Text(
                              'Owner',
                              style: roleTextStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: DropdownButton2<String>(
                                value: m.role,
                                items: [
                                  DropdownMenuItem(
                                    value: 'editor',
                                    child: Text(
                                      'Editor',
                                      style: roleTextStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'spectator',
                                    child: Text(
                                      'Spectator',
                                      style: roleTextStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    _members[i] = m.copyWith(role: v);
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 36,
                                  width: 120,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _orange.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  overlayColor:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        Set<WidgetState> states,
                                      ) {
                                        return null;
                                      }),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xFF2A2A2A),
                                  ),
                                  offset: const Offset(0, -4),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(8),
                                    thickness: WidgetStateProperty.all(4),
                                    thumbVisibility: WidgetStateProperty.all(
                                      true,
                                    ),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  iconSize: 20,
                                  iconEnabledColor: _orange,
                                  iconDisabledColor: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: AppButtonWidget(buttonText: 'Lưu thay đổi', onTap: _save),
          ),
        ],
      ),
    );
  }
}
