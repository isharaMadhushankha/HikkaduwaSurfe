import 'package:flutter/material.dart';
import '../services/review_service.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<ReviewModel> _reviews = [];
  bool _hasReview = false;
  bool _isLoading = false;
  String? _error;

  // ---------- GETTERS ----------
  List<ReviewModel> get reviews => _reviews;
  bool get hasReview => _hasReview;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  // ---------- LOAD INSTRUCTOR REVIEWS ----------
  Future<void> loadInstructorReviews(String instructorId) async {
    _setLoading(true);
    _clearError();
    try {
      _reviews = await _reviewService.getInstructorReviews(instructorId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ---------- CHECK IF BOOKING HAS REVIEW ----------
  Future<void> checkHasReview(String bookingId) async {
    try {
      _hasReview = await _reviewService.hasReview(bookingId);
      notifyListeners();
    } catch (e) {
      _hasReview = false;
      notifyListeners();
    }
  }

  // ---------- CREATE REVIEW ----------
  Future<bool> createReview({
    required String bookingId,
    required String userId,
    required String instructorId,
    required int rating,
    String? comment,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _reviewService.createReview(
        bookingId: bookingId,
        userId: userId,
        instructorId: instructorId,
        rating: rating,
        comment: comment,
      );
      await loadInstructorReviews(instructorId);
      _hasReview = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ---------- CLEAR ----------
  void clearReviews() {
    _reviews = [];
    _hasReview = false;
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
