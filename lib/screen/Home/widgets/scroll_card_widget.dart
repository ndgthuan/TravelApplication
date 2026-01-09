import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../models/destination_model.dart';

class ScrollCardWidget extends StatefulWidget {
  final List<RecommendDestination> recommendDestination;
  final int index;
  const ScrollCardWidget({
    super.key,
    required this.recommendDestination,
    required this.index,
  });

  @override
  State<ScrollCardWidget> createState() => _ScrollCardWidgetState();
}

Widget _buildStars(double rating) {
  return Row(
    children: List.generate(5, (index) {
      if (index < rating.floor()) {
        return Icon(Icons.star, color: Colors.amber, size: 15);
      } else if (index < rating) {
        return Icon(Icons.star_half, color: Colors.amber, size: 15);
      } else {
        return Icon(Icons.star_border, color: Colors.amber, size: 15);
      }
    }),
  );
}

class _ScrollCardWidgetState extends State<ScrollCardWidget> {
  bool isPressed = false;
  bool isFavourite = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFF1E1E1E),
            ),

            child: Row(
              children: [
                // Bức hình của địa điểm đề xuất
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 105,
                    width: 105,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(
                          widget.recommendDestination[widget.index].imagePath,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Các dòng chữ và đánh giá
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      bottom: 20,
                      left: 5,
                      right: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên địa điểm
                        Padding(
                          padding: const EdgeInsets.only(right: 65),
                          child: Text(
                            widget.recommendDestination[widget.index].name,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Địa chỉ địa điểm
                        Row(
                          children: [
                            // Icon địa điểm
                            Icon(
                              Icons.location_on,
                              color: Color(0xFFFFAD35),
                              size: 13,
                            ),
                            Expanded(
                              child: Text(
                                widget
                                    .recommendDestination[widget.index]
                                    .address,
                                style: GoogleFonts.beVietnamPro(
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          // Số sao
                          children: [
                            Text(
                              widget.recommendDestination[widget.index].rating
                                  .toString(),
                              style: GoogleFonts.beVietnamPro(
                                color: Color(0xFFFFAD35),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Star
                            _buildStars(
                              widget.recommendDestination[widget.index].rating,
                            ),
                            const SizedBox(width: 5),
                            // Loại điểm đến
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  widget
                                      .recommendDestination[widget.index]
                                      .category,
                                  style: GoogleFonts.beVietnamPro(
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
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

        // Icon trái tim ở góc phải
        Positioned(
          top: 0,
          right: 5, // Căn theo padding của card
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFFFAD35), // Cùng màu với card
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), // Bo góc trên phải (theo card)
                bottomLeft: Radius.circular(
                  20,
                ), // Bo góc dưới trái (tạo hình tab)
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF000000).withValues(alpha: 0.3),
                  offset: Offset(0, 6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: GestureDetector(
              onTapDown: (_) => setState(() => isPressed = true),
              onTapUp: (_) => setState(() => isPressed = false),
              onTapCancel: () => setState(() => isPressed = false),
              onTap: () {
                setState(() {
                  isFavourite = !isFavourite;
                });
              },
              child: AnimatedScale(
                scale: isPressed ? 0.9 : 1.0,
                duration: Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                child: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
