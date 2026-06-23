// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/instructor_detail_model.dart';
import 'star_rating.dart';

class InstructorCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const InstructorCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['full_name'] ?? 'Instructor';
    final avatarUrl = data['avatar_url'];
    // final bio = data['bio'] ?? '';

    // Extract instructor details
    InstructorDetailModel? details;
    try {
      final detailsData = data['instructor_details'];
      if (detailsData != null) {
        if (detailsData is List && detailsData.isNotEmpty) {
          details = InstructorDetailModel.fromMap(detailsData.first);
        } else if (detailsData is Map<String, dynamic>) {
          details = InstructorDetailModel.fromMap(detailsData);
        }
      }
    } catch (_) {}

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ---------- AVATAR ----------
            CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 32,
                      color: AppTheme.primaryColor,
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            // ---------- INFO ----------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Rating
                  if (details != null)
                    Row(
                      children: [
                        StarRating(
                          rating: details.avgRating,
                          size: 15,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${details.avgRating.toStringAsFixed(1)} (${details.totalReviews})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 6),

                  // Experience & Locations
                  if (details != null)
                    Row(
                      children: [
                        if (details.yearsExperience > 0) ...[
                          Icon(
                            Icons.timeline,
                            size: 14,
                            color: AppTheme.greyText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${details.yearsExperience} yrs',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.greyText,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (details.locationsServed.isNotEmpty) ...[
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.greyText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              details.locationsServed.join(', '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.greyText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                  // Surf styles chips
                  if (details != null &&
                      details.surfStyles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: details.surfStyles.take(3).map((style) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            style,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // ---------- ARROW ----------
            const Icon(
              Icons.chevron_right,
              color: AppTheme.greyText,
            ),
          ],
        ),
      ),
    );
  }
}
