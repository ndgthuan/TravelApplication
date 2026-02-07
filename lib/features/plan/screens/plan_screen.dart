import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/features/plan/screens/add_plan_screen.dart';
import 'package:travel_app/features/plan/widgets/activity_plan_widget.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Plan",
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),

                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: Icon(
                        Icons.insights,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Đang diễn ra',
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SizedBox(
                      height: 350,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Ảnh full card
                          CachedNetworkImage(
                            imageUrl:
                                'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=600',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                          // Lớp đen mờ gradient (trong suốt trên → đen mờ dưới)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.75),
                                    Colors.black.withValues(alpha: 0.9),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Nội dung nằm trên lớp mờ
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hà Nội - Mùa Thu',
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '10 Th10 - 15 Th10',
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: 2 / 6,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFFAD35),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Ngày 2/6',
                                        style: GoogleFonts.beVietnamPro(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 72,
                                        height: 36,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: 0,
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Color(0xFFFFAD35),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage: NetworkImage(
                                                    'https://i.pravatar.cc/100?img=1',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 14,
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Color(0xFFFFAD35),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage: NetworkImage(
                                                    'https://i.pravatar.cc/100?img=2',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 28,
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Color(0xFFFFAD35),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage: NetworkImage(
                                                    'https://i.pravatar.cc/100?img=3',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Material(
                                        color: Color(0xFFFFAD35),
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ActivityPlanWidget(),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Xem chi tiết',
                                                  style:
                                                      GoogleFonts.beVietnamPro(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Sắp tới",
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Horizontal list cards
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    // Card 1: Lên kế hoạch
                    _buildPlanCard(),
                    SizedBox(width: 10),
                    // Card 2: Đà Nẵng
                    _buildUpcomingCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400',
                      title: 'Đà Nẵng - Hội An',
                      date: '20 Th11 - 25 Th11',
                    ),
                    SizedBox(width: 10),
                    // Card 3: Phú Quốc
                    _buildUpcomingCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1540202403-b7abd6747a18?w=400',
                      title: 'Phú Quốc',
                      date: '20 Th12 - 25 Th12',
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPlanModal(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return Stack(
          children: [
            // Phần blur + tối phía trên (tap để đóng)
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: AnimatedOpacity(
                opacity: curve.value,
                duration: const Duration(milliseconds: 300),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black38),
                ),
              ),
            ),
            // Sheet 80% từ dưới lên
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curve),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: height * 0.9,
                    child: const AddPlanScreen(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Card "Lên kế hoạch cùng hội bạn"
  Widget _buildPlanCard() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showAddPlanModal(context),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/AddPlanImage.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E1E1D),
              ),
              child: Icon(Icons.add, color: Color(0xFFFFAD35), size: 30),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Card upcoming trip
  Widget _buildUpcomingCard({
    required String imageUrl,
    required String title,
    required String date,
  }) {
    return Container(
      width: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Phần ảnh với Shared label và avatars
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Stack(
              clipBehavior: Clip.antiAlias,
              children: [
                // Ảnh
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 137,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: Colors.grey[800],
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),

                // Avatars góc phải
                Positioned(
                  top: 8,
                  right: 8,
                  child: SizedBox(
                    width: 62,
                    height: 28,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFFFAD35),
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/100?img=1',
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFFFAD35),
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/100?img=2',
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 32,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFFFAD35),
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/100?img=3',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Phần thông tin ở dưới
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 4),

                // Date
                Text(
                  date,
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
