import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/features/plan/constants/activity_types_constants.dart';
import 'package:travel_app/features/plan/viewmodels/plan_section_view_model.dart';
import 'package:travel_app/features/plan/widgets/activity_date_picker_sheet.dart';
import 'package:travel_app/features/plan/widgets/activity_location_map_widget.dart';
import 'package:travel_app/features/plan/widgets/activity_time_date_row.dart';
import 'package:travel_app/features/plan/widgets/activity_time_picker_sheet.dart';
import 'package:travel_app/features/plan/widgets/activity_type_chip_widget.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class OngoingPlanSectionScreen extends StatefulWidget {
  const OngoingPlanSectionScreen({
    super.key,
    this.planId,
    this.destination,
    this.planStartDate,
    this.planEndDate,
    this.initialActivity,
  });

  final String? planId;
  final String? destination;
  final DateTime? planStartDate;
  final DateTime? planEndDate;

  // Mở màn ở chế độ sửa pre-fill ở chế độ này
  final PlanActivityModel? initialActivity;

  @override
  State<OngoingPlanSectionScreen> createState() =>
      _OngoingPlanSectionScreenState();
}

class _OngoingPlanSectionScreenState extends State<OngoingPlanSectionScreen> {
  final _mapController = MapController();
  final _activityNameController = TextEditingController();
  final _locationSearchController = TextEditingController();
  final _customActivityTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<PlanSectionViewModel>();
      vm.setPlanId(widget.planId);
      vm.setDestination(widget.destination);
      vm.setPlanDateRange(widget.planStartDate, widget.planEndDate);
      vm.clearPlaceSearch(); // Xoá kết quả khi mở lại màn
      if (widget.initialActivity != null) {
        final a = widget.initialActivity!;
        vm.setEditingActivity(a);
        _activityNameController.text = a.name;
        _locationSearchController.text = a.addressText ?? '';
        if (kActivityTypes.any((e) => e.type == a.type)) {
          vm.setActivityType(a.type);
        } else {
          vm.setActivityType('other');
          _customActivityTypeController.text = a.type;
        }
      } else {
        vm.clearEditing();
      }
    });
  }

  @override
  void dispose() {
    _activityNameController.dispose();
    _locationSearchController.dispose();
    _customActivityTypeController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    final viewModel = context.read<PlanSectionViewModel>();
    final activity = await viewModel.saveActivity(
      _activityNameController.text,
      _customActivityTypeController.text,
      _locationSearchController.text,
    );
    if (!mounted) return;
    if (activity != null) {
      Navigator.of(context).pop(activity);
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      viewModel.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlanSectionViewModel>();
    return Scaffold(
      appBar: AppBarWidget(
        title: viewModel.isEditing ? 'Sửa điểm đến' : 'Thêm điểm đến',
      ),
      backgroundColor: Color(0xFF000000),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  AppTextFieldWidget(
                    labelText: 'Tên hoạt động',
                    showLabel: true,
                    hintText: 'VD: Ăn tối...',
                    labelFontSize: 17,
                    controller: _activityNameController,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Loại hoạt động',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: kActivityTypes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = kActivityTypes[index];
                        return ActivityTypeChipWidget(
                          label: item.label,
                          type: item.type,
                          isSelected: viewModel.activityType == item.type,
                          onTap: () => viewModel.setActivityType(item.type),
                        );
                      },
                    ),
                  ),
                  if (viewModel.activityType == 'other') ...[
                    const SizedBox(height: 16),
                    AppTextFieldWidget(
                      labelText: 'Loại hoạt động (tùy chỉnh)',
                      showLabel: true,
                      hintText: 'VD: Lễ hội, Họp mặt, Chụp ảnh...',
                      labelFontSize: 17,
                      controller: _customActivityTypeController,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Thời gian',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ActivityTimeDateRow(
                    time: viewModel.time,
                    date: viewModel.date,
                    onTapTime: () => showActivityTimePickerSheet(
                      context,
                      initialTime: viewModel.time,
                      onConfirm: viewModel.setTime,
                    ),
                    onTapDate: () => showActivityDatePickerSheet(
                      context,
                      initialDate: viewModel.date,
                      onConfirm: viewModel.setDate,
                      minimumDate: viewModel.planStartDate,
                      maximumDate: viewModel.planEndDate,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Vị trí',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ActivityLocationMapWidget(
                    mapController: _mapController,
                    locationSearchController: _locationSearchController,
                    pinPosition: viewModel.pinPosition,
                    onPinPositionChanged: viewModel.setPinPosition,
                    onSearchQuery: viewModel.searchPlaces,
                    onSelectPlaceResult: (index) {
                      final result = viewModel.selectPlaceResult(index);
                      if (result == null || !mounted) return;
                      _locationSearchController.text = result.displayName;
                      _mapController.move(
                        result.latLng,
                        _mapController.camera.zoom,
                      );
                      FocusScope.of(context).unfocus();
                    },
                    placeSearchResults: viewModel.placeSearchResults,
                    isSearchingLocation: viewModel.isSearchingLocation,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              16,
              0,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: AppButtonWidget(
              buttonText: 'Lưu điểm đến',
              onTap: _saveActivity,
              height: 53,
              isLoading: viewModel.isSaving,
            ),
          ),
        ],
      ),
    );
  }
}
