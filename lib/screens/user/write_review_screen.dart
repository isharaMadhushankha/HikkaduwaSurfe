// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/loading_widget.dart';

class WriteReviewScreen extends StatefulWidget {
  final String bookingId;

  const WriteReviewScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookingById(widget.bookingId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final booking = context.read<BookingProvider>().selectedBooking;
    if (booking == null) return;

    final reviewProvider = context.read<ReviewProvider>();
    final success = await reviewProvider.createReview(
      bookingId: widget.bookingId,
      userId: authProvider.userId,
      instructorId: booking.instructorId,
      rating: _rating,
      comment: _commentController.text.isNotEmpty
          ? _commentController.text
          : null,
    );

    if (success && mounted) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    final booking = bookingProvider.selectedBooking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () =>
              context.go('/user/booking/${widget.bookingId}'),
        ),
      ),
      body: booking == null
          ? const LoadingWidget()
          : _submitted
              ? _buildSuccessView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // ---------- INSTRUCTOR INFO ----------
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: booking.instructorAvatar != null
                            ? NetworkImage(booking.instructorAvatar!)
                            : null,
                        child: booking.instructorAvatar == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        booking.instructorName ?? 'Instructor',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'How was your surf session?',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.greyText,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ---------- STAR RATING ----------
                      const Text(
                        'Tap to rate',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() => _rating = index + 1);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                index < _rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 48,
                                color: index < _rating
                                    ? AppTheme.accentColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _ratingText(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _rating > 0
                              ? AppTheme.accentColor
                              : Colors.transparent,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ---------- COMMENT ----------
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Review (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _commentController,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          hintText:
                              'Share your experience with this instructor...',
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ---------- ERROR ----------
                      if (reviewProvider.error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reviewProvider.error!,
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),

                      // ---------- SUBMIT BUTTON ----------
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: reviewProvider.isLoading
                              ? null
                              : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                          ),
                          child: reviewProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('Submit Review'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // ---------- SUCCESS VIEW ----------
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thumb_up_rounded,
                size: 50,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your review has been submitted.\nIt helps other surfers find great instructors!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.greyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go('/user'),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingText() {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }
}
