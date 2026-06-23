import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'avatar_widget.dart';

class AvatarUploader extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool isLoading;
  final VoidCallback onTap;

  const AvatarUploader({
    super.key,
    this.imageUrl,
    this.radius = 55,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AvatarWidget(
          imageUrl: imageUrl,
          radius: radius,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isLoading ? null : onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
