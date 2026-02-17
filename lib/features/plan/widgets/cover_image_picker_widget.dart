import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/plan/viewmodels/plan_view_model.dart';

// Widget chọn ảnh bìa từ gallery
class CoverImagePickerWidget extends StatefulWidget {
  final String? coverImageUrl;
  final ValueChanged<String?> onImageChanged;

  const CoverImagePickerWidget({
    super.key,
    required this.coverImageUrl,
    required this.onImageChanged,
  });

  @override
  State<CoverImagePickerWidget> createState() => _CoverImagePickerWidgetState();
}

class _CoverImagePickerWidgetState extends State<CoverImagePickerWidget> {
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final vm = context.read<PlanViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _isUploading = true);

    final url = await vm.uploadCoverImage(File(picked.path));

    if (mounted) {
      setState(() => _isUploading = false);
      if (url != null) {
        widget.onImageChanged(url);
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('plan.upload_failed'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'plan.cover_image'.tr(),
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isUploading ? null : _pickImage,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF1C1C1D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.coverImageUrl != null
                      ? Color(0xFFFF6D00)
                      : Color(0xFF333333),
                ),
                image: widget.coverImageUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                          widget.coverImageUrl!,
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _isUploading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6D00),
                      ),
                    )
                  : widget.coverImageUrl == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.photo_on_rectangle,
                          color: Colors.grey[600],
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'plan.pick_image'.tr(),
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              CupertinoIcons.pencil,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
