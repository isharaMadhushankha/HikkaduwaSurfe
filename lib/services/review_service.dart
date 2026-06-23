import '../config/supabase_config.dart';
import '../models/review_model.dart';

class ReviewService {
  final _client = SupabaseConfig.client;

  // ---------- CREATE REVIEW ----------
  Future<void> createReview({
    required String bookingId,
    required String userId,
    required String instructorId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _client.from('reviews').insert({
        'booking_id': bookingId,
        'user_id': userId,
        'instructor_id': instructorId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET INSTRUCTOR REVIEWS ----------
  Future<List<ReviewModel>> getInstructorReviews(
      String instructorId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *,
            user:profiles!reviews_user_id_fkey (
              full_name, avatar_url
            )
          ''')
          .eq('instructor_id', instructorId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ReviewModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- CHECK IF BOOKING HAS REVIEW ----------
  Future<bool> hasReview(String bookingId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('id')
          .eq('booking_id', bookingId);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ---------- GET REVIEW BY BOOKING ----------
  Future<ReviewModel?> getReviewByBooking(String bookingId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *,
            user:profiles!reviews_user_id_fkey (
              full_name, avatar_url
            )
          ''')
          .eq('booking_id', bookingId)
          .single();

      return ReviewModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // ---------- GET USER'S REVIEWS ----------
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ReviewModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
