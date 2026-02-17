import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:travel_app/domain/models/home_destination_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_app/shared/widgets/heart_button_widget.dart';

class ScrollCardWidget extends StatelessWidget {
  final List<HomeDestination> destinations;
  final int index;
  final Function(String name)? onHeartTap;
  final bool Function(String name) isSaved;

  const ScrollCardWidget({
    super.key,
    required this.destinations,
    required this.index,
    required this.isSaved,
    this.onHeartTap,
  });

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(
            CupertinoIcons.star_fill,
            color: Color(0xFFFF8F00),
            size: 12,
          );
        } else if (index < rating) {
          return Icon(
            CupertinoIcons.star_lefthalf_fill,
            color: Color(0xFFFF8F00),
            size: 12,
          );
        } else {
          return Icon(CupertinoIcons.star, color: Color(0xFFFF8F00), size: 12);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dest = destinations[index];
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: dest.imagePath.trim().isEmpty
                          ? Container(
                              color: const Color(0xFF2A2A2A),
                              child: const Icon(
                                CupertinoIcons.photo,
                                color: Colors.grey,
                                size: 30,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: dest.imagePath,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFF2A2A2A),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFF6D00),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF2A2A2A),
                                child: const Icon(
                                  CupertinoIcons.photo,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              ),
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
                            dest.name,
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
                            Icon(
                              CupertinoIcons.location_fill,
                              color: Color(0xFFFF6D00),
                              size: 13,
                            ),
                            Expanded(
                              child: Text(
                                dest.address,
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
                          children: [
                            Text(
                              dest.rating.toString(),
                              style: GoogleFonts.beVietnamPro(
                                color: Color(0xFFFF6D00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            _buildStars(dest.rating),
                            const SizedBox(width: 5),
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
                                  dest.category,
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
          right: 5,
          child: SizedBox(
            width: 50,
            height: 50,
            child: HeartButtonWidget(
              isSaved: isSaved(dest.name),
              onTap: () => onHeartTap?.call(dest.name),
            ),
          ),
        ),
      ],
    );
  }
}
