// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../utils/helpers.dart';
// import '../../widgets/loading_widget.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
      _loadForDate(_selectedDay);
    });
  }

  void _loadAppointments() {
    final userId = context.read<AuthProvider>().userId;
    context.read<BookingProvider>().loadConfirmedAppointments(userId);
  }

  void _loadForDate(DateTime date) {
    final userId = context.read<AuthProvider>().userId;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    context.read<BookingProvider>().loadBookingsForDate(
          instructorId: userId,
          date: dateStr,
        );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    // Build event markers from confirmed appointments
    final eventDates = <DateTime>{};
    for (final booking in bookingProvider.confirmedAppointments) {
      eventDates.add(DateTime.parse(booking.bookingDate));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ---------- CALENDAR ----------
          Container(
            margin: const EdgeInsets.all(12),
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
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 180)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadForDate(selectedDay);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerSize: 6,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              eventLoader: (day) {
                final normalized =
                    DateTime(day.year, day.month, day.day);
                return eventDates.contains(normalized)
                    ? ['event']
                    : [];
              },
            ),
          ),

          // ---------- SELECTED DATE HEADER ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  Helpers.formatDateFull(
                      _selectedDay.toIso8601String()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const Spacer(),
                Text(
                  '${bookingProvider.dateBookings.length} sessions',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),

          // ---------- BOOKINGS LIST ----------
          Expanded(
            child: bookingProvider.dateBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No sessions on this day',
                          style: TextStyle(
                            color: AppTheme.greyText,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bookingProvider.dateBookings.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final booking =
                          bookingProvider.dateBookings[index];
                      return _buildAppointmentCard(booking);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BookingModel booking) {
    return GestureDetector(
      onTap: () {
        context.go('/instructor/booking/${booking.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: booking.status == 'confirmed'
                ? AppTheme.successColor.withOpacity(0.3)
                : AppTheme.pendingColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Time column
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    Helpers.formatTime(booking.startTime),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    Helpers.formatDuration(booking.duration),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info
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
                  Row(
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
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.greyText,
            ),
          ],
        ),
      ),
    );
  }
}
