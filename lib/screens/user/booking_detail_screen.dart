// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/review_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookingById(widget.bookingId);
      context.read<ReviewProvider>().checkHasReview(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    final booking = bookingProvider.selectedBooking;

    if (bookingProvider.isLoading || booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/user'),
          ),
        ),
        body: const LoadingWidget(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/user'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- STATUS ----------
            Center(child: StatusBadge(status: booking.status)),

            const SizedBox(height: 24),

            // ---------- INSTRUCTOR INFO ----------
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: booking.instructorAvatar != null
                        ? NetworkImage(booking.instructorAvatar!)
                        : null,
                    child: booking.instructorAvatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.instructorName ?? 'Instructor',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Surf Instructor',
                          style: TextStyle(
                            color: AppTheme.greyText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.go(
                        '/user/instructor/${booking.instructorId}',
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRow(
                    Icons.calendar_month,
                    'Date',
                    Helpers.formatDateFull(booking.bookingDate),
                  ),
                  const SizedBox(height: 14),
                  _buildRow(
                    Icons.access_time,
                    'Time',
                    Helpers.formatTime(booking.startTime),
                  ),
                  const SizedBox(height: 14),
                  _buildRow(
                    Icons.timer_outlined,
                    'Duration',
                    Helpers.formatDuration(booking.duration),
                  ),
                  const SizedBox(height: 14),
                  _buildRow(
                    Icons.location_on,
                    'Location',
                    booking.location,
                  ),
                  const SizedBox(height: 14),
                  _buildRow(
                    Icons.surfing,
                    'Level',
                    Helpers.surfLevelDisplay(booking.surfLevel),
                  ),
                  if (booking.notes != null &&
                      booking.notes!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildRow(
                      Icons.note,
                      'Notes',
                      booking.notes!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ---------- BOOKED ON ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppTheme.greyText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Booked on ${Helpers.formatDateTime(booking.createdAt)}',
                    style: const TextStyle(
                      color: AppTheme.greyText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ---------- WRITE REVIEW (only for completed) ----------
            if (booking.status == 'completed' && !reviewProvider.hasReview)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/user/review/${booking.id}');
                  },
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Write a Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                  ),
                ),
              ),

            if (booking.status == 'completed' && reviewProvider.hasReview)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Review submitted!',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
