import '../config/supabase_config.dart';
import '../models/profile_model.dart';
import '../models/instructor_detail_model.dart';

class ProfileService {
  final _client = SupabaseConfig.client;

  // ---------- GET PROFILE ----------
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return ProfileModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // ---------- UPDATE PROFILE ----------
  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _client.from('profiles').update(data).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET INSTRUCTOR DETAILS ----------
  Future<InstructorDetailModel?> getInstructorDetails(
      String instructorId) async {
    try {
      final response = await _client
          .from('instructor_details')
          .select()
          .eq('instructor_id', instructorId)
          .single();
      return InstructorDetailModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // ---------- CREATE INSTRUCTOR DETAILS ----------
  Future<void> createInstructorDetails({
    required String instructorId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['instructor_id'] = instructorId;
      await _client.from('instructor_details').insert(data);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- UPDATE INSTRUCTOR DETAILS ----------
  Future<void> updateInstructorDetails({
    required String instructorId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _client
          .from('instructor_details')
          .update(data)
          .eq('instructor_id', instructorId);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- UPSERT INSTRUCTOR DETAILS ----------
  // Creates if not exists, updates if exists
  Future<void> upsertInstructorDetails({
    required String instructorId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final existing = await getInstructorDetails(instructorId);
      if (existing == null) {
        await createInstructorDetails(
          instructorId: instructorId,
          data: data,
        );
      } else {
        await updateInstructorDetails(
          instructorId: instructorId,
          data: data,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
