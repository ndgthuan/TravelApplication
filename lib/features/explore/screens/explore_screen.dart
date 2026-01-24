import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/features/account/widgets/simple_divider_widget.dart';
import 'package:travel_app/features/explore/screens/save_screen.dart';
import 'package:travel_app/features/home/widgets/heart_button_widget.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explore trip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Text(
                    "Khám phá",
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),

                GestureDetector(
                  onTapDown: (_) => setState(() => isLoading = true),
                  onTapUp: (_) => setState(() => isLoading = false),
                  onTapCancel: () => setState(() => isLoading = false),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) => SaveScreen()),
                    );
                  },
                  child: AnimatedScale(
                    scale: isLoading ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        CupertinoIcons.arrow_down_to_line_alt,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            AppTextFieldWidget(
              prefixIcon: Icons.search,
              hintText: "Enter your destination...",
              horizontalPadding: 10,
              suffixIcon: Icon(
                CupertinoIcons.xmark_circle,
                color: Colors.grey[600],
              ),
            ),

            // Phân loại
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Row(
                children: [
                  // Các loại danh mục
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tên danh mục
                        Text(
                          'Hotel',
                          style: GoogleFonts.beVietnamPro(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tên danh mục
                        Text(
                          'Hotel',
                          style: GoogleFonts.beVietnamPro(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tên danh mục
                        Text(
                          'Hotel',
                          style: GoogleFonts.beVietnamPro(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tên danh mục
                        Text(
                          'Hotel',
                          style: GoogleFonts.beVietnamPro(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tên danh mục
                        Text(
                          'Hotel',
                          style: GoogleFonts.beVietnamPro(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    "Địa điểm du lịch",
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: SimpleDividerWidget(),
                    ),
                  ),
                  Icon(CupertinoIcons.slider_horizontal_3, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Masonry Grid View
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.custom(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    repeatPattern: QuiltedGridRepeatPattern
                        .inverted, // Lặp lại pattern và đảo ngược để đỡ nhàm chán
                    pattern: [
                      // Định nghĩa mẫu xếp gạch (Pattern)
                      QuiltedGridTile(5, 2),
                      QuiltedGridTile(3, 2),
                      QuiltedGridTile(2, 2),
                    ],
                  ),

                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Ảnh nền
                            CachedNetworkImage(
                              imageUrl:
                                  'https://picsum.photos/500/500?random=$index',
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[800]),
                              errorWidget: (context, url, error) =>
                                  Container(color: Colors.grey[800]),
                            ),

                            Positioned(
                              top: 10,
                              right: 10,
                              child: HeartButtonWidget(isSaved: false),
                            ),

                            // Lớp Gradient đen mờ từ dưới lên (Chèn vào đây)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 120, // Chiều cao của lớp mờ
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(
                                        alpha: 0.8,
                                      ), // Đen đậm ở dưới
                                      Colors.transparent, // Trong suốt ở trên
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Thông tin
                            Positioned(
                              bottom: 8,
                              left: 8,
                              right:
                                  8, // Thêm right để giới hạn chiều ngang nếu tên dài
                              child: Column(
                                mainAxisSize:
                                    MainAxisSize.min, // Ôm sát nội dung
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tên địa điểm (Có bóng đổ để dễ đọc trên nền ảnh)
                                  Text(
                                    "Santorini Island", // Tên giả định
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 2.0,
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // Số sao và comment
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize
                                          .min, // Chỉ rộng bằng nội dung
                                      children: [
                                        const Icon(
                                          CupertinoIcons.star_fill,
                                          color: Color(0xFFFFAD35),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "4.8",
                                          style: GoogleFonts.beVietnamPro(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "(124)",
                                          style: GoogleFonts.beVietnamPro(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: 15, // Số lượng hình demo
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
