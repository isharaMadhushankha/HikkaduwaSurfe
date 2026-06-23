// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData placeholderIcon;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.placeholderIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? AppTheme.primaryColor.withOpacity(0.1),
      backgroundImage:
          imageUrl != null ? NetworkImage(imageUrl!) : null,
      onBackgroundImageError: imageUrl != null
          ? (_, _) {}
          : null,
      child: imageUrl == null
          ? Icon(
              placeholderIcon,
              size: radius * 0.9,
              color: AppTheme.primaryColor,
            )
          : null,
    );
  }
}
