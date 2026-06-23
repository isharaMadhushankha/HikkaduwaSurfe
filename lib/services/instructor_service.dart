import '../config/supabase_config.dart';
// import '../models/profile_model.dart';
// import '../models/instructor_detail_model.dart';

class InstructorService {
  final _client = SupabaseConfig.client;

  // ---------- GET ALL INSTRUCTORS ----------
  Future<List<Map<String, dynamic>>> getAllInstructors() async {
    try {
      final response = await _client
          .from('profiles')
          .select('''
            *,
            instructor_details (*)
          ''')
          .eq('role', 'instructor')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- SEARCH INSTRUCTORS ----------
  Future<List<Map<String, dynamic>>> searchInstructors({
    String? query,
    String? location,
    String? surfStyle,
  }) async {
    try {
      var request = _client
          .from('profiles')
          .select('''
            *,
            instructor_details (*)
          ''')
          .eq('role', 'instructor');

      if (query != null && query.isNotEmpty) {
        request = request.ilike('full_name', '%$query%');
      }

      final response = await request.order('created_at', ascending: false);
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(response);

      // Filter by location or surf style (client-side for array fields)
      if (location != null && location.isNotEmpty) {
        results = results.where((item) {
          final details = item['instructor_details'];
          if (details == null || details.isEmpty) return false;
          final detail = details is List ? details.first : details;
          final locations =
              List<String>.from(detail['locations_served'] ?? []);
          return locations
              .any((l) => l.toLowerCase().contains(location.toLowerCase()));
        }).toList();
      }

      if (surfStyle != null && surfStyle.isNotEmpty) {
        results = results.where((item) {
          final details = item['instructor_details'];
          if (details == null || details.isEmpty) return false;
          final detail = details is List ? details.first : details;
          final styles = List<String>.from(detail['surf_styles'] ?? []);
          return styles
              .any((s) => s.toLowerCase().contains(surfStyle.toLowerCase()));
        }).toList();
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- GET SINGLE INSTRUCTOR WITH DETAILS ----------
  Future<Map<String, dynamic>?> getInstructorById(
      String instructorId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('''
            *,
            instructor_details (*)
          ''')
          .eq('id', instructorId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ---------- GET TOP RATED INSTRUCTORS ----------
  Future<List<Map<String, dynamic>>> getTopRatedInstructors({
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from('instructor_details')
          .select('''
            *,
            instructor:profiles (*)
          ''')
          .gt('total_reviews', 0)
          .order('avg_rating', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
}
