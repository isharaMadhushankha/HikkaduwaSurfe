// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../utils/helpers.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  Color _getColor() {
    switch (status) {
      case 'pending':
        return AppTheme.pendingColor;
      case 'confirmed':
        return AppTheme.successColor;
      case 'completed':
        return AppTheme.primaryColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.greyText;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case 'pending':
        return Icons.hourglass_top;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 10 : 16,
        vertical: small ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: small ? 14 : 18,
            color: color,
          ),
          SizedBox(width: small ? 4 : 6),
          Text(
            Helpers.statusDisplay(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: small ? 11 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
