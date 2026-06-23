class AvailabilityModel {
  final String id;
  final String instructorId;
  final int? dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final String? specificDate;

  AvailabilityModel({
    required this.id,
    required this.instructorId,
    this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.specificDate,
  });

  factory AvailabilityModel.fromMap(Map<String, dynamic> map) {
    return AvailabilityModel(
      id: map['id'],
      instructorId: map['instructor_id'],
      dayOfWeek: map['day_of_week'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      isAvailable: map['is_available'] ?? true,
      specificDate: map['specific_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'instructor_id': instructorId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable,
      'specific_date': specificDate,
    };
  }
}
