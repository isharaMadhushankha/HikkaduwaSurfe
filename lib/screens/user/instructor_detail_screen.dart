// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/review_provider.dart';
import '../../models/profile_model.dart';
import '../../models/instructor_detail_model.dart';
import '../../widgets/review_card.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/loading_widget.dart';

class InstructorDetailScreen extends StatefulWidget {
  final String instructorId;

  const InstructorDetailScreen({
    super.key,
    required this.instructorId,
  });

  @override
  State<InstructorDetailScreen> createState() =>
      _InstructorDetailScreenState();
}

class _InstructorDetailScreenState extends State<InstructorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InstructorProvider>()
          .loadInstructorById(widget.instructorId);
      context
          .read<ReviewProvider>()
          .loadInstructorReviews(widget.instructorId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructorProvider = context.watch<InstructorProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    final data = instructorProvider.selectedInstructor;

    if (instructorProvider.isLoading || data == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/user'),
          ),
        ),
        body: const LoadingWidget(),
      );
    }

    final profile = ProfileModel.fromMap(data);
    final details = instructorProvider.getInstructorDetails(data);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---------- APP BAR WITH IMAGE ----------
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppTheme.darkText,
                ),
              ),
              onPressed: () => context.go('/user'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0EA5E9),
                          Color(0xFF0369A1),
                        ],
                      ),
                    ),
                  ),
                  // Avatar
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 52,
                            backgroundImage: profile.avatarUrl != null
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppTheme.greyText,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (details != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StarRating(
                                rating: details.avgRating,
                                size: 18,
                                color: AppTheme.accentColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${details.avgRating} (${details.totalReviews} reviews)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- CONTENT ----------
          SliverToBoxAdapter(
            child: Column(
              children: [
                // ---------- STATS ROW ----------
                if (details != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin: const EdgeInsets.all(16),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(
                          '${details.yearsExperience}',
                          'Years Exp.',
                          Icons.timeline,
                        ),
                        _buildDivider(),
                        _buildStat(
                          '${details.totalReviews}',
                          'Reviews',
                          Icons.rate_review_outlined,
                        ),
                        _buildDivider(),
                        _buildStat(
                          '${details.locationsServed.length}',
                          'Locations',
                          Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ),

                // ---------- TAB BAR ----------
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.greyText,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ---------- TAB CONTENT ----------
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ---- ABOUT TAB ----
                _buildAboutTab(profile, details),

                // ---- REVIEWS TAB ----
                _buildReviewsTab(reviewProvider),
              ],
            ),
          ),
        ],
      ),

      // ---------- BOOK NOW BUTTON ----------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/user/book/${widget.instructorId}');
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Book Now'),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- ABOUT TAB ----------
  Widget _buildAboutTab(
    ProfileModel profile,
    InstructorDetailModel? details,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.bio!,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.greyText,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (details != null) ...[
            // Surf Styles
            if (details.surfStyles.isNotEmpty) ...[
              const Text(
                'Surf Styles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: details.surfStyles.map((style) {
                  return Chip(
                    label: Text(style),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Locations
            if (details.locationsServed.isNotEmpty) ...[
              const Text(
                'Locations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 10),
              ...details.locationsServed.map((loc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Certifications
            if (details.certifications.isNotEmpty) ...[
              const Text(
                'Certifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 10),
              ...details.certifications.map((cert) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 20,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cert,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Languages
            if (details.languages.isNotEmpty) ...[
              const Text(
                'Languages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: details.languages.map((lang) {
                  return Chip(
                    avatar: const Icon(
                      Icons.language,
                      size: 18,
                      color: AppTheme.greyText,
                    ),
                    label: Text(lang),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: const TextStyle(color: AppTheme.darkText),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ],

          // Contact
          if (profile.phone != null) ...[
            const Text(
              'Contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.phone, size: 20, color: AppTheme.greyText),
                const SizedBox(width: 8),
                Text(
                  profile.phone!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.darkText,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------- REVIEWS TAB ----------
  Widget _buildReviewsTab(ReviewProvider reviewProvider) {
    if (reviewProvider.isLoading) {
      return const LoadingWidget();
    }
    if (reviewProvider.reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 60, color: AppTheme.greyText),
            SizedBox(height: 12),
            Text(
              'No Reviews Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.greyText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: reviewProvider.reviews.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return ReviewCard(review: reviewProvider.reviews[index]);
      },
    );
  }

  // ---------- HELPERS ----------
  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.shade200,
    );
  }
}
