// Các thẻ destination card tái sử dụng
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/domain/models/destination_model.dart';
import 'package:travel_app/shared/widgets/heart_button_widget.dart';

class ExploreDestinationCard extends StatelessWidget {
  final DestinationModel item;
  final bool isSaved;
  final VoidCallback onHeartTap;

  const ExploreDestinationCard({
    super.key,
    required this.item,
    required this.isSaved,
    required this.onHeartTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          item.imageUrl.trim().isEmpty
              ? Container(color: Colors.grey[800])
              : CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[800]),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey[800]),
                ),
          Positioned(
            top: 10,
            right: 10,
            child: HeartButtonWidget(isSaved: isSaved, onTap: onHeartTap),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
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
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 2.0,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.star_fill,
                        color: Color(0xFFFFAD35),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.rating,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${item.reviewCount})",
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white.withValues(alpha: 0.8),
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
  }
}
