// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/review_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/star_rating.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      context.read<ReviewProvider>().loadInstructorReviews(userId);
      context.read<ProfileProvider>().loadInstructorDetails(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final details = profileProvider.instructorDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        automaticallyImplyLeading: false,
      ),
      body: reviewProvider.isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                // ---------- RATING SUMMARY ----------
                if (details != null && details.totalReviews > 0)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0EA5E9),
                          Color(0xFF06B6D4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          details.avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StarRating(
                          rating: details.avgRating,
                          size: 28,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${details.totalReviews} reviews',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rating distribution
                        ...List.generate(5, (index) {
                          final star = 5 - index;
                          final count = reviewProvider.reviews
                              .where((r) => r.rating == star)
                              .length;
                          final percentage = details.totalReviews > 0
                              ? count / details.totalReviews
                              : 0.0;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  '$star',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: AppTheme.accentColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.2),
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                        AppTheme.accentColor,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                // ---------- REVIEWS LIST ----------
                Expanded(
                  child: reviewProvider.reviews.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.rate_review_outlined,
                          title: 'No Reviews Yet',
                          subtitle:
                              'Reviews from your students will appear here',
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            final userId =
                                context.read<AuthProvider>().userId;
                            await reviewProvider
                                .loadInstructorReviews(userId);
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: reviewProvider.reviews.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return ReviewCard(
                                review: reviewProvider.reviews[index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
