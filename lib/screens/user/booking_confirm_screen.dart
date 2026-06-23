// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../utils/helpers.dart';

class BookingConfirmScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingConfirmScreen({
    super.key,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ---------- SUCCESS ICON ----------
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: AppTheme.successColor,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Booking Submitted!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your booking request has been sent.\nWaiting for instructor confirmation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.greyText,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // ---------- BOOKING DETAILS ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.person,
                      'Instructor',
                      bookingData['instructorName'] ?? 'N/A',
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.calendar_month,
                      'Date',
                      Helpers.formatDateFull(bookingData['date']),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.access_time,
                      'Time',
                      Helpers.formatTime(bookingData['time']),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.timer_outlined,
                      'Duration',
                      Helpers.formatDuration(bookingData['duration']),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.location_on,
                      'Location',
                      bookingData['location'] ?? 'N/A',
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.surfing,
                      'Level',
                      Helpers.surfLevelDisplay(bookingData['surfLevel']),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------- STATUS BADGE ----------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.pendingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_top,
                      size: 18,
                      color: AppTheme.pendingColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Status: Pending',
                      style: TextStyle(
                        color: AppTheme.pendingColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ---------- BUTTONS ----------
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/user'),
                  child: const Text('Back to Home'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/user');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View My Bookings',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.greyText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
