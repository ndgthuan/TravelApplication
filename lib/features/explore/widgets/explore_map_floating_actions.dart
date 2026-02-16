// Vẽ các trạng thái của nút bấm ở mapScreen
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ExploreMapFloatingActions extends StatefulWidget {
  final VoidCallback onFitBounds;
  final VoidCallback onBookmarkTap;
  final bool canFitBounds;

  const ExploreMapFloatingActions({
    super.key,
    required this.onFitBounds,
    required this.onBookmarkTap,
    required this.canFitBounds,
  });

  @override
  State<ExploreMapFloatingActions> createState() =>
      _ExploreMapFloatingActionsState();
}

class _ExploreMapFloatingActionsState extends State<ExploreMapFloatingActions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.canFitBounds ? widget.onFitBounds : null,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.my_location,
              color: widget.canFitBounds
                  ? const Color(0xFFFFAD35)
                  : Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.onBookmarkTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
            ),
            child: const Icon(
              CupertinoIcons.bookmark_fill,
              color: Color(0xFFFFAD35),
            ),
          ),
        ),
      ],
    );
  }
}
