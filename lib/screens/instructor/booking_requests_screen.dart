// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  void _loadRequests() {
    final userId = context.read<AuthProvider>().userId;
    context.read<BookingProvider>().loadPendingRequests(userId);
  }

  Future<void> _confirmBooking(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text(
          'Confirm session with ${booking.userName ?? "student"} on ${Helpers.formatDate(booking.bookingDate)} at ${Helpers.formatTime(booking.startTime)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final userId = context.read<AuthProvider>().userId;
      final success = await context.read<BookingProvider>().confirmBooking(
            bookingId: booking.id,
            instructorId: userId,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel the booking with ${booking.userName ?? "student"}?',
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
            bookingId: booking.id,
            instructorId: userId,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        automaticallyImplyLeading: false,
      ),
      body: bookingProvider.isLoading
          ? const LoadingWidget()
          : bookingProvider.pendingRequests.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.pending_actions,
                  title: 'No Pending Requests',
                  subtitle: 'New booking requests will appear here',
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadRequests(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingProvider.pendingRequests.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final booking =
                          bookingProvider.pendingRequests[index];
                      return _buildRequestCard(booking);
                    },
                  ),
                ),
    );
  }

  Widget _buildRequestCard(BookingModel booking) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: booking.userAvatar != null
                    ? NetworkImage(booking.userAvatar!)
                    : null,
                child: booking.userAvatar == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.userName ?? 'Student',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Booked ${Helpers.timeAgo(booking.createdAt)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.pendingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: AppTheme.pendingColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Details
          Row(
            children: [
              _buildDetailChip(
                Icons.calendar_month,
                Helpers.formatDate(booking.bookingDate),
              ),
              const SizedBox(width: 10),
              _buildDetailChip(
                Icons.access_time,
                Helpers.formatTime(booking.startTime),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDetailChip(
                Icons.timer_outlined,
                Helpers.formatDuration(booking.duration),
              ),
              const SizedBox(width: 10),
              _buildDetailChip(
                Icons.location_on,
                booking.location,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDetailChip(
            Icons.surfing,
            Helpers.surfLevelDisplay(booking.surfLevel),
          ),

          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note,
                    size: 18,
                    color: AppTheme.greyText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.notes!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.greyText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => _cancelBooking(booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _confirmBooking(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
