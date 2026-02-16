// Màn hình hiển thị form để điền thông tin tạo plan mới hoặc chỉnh sửa plan
// Logic xử lý được quản lý bởi PlanViewModel, UI chỉ hiển thị và gọi ViewModel
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/features/plan/viewmodels/plan_view_model.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';
import 'package:travel_app/features/plan/widgets/cover_image_picker_widget.dart';
import 'package:travel_app/features/plan/widgets/member_selector_widget.dart';
import 'package:travel_app/features/plan/widgets/date_range_picker_sheet.dart';

class PlanCreatedFormSheet extends StatefulWidget {
  final PlanModel? initialPlan;

  const PlanCreatedFormSheet({super.key, this.initialPlan});

  @override
  State<PlanCreatedFormSheet> createState() => _PlanCreatedFormSheetState();
}

class _PlanCreatedFormSheetState extends State<PlanCreatedFormSheet> {
  final _destinationController = TextEditingController();
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCreating = false;

  // Ảnh bìa
  String? _coverImageUrl;

  // Danh sách member bao gồm email và avatarUrl
  final List<PlanMember> _members = [];

  bool get _isEditMode => widget.initialPlan != null;
  bool _editPrefillDone = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPlan;
    if (p != null) {
      _titleController.text = p.title;
      _destinationController.text = p.destination;
      _budgetController.text = p.budget > 0
          ? PlanViewModel.formatMoney(p.budget.toStringAsFixed(0))
          : '';
      _startDate = p.startDate;
      _endDate = p.endDate;
      _coverImageUrl = p.imageUrl.isNotEmpty ? p.imageUrl : null;
      _members.addAll(p.members);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditMode &&
        !_editPrefillDone &&
        _startDate != null &&
        _endDate != null) {
      _editPrefillDone = true;
      _dateController.text = _dateRangeDisplay;
    }
  }

  String get _dateRangeDisplay {
    if (_startDate == null || _endDate == null) return '';
    final locale = context.locale.toString();
    final fmt = DateFormat.MMMd(locale);
    return '${fmt.format(_startDate!)} - ${fmt.format(_endDate!)}';
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _titleController.dispose();
    _budgetController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showModalBottomSheet<DateTimeRange>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DateRangePickerSheet(
          initialStart: _startDate,
          initialEnd: _endDate,
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _dateController.text = _dateRangeDisplay;
      });
    }
  }

  // Xử lý format tiền khi nhập
  void _onBudgetChanged(String value) {
    final formatted = PlanViewModel.formatMoney(value);
    if (formatted != value) {
      _budgetController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('plan.error_empty_title'.tr())));
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('plan.error_empty_date'.tr())));
      return;
    }

    setState(() => _isCreating = true);

    final plan = PlanModel(
      id: widget.initialPlan?.id ?? '',
      title: _titleController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      imageUrl: _coverImageUrl ?? '',
      destination: _destinationController.text.trim(),
      budget:
          double.tryParse(_budgetController.text.trim().replaceAll('.', '')) ??
          0,
      members: List.from(_members),
    );

    final vm = context.read<PlanViewModel>();
    if (_isEditMode) {
      final updated = await vm.updatePlan(plan);
      if (mounted) {
        setState(() => _isCreating = false);
        if (updated != null) {
          Navigator.of(context).pop(updated);
        } else if (vm.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(vm.error!)));
        }
      }
    } else {
      final created = await vm.createPlan(plan);
      if (mounted) {
        setState(() => _isCreating = false);
        if (created != null) {
          Navigator.of(context).pop();
        } else if (vm.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(vm.error!)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar để hiển tên của phần appbar
      appBar: AppBarWidget(
        title: _isEditMode ? 'Chỉnh sửa chuyến đi' : 'plan.add_plan_title'.tr(),
        icon: CupertinoIcons.xmark,
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Mục nội dung tên điểm đến
                  AppTextFieldWidget(
                    labelText: 'plan.destination'.tr(),
                    showLabel: true,
                    hintText: 'plan.destination_hint'.tr(),
                    controller: _destinationController,
                  ),
                  const SizedBox(height: 20),
                  // Mục nội dung của tên chuyến đi
                  AppTextFieldWidget(
                    labelText: 'plan.trip_name'.tr(),
                    showLabel: true,
                    hintText: 'plan.trip_name_hint'.tr(),
                    controller: _titleController,
                  ),
                  const SizedBox(height: 20),
                  // Field này là field dùng để chỉnh thời gian
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: AbsorbPointer(
                      child: AppTextFieldWidget(
                        labelText: 'plan.time_range'.tr(),
                        showLabel: true,
                        controller: _dateController,
                        readOnly: true,
                        hintText: 'plan.time_range_hint'.tr(),
                        suffixIcon: Icon(
                          CupertinoIcons.calendar,
                          color: Color(0xFFFF6D00),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Mục nội dung để nhập vào số tiền dự kiến cho chuyến đi
                  AppTextFieldWidget(
                    labelText: 'plan.budget'.tr(),
                    showLabel: true,
                    hintText: 'plan.budget_hint'.tr(),
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: _onBudgetChanged,
                  ),
                  const SizedBox(height: 20),

                  // Ảnh bìa
                  CoverImagePickerWidget(
                    coverImageUrl: _coverImageUrl,
                    onImageChanged: (url) {
                      setState(() => _coverImageUrl = url);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Mục đồng hành để chọn thêm thành viên
                  MemberSelectorWidget(
                    members: _members,
                    onAddPressed: () {
                      MemberSelectorWidget.showSearchSheet(
                        context: context,
                        currentMembers: _members,
                        onConfirm: (selectedUsers) {
                          setState(() {
                            _members.clear();
                            for (final user in selectedUsers) {
                              _members.add(
                                PlanMember(
                                  email: user.email,
                                  avatarUrl: user.avatarUrl ?? '',
                                ),
                              );
                            }
                          });
                        },
                      );
                    },
                    onRemoveMember: (index) {
                      setState(() => _members.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Nút Lên kế hoạch ngay
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: _isCreating
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6D00)),
                  )
                : AppButtonWidget(
                    buttonText: _isEditMode
                        ? 'Lưu thay đổi'
                        : 'plan.create_plan'.tr(),
                    onTap: _handleSave,
                  ),
          ),
        ],
      ),
    );
  }
}
