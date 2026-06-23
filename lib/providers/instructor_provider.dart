import 'package:flutter/material.dart';
import '../services/instructor_service.dart';
import '../models/profile_model.dart';
import '../models/instructor_detail_model.dart';

class InstructorProvider extends ChangeNotifier {
  final InstructorService _instructorService = InstructorService();

  List<Map<String, dynamic>> _instructors = [];
  List<Map<String, dynamic>> _topRated = [];
  Map<String, dynamic>? _selectedInstructor;
  bool _isLoading = false;
  String? _error;

  // ---------- GETTERS ----------
  List<Map<String, dynamic>> get instructors => _instructors;
  List<Map<String, dynamic>> get topRated => _topRated;
  Map<String, dynamic>? get selectedInstructor => _selectedInstructor;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper to extract profile from instructor data
  ProfileModel? getInstructorProfile(Map<String, dynamic> data) {
    try {
      return ProfileModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  // Helper to extract details from instructor data
  InstructorDetailModel? getInstructorDetails(Map<String, dynamic> data) {
    try {
      final details = data['instructor_details'];
      if (details == null) return null;
      if (details is List && details.isNotEmpty) {
        return InstructorDetailModel.fromMap(details.first);
      }
      if (details is Map<String, dynamic>) {
        return InstructorDetailModel.fromMap(details);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ---------- LOAD ALL INSTRUCTORS ----------
  Future<void> loadInstructors() async {
    _setLoading(true);
    _clearError();
    try {
      _instructors = await _instructorService.getAllInstructors();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- SEARCH INSTRUCTORS ----------
  Future<void> searchInstructors({
    String? query,
    String? location,
    String? surfStyle,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _instructors = await _instructorService.searchInstructors(
        query: query,
        location: location,
        surfStyle: surfStyle,
      );
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- LOAD SINGLE INSTRUCTOR ----------
  Future<void> loadInstructorById(String instructorId) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedInstructor =
          await _instructorService.getInstructorById(instructorId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- LOAD TOP RATED ----------
  Future<void> loadTopRated({int limit = 10}) async {
    try {
      _topRated =
          await _instructorService.getTopRatedInstructors(limit: limit);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------- CLEAR SELECTED ----------
  void clearSelected() {
    _selectedInstructor = null;
    notifyListeners();
  }

  // ---------- HELPERS ----------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
