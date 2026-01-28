import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:travel_app/features/home/models/destination_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_app/shared/widgets/heart_button_widget.dart';

class SlideCardWidget extends StatefulWidget {
  final PageController controller;
  final List<Destination> destinations;
  final int length;
  final Function(String name)? onHeartTap;
  final bool Function(String name) isSaved;

  const SlideCardWidget({
    super.key,
    required this.controller,
    required this.length,
    required this.destinations,
    required this.isSaved,
    this.onHeartTap,
  });

  @override
  State<SlideCardWidget> createState() => _SlideCardWidgetState();
}

class _SlideCardWidgetState extends State<SlideCardWidget> {
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(Duration(milliseconds: 4000), (timer) {
      widget.controller.nextPage(
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PageView để slide ảnh
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: widget.controller,
            onPageChanged: (pageIndex) {
              setState(() {
                _currentPage = pageIndex % widget.length;
              });
            },
            itemBuilder: (context, pageIndex) {
              final index = pageIndex % widget.length;
              final destination = widget.destinations[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Stack(
                  children: [
                    // 1. Ảnh nền
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: destination.imagePath,
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFF2A2A2A),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFAD35),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFF2A2A2A),
                          child: const Icon(
                            CupertinoIcons.photo,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    // 2. Lớp đen mờ
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. Thông tin địa điểm
                    Positioned(
                      bottom: 15,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destination.country,
                                style: GoogleFonts.beVietnamPro(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: 250,
                                child: Text(
                                  destination.name,
                                  style: GoogleFonts.beVietnamPro(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                destination.city,
                                style: GoogleFonts.beVietnamPro(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.star_fill,
                                    color: Color(0xFFFFAD35),
                                    size: 15,
                                  ),
                                  Text(
                                    destination.rating.toString(),
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "(${destination.reviewCount} reviews)",
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.grey.shade300,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  border: BoxBorder.all(
                                    color: Color(0XFF1E1E1E),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.shade800,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    destination.category,
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Icon trái tim ở góc phải
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: HeartButtonWidget(
                          isSaved: widget.isSaved(destination.name),
                          onTap: () =>
                              widget.onHeartTap?.call(destination.name),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 15),

        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.length,
            (index) => GestureDetector(
              onTap: () {
                final currentActualPage = widget.controller.page?.round() ?? 0;
                final targetPage = currentActualPage - (_currentPage - index);
                widget.controller.animateToPage(
                  targetPage,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Color(0xFFFFAD35)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
