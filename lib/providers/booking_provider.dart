import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<BookingModel> _userBookings = [];
  List<BookingModel> _instructorBookings = [];
  List<BookingModel> _pendingRequests = [];
  List<BookingModel> _confirmedAppointments = [];
  List<BookingModel> _dateBookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String? _error;

  // ---------- GETTERS ----------
  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get instructorBookings => _instructorBookings;
  List<BookingModel> get pendingRequests => _pendingRequests;
  List<BookingModel> get confirmedAppointments => _confirmedAppointments;
  List<BookingModel> get dateBookings => _dateBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered lists for user
  List<BookingModel> get upcomingBookings => _userBookings
      .where((b) => b.status == 'pending' || b.status == 'confirmed')
      .toList();

  List<BookingModel> get pastBookings => _userBookings
      .where((b) => b.status == 'completed')
      .toList();

  List<BookingModel> get cancelledBookings => _userBookings
      .where((b) => b.status == 'cancelled')
      .toList();

  // ---------- CREATE BOOKING ----------
  Future<bool> createBooking({
    required String userId,
    required String instructorId,
    required String bookingDate,
    required String startTime,
    required int duration,
    required String location,
    String? surfLevel,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      // Check availability
      final isAvailable = await _bookingService.isTimeSlotAvailable(
        instructorId: instructorId,
        bookingDate: bookingDate,
        startTime: startTime,
        duration: duration,
      );

      if (!isAvailable) {
        _error = 'This time slot is already booked. Please choose another.';
        _setLoading(false);
        return false;
      }

      await _bookingService.createBooking(
        userId: userId,
        instructorId: instructorId,
        bookingDate: bookingDate,
        startTime: startTime,
        duration: duration,
        location: location,
        surfLevel: surfLevel,
        notes: notes,
      );

      // Refresh user bookings
      await loadUserBookings(userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- LOAD USER BOOKINGS ----------
  Future<void> loadUserBookings(String userId) async {
    _setLoading(true);
    _clearError();
    try {
      _userBookings = await _bookingService.getUserBookings(userId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- LOAD INSTRUCTOR BOOKINGS ----------
  Future<void> loadInstructorBookings(String instructorId) async {
    _setLoading(true);
    _clearError();
    try {
      _instructorBookings =
          await _bookingService.getInstructorBookings(instructorId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- LOAD PENDING REQUESTS ----------
  Future<void> loadPendingRequests(String instructorId) async {
    _setLoading(true);
    _clearError();
    try {
      _pendingRequests =
          await _bookingService.getInstructorPendingBookings(instructorId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- LOAD CONFIRMED APPOINTMENTS ----------
  Future<void> loadConfirmedAppointments(String instructorId) async {
    _setLoading(true);
    _clearError();
    try {
      _confirmedAppointments =
          await _bookingService.getInstructorConfirmedBookings(instructorId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- LOAD SINGLE BOOKING ----------
  Future<void> loadBookingById(String bookingId) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedBooking = await _bookingService.getBookingById(bookingId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- CONFIRM BOOKING ----------
  Future<bool> confirmBooking({
    required String bookingId,
    required String instructorId,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _bookingService.confirmBooking(bookingId);
      await loadPendingRequests(instructorId);
      await loadConfirmedAppointments(instructorId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- CANCEL BOOKING ----------
  Future<bool> cancelBooking({
    required String bookingId,
    required String instructorId,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _bookingService.cancelBooking(bookingId);
      await loadPendingRequests(instructorId);
      await loadInstructorBookings(instructorId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- COMPLETE BOOKING ----------
  Future<bool> completeBooking({
    required String bookingId,
    required String instructorId,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _bookingService.completeBooking(bookingId);
      await loadInstructorBookings(instructorId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- LOAD BOOKINGS FOR DATE (calendar view) ----------
  Future<void> loadBookingsForDate({
    required String instructorId,
    required String date,
  }) async {
    try {
      _dateBookings = await _bookingService.getInstructorBookingsForDate(
        instructorId: instructorId,
        date: date,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------- CLEAR ----------
  void clearSelected() {
    _selectedBooking = null;
    notifyListeners();
  }

  void clearAll() {
    _userBookings = [];
    _instructorBookings = [];
    _pendingRequests = [];
    _confirmedAppointments = [];
    _dateBookings = [];
    _selectedBooking = null;
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
