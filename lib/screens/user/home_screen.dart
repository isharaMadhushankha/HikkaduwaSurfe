// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/instructor_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Top Rated',
    'Shortboard',
    'Longboard',
    'Bodyboard',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorProvider>().loadInstructors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty && _selectedFilter == 'All') {
      context.read<InstructorProvider>().loadInstructors();
    } else {
      context.read<InstructorProvider>().searchInstructors(
            query: query,
            surfStyle: _selectedFilter == 'All' ? null : _selectedFilter,
          );
    }
  }

  void _onFilterTap(String filter) {
    setState(() => _selectedFilter = filter);
    if (filter == 'All') {
      context.read<InstructorProvider>().loadInstructors();
    } else if (filter == 'Top Rated') {
      context.read<InstructorProvider>().loadTopRated();
    } else {
      context.read<InstructorProvider>().searchInstructors(
            query: _searchController.text,
            surfStyle: filter,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final instructorProvider = context.watch<InstructorProvider>();
    final userName = authProvider.profile?.fullName ?? 'Surfer';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $userName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.greyText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Find Your Instructor',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: authProvider.profile?.avatarUrl != null
                        ? NetworkImage(authProvider.profile!.avatarUrl!)
                        : null,
                    child: authProvider.profile?.avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------- SEARCH BAR ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search instructors...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ---------- FILTER CHIPS ----------
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => _onFilterTap(filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.greyText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ---------- INSTRUCTOR LIST ----------
            Expanded(
              child: instructorProvider.isLoading
                  ? const LoadingWidget()
                  : instructorProvider.instructors.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.surfing,
                          title: 'No Instructors Found',
                          subtitle: 'Try a different search or filter',
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              instructorProvider.loadInstructors(),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount:
                                instructorProvider.instructors.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final data =
                                  instructorProvider.instructors[index];
                              return InstructorCard(
                                data: data,
                                onTap: () {
                                  context.go(
                                    '/user/instructor/${data['id']}',
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
