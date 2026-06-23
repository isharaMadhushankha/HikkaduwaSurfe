class AppConstants {
  static const List<String> surfLevels = [
    'beginner',
    'intermediate',
    'advanced'
  ];

  static const List<int> durations = [60, 90, 120];

  static const Map<int, String> durationLabels = {
    60: '1 Hour',
    90: '1.5 Hours',
    120: '2 Hours',
  };

  static const List<String> daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const String defaultAvatarUrl =
      'https://via.placeholder.com/150/0EA5E9/FFFFFF?text=HS';

  static const String storageBucket = 'avatars';
}
