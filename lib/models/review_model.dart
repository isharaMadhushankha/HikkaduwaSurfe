class ReviewModel {
  final String id;
  final String bookingId;
  final String userId;
  final String instructorId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  // Joined
  final String? userName;
  final String? userAvatar;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.instructorId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'],
      bookingId: map['booking_id'],
      userId: map['user_id'],
      instructorId: map['instructor_id'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
      userName: map['user']?['full_name'],
      userAvatar: map['user']?['avatar_url'],
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'booking_id': bookingId,
      'user_id': userId,
      'instructor_id': instructorId,
      'rating': rating,
      'comment': comment,
    };
  }
}
