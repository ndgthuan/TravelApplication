import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/domain/models/user_model.dart';

// Bottom sheet tìm kiếm và chọn member từ danh sách users
class MemberSearchSheet extends StatefulWidget {
  final List<UserModel> availableUsers;
  final Set<String> selectedEmails;
  final void Function(List<UserModel> selectedUsers) onConfirm;

  const MemberSearchSheet({
    super.key,
    required this.availableUsers,
    required this.selectedEmails,
    required this.onConfirm,
  });

  @override
  State<MemberSearchSheet> createState() => _MemberSearchSheetState();
}

class _MemberSearchSheetState extends State<MemberSearchSheet> {
  final _searchController = TextEditingController();
  late Set<String> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedEmails);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> get _filteredUsers {
    if (_query.isEmpty) return widget.availableUsers;
    final q = _query.toLowerCase();
    return widget.availableUsers
        .where(
          (u) =>
              u.email.toLowerCase().contains(q) ||
              u.name.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'plan.select_companions'.tr(),
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final selectedUsers = widget.availableUsers
                        .where((u) => _selected.contains(u.email))
                        .toList();
                    widget.onConfirm(selectedUsers);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '${'plan.done'.tr()} (${_selected.length})',
                    style: GoogleFonts.beVietnamPro(
                      color: Color(0xFFFFAD35),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.beVietnamPro(color: Colors.white),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'plan.search_member_hint'.tr(),
                hintStyle: GoogleFonts.beVietnamPro(color: Colors.grey[600]),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: Colors.grey[600],
                ),
                filled: true,
                fillColor: Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // User list
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Text(
                      'plan.no_user_found'.tr(),
                      style: GoogleFonts.beVietnamPro(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final isSelected = _selected.contains(user.email);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[800],
                          backgroundImage:
                              user.avatarUrl != null &&
                                  user.avatarUrl!.isNotEmpty
                              ? CachedNetworkImageProvider(user.avatarUrl!)
                              : null,
                          child:
                              user.avatarUrl == null || user.avatarUrl!.isEmpty
                              ? Text(
                                  user.email[0].toUpperCase(),
                                  style: GoogleFonts.beVietnamPro(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          user.name.isNotEmpty ? user.name : user.email,
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: user.name.isNotEmpty
                            ? Text(
                                user.email,
                                style: GoogleFonts.beVietnamPro(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              )
                            : null,
                        trailing: isSelected
                            ? Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                color: Color(0xFFFFAD35),
                              )
                            : Icon(
                                CupertinoIcons.circle,
                                color: Colors.grey[600],
                              ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selected.remove(user.email);
                            } else {
                              _selected.add(user.email);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
