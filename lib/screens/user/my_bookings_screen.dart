import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  void _loadBookings() {
    final userId = context.read<AuthProvider>().userId;
    context.read<BookingProvider>().loadUserBookings(userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Upcoming (${bookingProvider.upcomingBookings.length})',
            ),
            Tab(
              text: 'Past (${bookingProvider.pastBookings.length})',
            ),
            Tab(
              text: 'Cancelled (${bookingProvider.cancelledBookings.length})',
            ),
          ],
        ),
      ),
      body: bookingProvider.isLoading
          ? const LoadingWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                // ---- UPCOMING ----
                _buildBookingList(
                  bookingProvider.upcomingBookings,
                  'No Upcoming Bookings',
                  'Book a surf session to get started!',
                  Icons.calendar_today_outlined,
                ),

                // ---- PAST ----
                _buildBookingList(
                  bookingProvider.pastBookings,
                  'No Past Bookings',
                  'Your completed sessions will appear here',
                  Icons.history,
                ),

                // ---- CANCELLED ----
                _buildBookingList(
                  bookingProvider.cancelledBookings,
                  'No Cancelled Bookings',
                  'Cancelled bookings will show up here',
                  Icons.cancel_outlined,
                ),
              ],
            ),
    );
  }

  Widget _buildBookingList(
    List bookings,
    String emptyTitle,
    String emptySubtitle,
    IconData emptyIcon,
  ) {
    if (bookings.isEmpty) {
      return EmptyStateWidget(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadBookings(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            booking: booking,
            showInstructorName: true,
            onTap: () {
              context.go('/user/booking/${booking.id}');
            },
          );
        },
      ),
    );
  }
}
