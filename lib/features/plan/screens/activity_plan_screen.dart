import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/features/plan/screens/plan_section_screen.dart';
import 'package:travel_app/features/plan/screens/plan_role_management_screen.dart';
import 'package:travel_app/features/plan/viewmodels/activity_plan_view_model.dart';
import 'package:travel_app/features/plan/widgets/activity_plan_app_bar.dart';
import 'package:travel_app/features/plan/widgets/activity_plan_map_layer.dart';
import 'package:travel_app/features/plan/widgets/activity_plan_sheet.dart';
import 'package:travel_app/features/plan/widgets/travel_agent_chat_sheet.dart';
import 'package:travel_app/features/plan/widgets/plan_created_form_sheet.dart';

// Màn hình chi tiết chuyến đi
class ActivityPlanScreen extends StatefulWidget {
  final PlanModel plan;

  const ActivityPlanScreen({super.key, required this.plan});

  @override
  State<ActivityPlanScreen> createState() => _ActivityPlanScreenState();
}

class _ActivityPlanScreenState extends State<ActivityPlanScreen> {
  final _mapController = MapController();
  StreamSubscription<void>? _remoteUpdateSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ActivityPlanViewModel>();
      vm.loadPlan();
      _remoteUpdateSub = vm.onRemoteUpdate.listen((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'plan.updated_by_member'.tr(),
                style: GoogleFonts.beVietnamPro(fontSize: 14),
              ),
              backgroundColor: const Color(0xFF2A2A2A),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _remoteUpdateSub?.cancel();
    super.dispose();
  }

  void _fitMapToCurrentAndNext() {
    if (!mounted) return;
    final vm = context.read<ActivityPlanViewModel>();
    final points = vm.routePoints;
    var currentIndex = vm.mapCurrentIndex;
    if (points.isEmpty) return;
    // Khi tất cả activities đã check-in, mapCurrentIndex có thể == points.length.
    // Clamp lại về phần tử cuối để tránh out-of-range.
    if (currentIndex >= points.length) {
      currentIndex = points.length - 1;
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomPadding = screenHeight * 0.52;

    if (currentIndex + 1 < points.length) {
      final bounds = LatLngBounds.fromPoints([
        points[currentIndex],
        points[currentIndex + 1],
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: EdgeInsets.fromLTRB(50, 80, 50, bottomPadding),
        ),
      );
    } else {
      _mapController.move(points[currentIndex], 17);
    }
  }

  void _fitMapToInitialBounds() {
    if (!mounted) return;
    final vm = context.read<ActivityPlanViewModel>();
    final points = vm.routePoints;
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 17);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    final screenHeight = MediaQuery.sizeOf(context).height;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.fromLTRB(50, 80, 50, screenHeight * 0.52),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityPlanViewModel>();

    if (vm.isLoading && vm.routePoints.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF000000),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6D00)),
        ),
      );
    }

    if (vm.error != null && vm.routePoints.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              vm.error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ActivityPlanMapLayer(
            mapController: _mapController,
            routePoints: vm.routePoints,
            routeSegments: vm.routeSegments,
            currentIndex: vm.mapCurrentIndex,
            isCheckedInByRoutePoint: vm.checkedInByRoutePoint,
            fallbackCenter: const LatLng(21.028, 105.853),
            onMapReady: () {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _fitMapToCurrentAndNext();
              });
            },
          ),
          ActivityPlanAppBar(
            title: vm.plan.title,
            presenceSubtitle: vm.viewerNames.isEmpty
                ? null
                : '${vm.viewerNames.join(', ')} đang trong chuyến đi',
            onMenu: vm.currentUserRole == 'owner'
                ? () => _showAppBarMenu(context, vm)
                : null,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.25,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              final role = vm.currentUserRole;
              final isSpectator = role == 'spectator';
              return ActivityPlanSheet(
                plan: vm.plan,
                activities: vm.activities,
                currentIndex: vm.currentIndex,
                scrollController: scrollController,
                onFitMap: vm.routePoints.isEmpty
                    ? null
                    : _fitMapToInitialBounds,
                onCheckIn: () => vm.checkIn(),
                onUncheckIn: (activity) => vm.uncheckIn(activity),
                showAddButton: !isSpectator,
                showEditDelete: !isSpectator,
                onAddTap: isSpectator ? null : () async {
                  await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => OngoingPlanSectionScreen(
                        planId: vm.plan.id,
                        planOwnerId: vm.plan.ownerId,
                        destination: vm.plan.destination,
                        planStartDate: vm.plan.startDate,
                        planEndDate: vm.plan.endDate,
                      ),
                    ),
                  );
                  if (mounted) vm.loadPlan();
                },
                onEditActivity: isSpectator ? null : (activity) async {
                  await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => OngoingPlanSectionScreen(
                        planId: vm.plan.id,
                        planOwnerId: vm.plan.ownerId,
                        destination: vm.plan.destination,
                        planStartDate: vm.plan.startDate,
                        planEndDate: vm.plan.endDate,
                        initialActivity: activity,
                      ),
                    ),
                  );
                  if (mounted) vm.loadPlan();
                },
                onDeleteActivity: isSpectator ? null : (activity) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await vm.deleteActivity(activity.id);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'plan.activity_deleted'.tr() : 'plan.delete_failed'.tr()),
                    ),
                  );
                },
              );
            },
          ),
          if (vm.currentUserRole != 'spectator')
            Positioned(
              right: 20,
              bottom: 24,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (ctx) =>
                        TravelAgentChatSheet(plan: vm.plan, viewModel: vm),
                  );
                },
                child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2A2A2A),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'lib/assets/images/chatbot.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //=====================================================================//
  //                          HELPER FUNCTION                            //
  //=====================================================================//
  void _showAppBarMenu(BuildContext context, ActivityPlanViewModel vm) {
    final role = vm.currentUserRole;
    final isOwner = role == 'owner';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwner)
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFFFF6D00)),
                  title: Text(
                    'plan.edit_trip'.tr(),
                    style: GoogleFonts.beVietnamPro(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openEditPlan(ctx, vm.plan);
                  },
                ),
              if (isOwner)
                ListTile(
                  leading: const Icon(Icons.people, color: Color(0xFFFF6D00)),
                  title: Text(
                    'plan.manage_roles'.tr(),
                    style: GoogleFonts.beVietnamPro(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openRoleManagement(ctx, vm.plan);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditPlan(BuildContext context, PlanModel plan) {
    final vm = context.read<ActivityPlanViewModel>();
    Navigator.of(context)
        .push<PlanModel>(
          MaterialPageRoute(
            builder: (_) => PlanCreatedFormSheet(initialPlan: plan),
          ),
        )
        .then((updatedPlan) {
          if (!mounted || updatedPlan == null) return;
          vm.updatePlan(updatedPlan);
        });
  }

  void _openRoleManagement(BuildContext context, PlanModel plan) {
    final vm = context.read<ActivityPlanViewModel>();
    Navigator.of(context)
        .push<PlanModel>(
          MaterialPageRoute(
            builder: (_) => PlanRoleManagementScreen(plan: plan),
          ),
        )
        .then((updatedPlan) {
          if (!mounted || updatedPlan == null) return;
          vm.updatePlan(updatedPlan);
        });
  }
}
