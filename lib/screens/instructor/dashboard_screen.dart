// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/booking_model.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userId = context.read<AuthProvider>().userId;
    context.read<BookingProvider>().loadInstructorBookings(userId);
    context.read<BookingProvider>().loadPendingRequests(userId);
    context.read<BookingProvider>().loadConfirmedAppointments(userId);
    context.read<ProfileProvider>().loadInstructorDetails(userId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final profile = authProvider.profile;
    final details = profileProvider.instructorDetails;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayBookings = bookingProvider.confirmedAppointments
        .where((b) => b.bookingDate == today)
        .toList();

    final totalBookings = bookingProvider.instructorBookings.length;
    final pendingCount = bookingProvider.pendingRequests.length;
    final confirmedCount = bookingProvider.confirmedAppointments.length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- HEADER ----------
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          AppTheme.primaryColor.withOpacity(0.1),
                      backgroundImage: profile?.avatarUrl != null
                          ? NetworkImage(profile!.avatarUrl!)
                          : null,
                      child: profile?.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              color: AppTheme.primaryColor,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.greyText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile?.fullName ?? 'Instructor',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ---------- STATS CARDS ----------
                Row(
                  children: [
                    _buildStatCard(
                      'Pending',
                      pendingCount.toString(),
                      Icons.hourglass_top,
                      AppTheme.pendingColor,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Confirmed',
                      confirmedCount.toString(),
                      Icons.check_circle_outline,
                      AppTheme.successColor,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Total',
                      totalBookings.toString(),
                      Icons.calendar_today,
                      AppTheme.primaryColor,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Rating card
                if (details != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppTheme.accentColor,
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${details.totalReviews} reviews',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Your Rating',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 28),

                // ---------- TODAY'S SCHEDULE ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Sessions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.greyText,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (bookingProvider.isLoading)
                  const LoadingWidget()
                else if (todayBookings.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.surfing,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No sessions today',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enjoy your free time!',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...todayBookings.map((booking) =>
                      _buildTodayBookingCard(booking)),

                const SizedBox(height: 28),

                // ---------- PENDING REQUESTS PREVIEW ----------
                if (pendingCount > 0) ...[
                  const Text(
                    'Pending Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...bookingProvider.pendingRequests
                      .take(3)
                      .map((booking) => _buildPendingCard(booking)),
                  if (pendingCount > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            // Switch to Requests tab
                          },
                          child: Text(
                            'View all $pendingCount requests',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- STAT CARD ----------
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- TODAY'S BOOKING CARD ----------
  Widget _buildTodayBookingCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.successColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          CircleAvatar(
            radius: 22,
            backgroundImage: booking.userAvatar != null
                ? NetworkImage(booking.userAvatar!)
                : null,
            child: booking.userAvatar == null
                ? const Icon(Icons.person, size: 22)
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Helpers.formatTime(booking.startTime)} · ${Helpers.formatDuration(booking.duration)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppTheme.greyText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    booking.location,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                Helpers.surfLevelDisplay(booking.surfLevel),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- PENDING CARD ----------
  Widget _buildPendingCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.pendingColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: booking.userAvatar != null
                ? NetworkImage(booking.userAvatar!)
                : null,
            child: booking.userAvatar == null
                ? const Icon(Icons.person, size: 22)
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Helpers.formatDate(booking.bookingDate)} · ${Helpers.formatTime(booking.startTime)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.hourglass_top,
            color: AppTheme.pendingColor,
            size: 22,
          ),
        ],
      ),
    );
  }
}
