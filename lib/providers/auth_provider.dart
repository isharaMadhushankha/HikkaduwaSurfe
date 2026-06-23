import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  User? _user;
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  // ---------- GETTERS ----------
  User? get user => _user;
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isInstructor => _profile?.role == 'instructor';
  bool get isUser => _profile?.role == 'user';
  String get userId => _user?.id ?? '';

  AuthProvider() {
    _initialize();
  }

  // ---------- INITIALIZE ----------
  Future<void> _initialize() async {
    _user = _authService.currentUser;
    if (_user != null) {
      await _loadProfile();
    }

    // Listen to auth state changes
    _authService.authStateChanges.listen((AuthState authState) async {
      final event = authState.event;
      _user = authState.session?.user;

      if (event == AuthChangeEvent.signedIn && _user != null) {
        await _loadProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _profile = null;
      }
      notifyListeners();
    });
  }

  // ---------- LOAD PROFILE ----------
  Future<void> _loadProfile() async {
    if (_user == null) return;
    try {
      _profile = await _profileService.getProfile(_user!.id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profile';
    }
  }

  // ---------- REGISTER ----------
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      _user = response.user;
      if (_user != null) {
        // Wait for trigger to create profile, then load it
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadProfile();

        // If instructor, create instructor_details row
        if (role == 'instructor') {
          await _profileService.createInstructorDetails(
            instructorId: _user!.id,
            data: {
              'years_experience': 0,
              'certifications': <String>[],
              'surf_styles': <String>[],
              'locations_served': <String>[],
              'languages': <String>[],
            },
          );
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // ---------- LOGIN ----------
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _user = response.user;
      if (_user != null) {
        await _loadProfile();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // ---------- LOGOUT ----------
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _profile = null;
      _setLoading(false);
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
    }
  }

  // ---------- FORGOT PASSWORD ----------
  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.resetPassword(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // ---------- REFRESH PROFILE ----------
  Future<void> refreshProfile() async {
    await _loadProfile();
  }

  // ---------- HELPERS ----------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is AuthException) {
      return e.message;
    }
    return e.toString();
  }
}
