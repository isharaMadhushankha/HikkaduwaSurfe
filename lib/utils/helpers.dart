import 'package:intl/intl.dart';

class Helpers {
  // ---------- DATE FORMATTING ----------
  static String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateFull(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  static String formatTime(String timeStr) {
    // Input: "09:00:00" → Output: "9:00 AM"
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy – h:mm a').format(dateTime);
  }

  // ---------- DURATION ----------
  static String formatDuration(int minutes) {
    if (minutes == 60) return '1 Hour';
    if (minutes == 90) return '1.5 Hours';
    if (minutes == 120) return '2 Hours';
    return '$minutes min';
  }

  // ---------- TIME AGO ----------
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(dateTime);
  }

  // ---------- DAY NAME ----------
  static String dayName(int dayOfWeek) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[dayOfWeek];
  }

  // ---------- SURF LEVEL DISPLAY ----------
  static String surfLevelDisplay(String? level) {
    if (level == null) return 'Not set';
    return level[0].toUpperCase() + level.substring(1);
  }

  // ---------- STATUS COLOR NAME ----------
  static String statusDisplay(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  // ---------- GENERATE TIME SLOTS ----------
  static List<String> generateTimeSlots({
    String startTime = '06:00',
    String endTime = '20:00',
    int intervalMinutes = 60,
  }) {
    List<String> slots = [];
    final start = _timeToMinutes(startTime);
    final end = _timeToMinutes(endTime);

    for (int minutes = start; minutes < end; minutes += intervalMinutes) {
      final hour = (minutes ~/ 60).toString().padLeft(2, '0');
      final min = (minutes % 60).toString().padLeft(2, '0');
      slots.add('$hour:$min:00');
    }

    return slots;
  }

  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
