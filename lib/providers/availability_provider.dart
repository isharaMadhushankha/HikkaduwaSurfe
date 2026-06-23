import 'package:flutter/material.dart';
import '../services/availability_service.dart';
import '../models/availability_model.dart';

class AvailabilityProvider extends ChangeNotifier {
  final AvailabilityService _availabilityService = AvailabilityService();

  List<AvailabilityModel> _weeklySlots = [];
  List<AvailabilityModel> _dateSlots = [];
  List<AvailabilityModel> _blockedDates = [];
  bool _isLoading = false;
  String? _error;

  // ---------- GETTERS ----------
  List<AvailabilityModel> get weeklySlots => _weeklySlots;
  List<AvailabilityModel> get dateSlots => _dateSlots;
  List<AvailabilityModel> get blockedDates => _blockedDates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get slots for a specific day of week
  List<AvailabilityModel> getSlotsForDay(int dayOfWeek) {
    return _weeklySlots
        .where((s) => s.dayOfWeek == dayOfWeek && s.isAvailable)
        .toList();
  }

  // ---------- LOAD WEEKLY SCHEDULE ----------
  Future<void> loadWeeklySchedule(String instructorId) async {
    _setLoading(true);
    _clearError();
    try {
      _weeklySlots =
          await _availabilityService.getInstructorAvailability(instructorId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- LOAD AVAILABILITY FOR DATE ----------
  Future<void> loadAvailabilityForDate({
    required String instructorId,
    required String date,
    required int dayOfWeek,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _dateSlots = await _availabilityService.getAvailabilityForDate(
        instructorId: instructorId,
        date: date,
        dayOfWeek: dayOfWeek,
      );
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- ADD SLOT ----------
  Future<bool> addSlot({
    required String instructorId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _availabilityService.addAvailability(
        instructorId: instructorId,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );
      await loadWeeklySchedule(instructorId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- DELETE SLOT ----------
  Future<bool> deleteSlot({
    required String slotId,
    required String instructorId,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _availabilityService.deleteAvailability(slotId);
      await loadWeeklySchedule(instructorId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- SET FULL WEEK SCHEDULE ----------
  Future<bool> setWeekSchedule({
    required String instructorId,
    required List<Map<String, dynamic>> slots,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _availabilityService.setWeekSchedule(
        instructorId: instructorId,
        slots: slots,
      );
      await loadWeeklySchedule(instructorId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- BLOCK A DATE ----------
  Future<bool> blockDate({
    required String instructorId,
    required String date,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _availabilityService.addDateOverride(
        instructorId: instructorId,
        date: date,
        startTime: '00:00:00',
        endTime: '23:59:00',
        isAvailable: false,
      );
      await loadBlockedDates(instructorId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- LOAD BLOCKED DATES ----------
  Future<void> loadBlockedDates(String instructorId) async {
    try {
      _blockedDates =
          await _availabilityService.getBlockedDates(instructorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------- UNBLOCK DATE ----------
  Future<bool> unblockDate({
    required String slotId,
    required String instructorId,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _availabilityService.deleteAvailability(slotId);
      await loadBlockedDates(instructorId);
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
