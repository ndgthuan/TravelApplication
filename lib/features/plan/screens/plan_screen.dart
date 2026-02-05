import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                        Icons.bar_chart_rounded,
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
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      // Phần ảnh ở trên
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=600',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: Colors.grey[800],
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),

                      // Phần thông tin ở dưới
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            // Row chứa title + avatars
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cột trái: Title + Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hà Nội - Mùa Thu',
                                        style: GoogleFonts.beVietnamPro(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '10 Th10 - 15 Th10',
                                        style: GoogleFonts.beVietnamPro(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Cột phải: Avatars + Invite
                                Column(
                                  children: [
                                    // Stack avatars
                                    SizedBox(
                                      width: 90,
                                      height: 35,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: -7,
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundImage: NetworkImage(
                                                'https://i.pravatar.cc/100?img=1',
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 15,
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundImage: NetworkImage(
                                                'https://i.pravatar.cc/100?img=2',
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 34,
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundImage: NetworkImage(
                                                'https://i.pravatar.cc/100?img=3',
                                              ),
                                            ),
                                          ),
                                          // Nút + Invite
                                          Positioned(
                                            left: 54,
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Color(
                                                0xFFFFAD35,
                                              ),
                                              child: Icon(
                                                Icons.person_add_alt_1,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Invite',
                                      style: GoogleFonts.beVietnamPro(
                                        color: Color(0xFFFFAD35),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            // Progress bar
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.33, // 2/6 = 33%
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFAD35),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            // Row chứa Ngày 2/6
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Ngày 2/6',
                                  style: GoogleFonts.beVietnamPro(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),

                            // Nút Xem chi tiết
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFFFAD35)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Xem chi tiết',
                                  style: GoogleFonts.beVietnamPro(
                                    color: Color(0xFFFFAD35),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

  // Card "Lên kế hoạch cùng hội bạn"
  Widget _buildPlanCard() {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFAD35), Color(0xFFFF8C00)],
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
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần ảnh với Shared label và avatars
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Stack(
              children: [
                // Ảnh
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 120,
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
                    width: 60,
                    height: 24,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/100?img=1',
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/100?img=2',
                            ),
                          ),
                        ),
                        Positioned(
                          left: 32,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/100?img=3',
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
            padding: const EdgeInsets.all(12),
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
