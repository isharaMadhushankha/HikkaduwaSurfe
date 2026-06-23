import '../config/supabase_config.dart';
import '../models/availability_model.dart';

class AvailabilityService {
  final _client = SupabaseConfig.client;

  // ---------- GET INSTRUCTOR AVAILABILITY ----------
  Future<List<AvailabilityModel>> getInstructorAvailability(
      String instructorId) async {
    try {
      final response = await _client
          .from('availability')
          .select()
          .eq('instructor_id', instructorId)
          .isFilter('specific_date', null) // recurring only
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      return (response as List)
          .map((item) => AvailabilityModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET AVAILABILITY FOR SPECIFIC DATE ----------
  Future<List<AvailabilityModel>> getAvailabilityForDate({
    required String instructorId,
    required String date,
    required int dayOfWeek,
  }) async {
    try {
      // Check for specific date overrides first
      final overrides = await _client
          .from('availability')
          .select()
          .eq('instructor_id', instructorId)
          .eq('specific_date', date);

      if ((overrides as List).isNotEmpty) {
        return overrides
            .map((item) => AvailabilityModel.fromMap(item))
            .toList();
      }

      // Fall back to recurring schedule
      final recurring = await _client
          .from('availability')
          .select()
          .eq('instructor_id', instructorId)
          .eq('day_of_week', dayOfWeek)
          .isFilter('specific_date', null)
          .eq('is_available', true);

      return (recurring as List)
          .map((item) => AvailabilityModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- ADD AVAILABILITY SLOT ----------
  Future<void> addAvailability({
    required String instructorId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await _client.from('availability').insert({
        'instructor_id': instructorId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'is_available': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ---------- ADD DATE OVERRIDE (block/unblock specific date) ----------
  Future<void> addDateOverride({
    required String instructorId,
    required String date,
    required String startTime,
    required String endTime,
    required bool isAvailable,
  }) async {
    try {
      await _client.from('availability').insert({
        'instructor_id': instructorId,
        'specific_date': date,
        'start_time': startTime,
        'end_time': endTime,
        'is_available': isAvailable,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ---------- UPDATE AVAILABILITY SLOT ----------
  Future<void> updateAvailability({
    required String slotId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from('availability').update(data).eq('id', slotId);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- DELETE AVAILABILITY SLOT ----------
  Future<void> deleteAvailability(String slotId) async {
    try {
      await _client.from('availability').delete().eq('id', slotId);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- SET FULL WEEK SCHEDULE ----------
  // Replaces all recurring slots for instructor
  Future<void> setWeekSchedule({
    required String instructorId,
    required List<Map<String, dynamic>> slots,
  }) async {
    try {
      // Delete all existing recurring slots
      await _client
          .from('availability')
          .delete()
          .eq('instructor_id', instructorId)
          .isFilter('specific_date', null);

      // Insert new slots
      if (slots.isNotEmpty) {
        final insertData = slots.map((slot) {
          return {
            'instructor_id': instructorId,
            'day_of_week': slot['day_of_week'],
            'start_time': slot['start_time'],
            'end_time': slot['end_time'],
            'is_available': true,
          };
        }).toList();

        await _client.from('availability').insert(insertData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET BLOCKED DATES ----------
  Future<List<AvailabilityModel>> getBlockedDates(
      String instructorId) async {
    try {
      final response = await _client
          .from('availability')
          .select()
          .eq('instructor_id', instructorId)
          .not('specific_date', 'is', null)
          .eq('is_available', false)
          .order('specific_date', ascending: true);

      return (response as List)
          .map((item) => AvailabilityModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
