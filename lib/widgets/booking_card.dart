// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/booking_model.dart';
import '../utils/helpers.dart';
import 'status_badge.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool showInstructorName;
  final bool showUserName;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.showInstructorName = false,
    this.showUserName = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = showInstructorName
        ? booking.instructorName ?? 'Instructor'
        : showUserName
            ? booking.userName ?? 'Student'
            : '';

    final displayAvatar = showInstructorName
        ? booking.instructorAvatar
        : showUserName
            ? booking.userAvatar
            : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TOP ROW ----------
            Row(
              children: [
                if (displayName.isNotEmpty) ...[
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: displayAvatar != null
                        ? NetworkImage(displayAvatar)
                        : null,
                    child: displayAvatar == null
                        ? const Icon(
                            Icons.person,
                            size: 22,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (displayName.isNotEmpty)
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkText,
                          ),
                        ),
                      Text(
                        Helpers.formatDate(booking.bookingDate),
                        style: TextStyle(
                          fontSize: displayName.isNotEmpty ? 13 : 16,
                          color: displayName.isNotEmpty
                              ? AppTheme.greyText
                              : AppTheme.darkText,
                          fontWeight: displayName.isNotEmpty
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: booking.status, small: true),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 12),

            // ---------- DETAILS ROW ----------
            Row(
              children: [
                _buildChip(
                  Icons.access_time,
                  Helpers.formatTime(booking.startTime),
                ),
                const SizedBox(width: 8),
                _buildChip(
                  Icons.timer_outlined,
                  Helpers.formatDuration(booking.duration),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChip(
                    Icons.location_on,
                    booking.location,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.darkText,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
