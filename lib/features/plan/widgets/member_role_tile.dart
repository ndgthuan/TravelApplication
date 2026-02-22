import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/domain/models/plan_model.dart';

class MemberRoleTile extends StatelessWidget {
  final PlanMember member;
  final int index;
  final bool isOwner;
  final VoidCallback onKick;
  final VoidCallback onBan;
  final ValueChanged<String> onRoleChanged;

  const MemberRoleTile({
    super.key,
    required this.member,
    required this.index,
    required this.isOwner,
    required this.onKick,
    required this.onBan,
    required this.onRoleChanged,
  });

  static const _orange = Color(0xFFFF6D00);

  @override
  Widget build(BuildContext context) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          member.email,
          style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          isOwner
              ? 'plan_role.owner_label'.tr()
              : (member.role == 'editor'
                    ? 'plan_role.editor_label'.tr()
                    : 'plan_role.spectator_label'.tr()),
          style: GoogleFonts.beVietnamPro(color: _orange, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isOwner
            ? Text('plan_role.owner'.tr(), style: roleTextStyle)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.person_remove,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: onKick,
                    tooltip: 'plan_role.kick'.tr(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.block,
                      color: Colors.red.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    onPressed: onBan,
                    tooltip: 'plan_role.ban'.tr(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: DropdownButton2<String>(
                      value: member.role,
                      items: [
                        DropdownMenuItem(
                          value: 'editor',
                          child: Text(
                            'plan_role.editor'.tr(),
                            style: roleTextStyle,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'spectator',
                          child: Text(
                            'plan_role.spectator'.tr(),
                            style: roleTextStyle,
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) onRoleChanged(v);
                      },
                      buttonStyleData: ButtonStyleData(
                        height: 36,
                        width: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _orange.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        overlayColor: WidgetStateProperty.resolveWith<Color?>(
                          (_) => null,
                        ),
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
                          thumbVisibility: WidgetStateProperty.all(true),
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
                ],
              ),
      ),
    );
  }
}
