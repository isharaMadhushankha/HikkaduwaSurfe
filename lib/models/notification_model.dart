class NotificationModel {
  final String id;
  final String recipientId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? bookingId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.bookingId,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      recipientId: map['recipient_id'],
      type: map['type'],
      title: map['title'],
      message: map['message'],
      isRead: map['is_read'] ?? false,
      bookingId: map['booking_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
