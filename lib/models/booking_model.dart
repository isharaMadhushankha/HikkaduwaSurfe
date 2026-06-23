class BookingModel {
  final String id;
  final String userId;
  final String instructorId;
  final String bookingDate;
  final String startTime;
  final int duration;
  final String location;
  final String? surfLevel;
  final String? notes;
  final String status;
  final DateTime createdAt;

  // Joined fields (optional)
  final String? userName;
  final String? userAvatar;
  final String? instructorName;
  final String? instructorAvatar;

  BookingModel({
    required this.id,
    required this.userId,
    required this.instructorId,
    required this.bookingDate,
    required this.startTime,
    required this.duration,
    required this.location,
    this.surfLevel,
    this.notes,
    required this.status,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.instructorName,
    this.instructorAvatar,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      userId: map['user_id'],
      instructorId: map['instructor_id'],
      bookingDate: map['booking_date'],
      startTime: map['start_time'],
      duration: map['duration'],
      location: map['location'],
      surfLevel: map['surf_level'],
      notes: map['notes'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      userName: map['user']?['full_name'],
      userAvatar: map['user']?['avatar_url'],
      instructorName: map['instructor']?['full_name'],
      instructorAvatar: map['instructor']?['avatar_url'],
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'instructor_id': instructorId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'duration': duration,
      'location': location,
      'surf_level': surfLevel,
      'notes': notes,
    };
  }
}
