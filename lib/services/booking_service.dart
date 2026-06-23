import '../config/supabase_config.dart';
import '../models/booking_model.dart';

class BookingService {
  final _client = SupabaseConfig.client;

  // ---------- CREATE BOOKING ----------
  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String instructorId,
    required String bookingDate,
    required String startTime,
    required int duration,
    required String location,
    String? surfLevel,
    String? notes,
  }) async {
    try {
      final response = await _client
          .from('bookings')
          .insert({
            'user_id': userId,
            'instructor_id': instructorId,
            'booking_date': bookingDate,
            'start_time': startTime,
            'duration': duration,
            'location': location,
            'surf_level': surfLevel,
            'notes': notes,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET USER BOOKINGS ----------
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            instructor:profiles!bookings_instructor_id_fkey (
              full_name, avatar_url
            )
          ''')
          .eq('user_id', userId)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((item) => BookingModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET USER BOOKINGS BY STATUS ----------
  Future<List<BookingModel>> getUserBookingsByStatus(
    String userId,
    String status,
  ) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            instructor:profiles!bookings_instructor_id_fkey (
              full_name, avatar_url
            )
          ''')
          .eq('user_id', userId)
          .eq('status', status)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((item) => BookingModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET INSTRUCTOR BOOKINGS ----------
  Future<List<BookingModel>> getInstructorBookings(
      String instructorId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            user:profiles!bookings_user_id_fkey (
              full_name, avatar_url
            )
          ''')
          .eq('instructor_id', instructorId)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((item) => BookingModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET INSTRUCTOR PENDING BOOKINGS ----------
  Future<List<BookingModel>> getInstructorPendingBookings(
      String instructorId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            user:profiles!bookings_user_id_fkey (
              full_name, avatar_url
            )
          ''')
          .eq('instructor_id', instructorId)
          .eq('status', 'pending')
          .order('booking_date', ascending: true);

      return (response as List)
          .map((item) => BookingModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET INSTRUCTOR CONFIRMED BOOKINGS ----------
  Future<List<BookingModel>> getInstructorConfirmedBookings(
      String instructorId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            user:profiles!bookings_user_id_fkey (
              full_name, avatar_url
            )
          ''')
          .eq('instructor_id', instructorId)
          .eq('status', 'confirmed')
          .order('booking_date', ascending: true);

      return (response as List)
          .map((item) => BookingModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET SINGLE BOOKING ----------
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            user:profiles!bookings_user_id_fkey (
              full_name, avatar_url
            ),
            instructor:profiles!bookings_instructor_id_fkey (
              full_name, avatar_url
            )
          ''')
          .eq('id', bookingId)
          .single();

      return BookingModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // ---------- UPDATE BOOKING STATUS ----------
  // Used by instructor to confirm or cancel
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await _client.from('bookings').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- CONFIRM BOOKING ----------
  Future<void> confirmBooking(String bookingId) async {
    await updateBookingStatus(bookingId: bookingId, status: 'confirmed');
  }

  // ---------- CANCEL BOOKING ----------
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId: bookingId, status: 'cancelled');
  }

  // ---------- COMPLETE BOOKING ----------
  Future<void> completeBooking(String bookingId) async {
    await updateBookingStatus(bookingId: bookingId, status: 'completed');
  }

  // ---------- CHECK TIME SLOT CONFLICT ----------
  Future<bool> isTimeSlotAvailable({
    required String instructorId,
    required String bookingDate,
    required String startTime,
    required int duration,
  }) async {
    try {
      final response = await _client
          .from('bookings')
          .select('id')
          .eq('instructor_id', instructorId)
          .eq('booking_date', bookingDate)
          .eq('start_time', startTime)
          .inFilter('status', ['pending', 'confirmed']);

      return (response as List).isEmpty;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET INSTRUCTOR BOOKINGS FOR A DATE ----------
  Future<List<BookingModel>> getInstructorBookingsForDate({
    required String instructorId,
    required String date,
  }) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            user:profiles!bookings_user_id_fkey (
              full_name, avatar_url
            )
          ''')
          .eq('instructor_id', instructorId)
          .eq('booking_date', date)
          .inFilter('status', ['pending', 'confirmed'])
          .order('start_time', ascending: true);

      return (response as List)
          .map((item) => BookingModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
