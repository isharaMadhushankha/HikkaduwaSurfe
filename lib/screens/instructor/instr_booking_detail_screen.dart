// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';

class InstrBookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const InstrBookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<InstrBookingDetailScreen> createState() =>
      _InstrBookingDetailScreenState();
}

class _InstrBookingDetailScreenState
    extends State<InstrBookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookingById(widget.bookingId);
    });
  }

  Future<void> _confirmBooking() async {
    final userId = context.read<AuthProvider>().userId;
    final success = await context.read<BookingProvider>().confirmBooking(
          bookingId: widget.bookingId,
          instructorId: userId,
        );

    if (success && mounted) {
      // Reload booking detail
      context.read<BookingProvider>().loadBookingById(widget.bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? The student will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cancel Booking',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final userId = context.read<AuthProvider>().userId;
      final success = await context.read<BookingProvider>().cancelBooking(
            bookingId: widget.bookingId,
            instructorId: userId,
          );

      if (success && mounted) {
        context
            .read<BookingProvider>()
            .loadBookingById(widget.bookingId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _completeBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Session'),
        content: const Text(
          'Mark this session as completed? The student will be able to leave a review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final userId = context.read<AuthProvider>().userId;
      final success =
          await context.read<BookingProvider>().completeBooking(
                bookingId: widget.bookingId,
                instructorId: userId,
              );

      if (success && mounted) {
        context
            .read<BookingProvider>()
            .loadBookingById(widget.bookingId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session marked as completed!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final booking = bookingProvider.selectedBooking;

    if (bookingProvider.isLoading || booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/instructor'),
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
          onPressed: () => context.go('/instructor'),
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

            // ---------- STUDENT INFO ----------
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
                    backgroundImage: booking.userAvatar != null
                        ? NetworkImage(booking.userAvatar!)
                        : null,
                    child: booking.userAvatar == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.userName ?? 'Student',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level: ${Helpers.surfLevelDisplay(booking.surfLevel)}',
                          style: const TextStyle(
                            color: AppTheme.greyText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- SESSION DETAILS ----------
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
                    'Surf Level',
                    Helpers.surfLevelDisplay(booking.surfLevel),
                  ),
                  if (booking.notes != null &&
                      booking.notes!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildRow(
                      Icons.note,
                      'Student Notes',
                      booking.notes!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Booked on
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

            // ---------- ACTION BUTTONS ----------
            if (booking.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _cancelBooking,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(
                            color: AppTheme.errorColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Decline',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (booking.status == 'confirmed') ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _cancelBooking,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(
                            color: AppTheme.errorColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _completeBooking,
                        child: const Text(
                          'Mark Complete',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
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
