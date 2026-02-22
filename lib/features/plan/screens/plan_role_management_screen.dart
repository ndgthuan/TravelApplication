import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/domain/models/user_model.dart';
import 'package:travel_app/features/plan/viewmodels/plan_view_model.dart';
import 'package:travel_app/features/plan/widgets/member_role_tile.dart';
import 'package:travel_app/features/plan/widgets/member_selector_widget.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';

class PlanRoleManagementScreen extends StatefulWidget {
  final PlanModel plan;

  const PlanRoleManagementScreen({super.key, required this.plan});

  @override
  State<PlanRoleManagementScreen> createState() => _PlanRoleManagementScreenState();
}

class _PlanRoleManagementScreenState extends State<PlanRoleManagementScreen> {
  late List<PlanMember> _members;
  late List<String> _bannedEmails;

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.plan.members);
    _bannedEmails = List.from(widget.plan.bannedEmails);
  }

  Future<void> _kickMember(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('plan_role.remove_title'.tr(), style: const TextStyle(color: Colors.white)),
        content: Text(
          'plan_role.remove_confirm'.tr(namedArgs: {'email': _members[index].email}),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('plan_role.cancel'.tr())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('plan.delete'.tr(), style: const TextStyle(color: Color(0xFFFF6D00)))),
        ],
      ),
    );
    if (ok == true && mounted) setState(() => _members.removeAt(index));
  }

  Future<void> _banMember(int index) async {
    final email = _members[index].email;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('plan_role.ban_title'.tr(), style: const TextStyle(color: Colors.white)),
        content: Text(
          'plan_role.ban_confirm'.tr(namedArgs: {'email': email}),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('plan_role.cancel'.tr())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('plan_role.ban_btn'.tr(), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        _members.removeAt(index);
        if (!_bannedEmails.contains(email)) _bannedEmails.add(email);
      });
    }
  }

  void _openAddMemberSheet() {
    MemberSelectorWidget.showSearchSheet(
      context: context,
      currentMembers: _members,
      bannedEmails: _bannedEmails,
      onConfirm: (List<UserModel> selectedUsers) async {
        final messenger = ScaffoldMessenger.of(context);
        final vm = context.read<PlanViewModel>();
        final currentEmails = _members.map((m) => m.email).toSet();
        final newInvites = selectedUsers.where((u) => !currentEmails.contains(u.email)).toList();
        if (newInvites.isEmpty) return;
        for (final toUser in newInvites) {
          await vm.sendInvite(widget.plan, toUser);
        }
        if (mounted) {
          final names = newInvites.map((u) => u.name.isNotEmpty ? u.name : u.email).join(', ');
          messenger.showSnackBar(
            SnackBar(
              content: Text('plan_role.invites_sent'.tr(namedArgs: {'names': names}), style: GoogleFonts.beVietnamPro(fontSize: 14)),
              backgroundColor: const Color(0xFF2A2A2A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Future<void> _save() async {
    final vm = context.read<PlanViewModel>();
    try {
      final updated = await vm.updatePlan(widget.plan.copyWith(members: _members, bannedEmails: _bannedEmails));
      if (!mounted) return;
      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? 'plan_role.save_error'.tr(), style: GoogleFonts.beVietnamPro(fontSize: 14)),
            backgroundColor: const Color(0xFF2A2A2A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString(), style: GoogleFonts.beVietnamPro(fontSize: 14)), backgroundColor: const Color(0xFF2A2A2A), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text('plan_role.title'.tr(), style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 22)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(CupertinoIcons.back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF6D00)), onPressed: _openAddMemberSheet, tooltip: 'plan_role.add_member'.tr()),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
            child: Text('plan_role.hint'.tr(), style: GoogleFonts.beVietnamPro(color: Colors.white54, fontSize: 13)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _members.length,
              itemBuilder: (context, i) {
                final m = _members[i];
                return MemberRoleTile(
                  member: m,
                  index: i,
                  isOwner: m.role == 'owner',
                  onKick: () => _kickMember(i),
                  onBan: () => _banMember(i),
                  onRoleChanged: (v) => setState(() => _members[i] = m.copyWith(role: v)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: AppButtonWidget(buttonText: 'plan_role.save'.tr(), onTap: _save),
          ),
        ],
      ),
    );
  }
}
