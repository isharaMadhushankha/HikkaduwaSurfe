import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // ---------- GET CURRENT USER ----------
  User? get currentUser => _client.auth.currentUser;

  // ---------- GET SESSION ----------
  Session? get currentSession => _client.auth.currentSession;

  // ---------- AUTH STATE STREAM ----------
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ---------- REGISTER ----------
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'user' or 'instructor'
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- LOGIN ----------
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- LOGOUT ----------
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // ---------- FORGOT PASSWORD ----------
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- UPDATE PASSWORD ----------
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      rethrow;
    }
  }
}
