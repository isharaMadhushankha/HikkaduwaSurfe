import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/booking_provider.dart';
import 'dashboard_screen.dart';
import 'booking_requests_screen.dart';
import 'schedule_screen.dart';
import 'notifications_screen.dart';
import 'profile_manage_screen.dart';

class InstructorMainScreen extends StatefulWidget {
  const InstructorMainScreen({super.key});

  @override
  State<InstructorMainScreen> createState() => _InstructorMainScreenState();
}

class _InstructorMainScreenState extends State<InstructorMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    BookingRequestsScreen(),
    ScheduleScreen(),
    InstructorNotificationsScreen(),
    ProfileManageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      if (userId.isNotEmpty) {
        final notifProvider = context.read<NotificationProvider>();
        notifProvider.loadNotifications(userId);
        notifProvider.subscribeToRealtime(userId);

        // Load pending requests count for badge
        context.read<BookingProvider>().loadPendingRequests(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: bookingProvider.pendingRequests.isNotEmpty,
              label: Text(
                bookingProvider.pendingRequests.length.toString(),
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.pending_actions_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: bookingProvider.pendingRequests.isNotEmpty,
              label: Text(
                bookingProvider.pendingRequests.length.toString(),
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.pending_actions),
            ),
            label: 'Requests',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: notifProvider.hasUnread,
              label: Text(
                notifProvider.unreadCount.toString(),
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: notifProvider.hasUnread,
              label: Text(
                notifProvider.unreadCount.toString(),
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.notifications),
            ),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
