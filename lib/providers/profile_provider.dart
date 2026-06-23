import 'dart:io';
import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';
import '../models/profile_model.dart';
import '../models/instructor_detail_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();

  ProfileModel? _profile;
  InstructorDetailModel? _instructorDetails;
  bool _isLoading = false;
  String? _error;

  // ---------- GETTERS ----------
  ProfileModel? get profile => _profile;
  InstructorDetailModel? get instructorDetails => _instructorDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ---------- LOAD PROFILE ----------
  Future<void> loadProfile(String userId) async {
    _setLoading(true);
    try {
      _profile = await _profileService.getProfile(userId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- UPDATE PROFILE ----------
  Future<bool> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
    String? surfLevel,
    String? bio,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final data = <String, dynamic>{'full_name': fullName};
      if (phone != null) data['phone'] = phone;
      if (surfLevel != null) data['surf_level'] = surfLevel;
      if (bio != null) data['bio'] = bio;

      await _profileService.updateProfile(userId: userId, data: data);
      await loadProfile(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- UPLOAD AVATAR ----------
  Future<String?> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final url = await _storageService.uploadAndUpdateAvatar(
        userId: userId,
        imageFile: imageFile,
      );
      await loadProfile(userId);
      _setLoading(false);
      return url;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // ---------- PICK AND UPLOAD AVATAR ----------
  Future<String?> pickAndUploadAvatar(String userId) async {
    try {
      final file = await _storageService.pickImage();
      if (file != null) {
        return await uploadAvatar(userId: userId, imageFile: file);
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ---------- LOAD INSTRUCTOR DETAILS ----------
  Future<void> loadInstructorDetails(String instructorId) async {
    _setLoading(true);
    try {
      _instructorDetails = await _profileService.getInstructorDetails(
        instructorId,
      );
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- UPDATE INSTRUCTOR DETAILS ----------
  Future<bool> updateInstructorDetails({
    required String instructorId,
    int? yearsExperience,
    List<String>? certifications,
    List<String>? surfStyles,
    List<String>? locationsServed,
    List<String>? languages,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final data = <String, dynamic>{};
      if (yearsExperience != null) data['years_experience'] = yearsExperience;
      if (certifications != null) data['certifications'] = certifications;
      if (surfStyles != null) data['surf_styles'] = surfStyles;
      if (locationsServed != null) data['locations_served'] = locationsServed;
      if (languages != null) data['languages'] = languages;

      await _profileService.upsertInstructorDetails(
        instructorId: instructorId,
        data: data,
      );
      await loadInstructorDetails(instructorId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
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
}
