// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/notification_provider.dart';
// import '../../utils/validators.dart';
// import '../../utils/helpers.dart';
// import '../../widgets/loading_widget.dart';

class ProfileManageScreen extends StatefulWidget {
  const ProfileManageScreen({super.key});

  @override
  State<ProfileManageScreen> createState() => _ProfileManageScreenState();
}

class _ProfileManageScreenState extends State<ProfileManageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Basic profile fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  // Instructor detail fields
  final _experienceController = TextEditingController();
  final _certController = TextEditingController();
  final _locationController = TextEditingController();
  final _languageController = TextEditingController();

  List<String> _certifications = [];
  List<String> _locationsServed = [];
  List<String> _languages = [];
  List<String> _selectedSurfStyles = [];

  final List<String> _allSurfStyles = [
    'Shortboard',
    'Longboard',
    'Bodyboard',
    'Stand Up Paddle',
    'Foil Surfing',
    'Skimboarding',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userId = context.read<AuthProvider>().userId;
    final profileProvider = context.read<ProfileProvider>();
    profileProvider.loadProfile(userId);
    profileProvider.loadInstructorDetails(userId);

    // Populate fields after load
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final profile = context.read<AuthProvider>().profile;
      if (profile != null) {
        _nameController.text = profile.fullName;
        _phoneController.text = profile.phone ?? '';
        _bioController.text = profile.bio ?? '';
      }

      final details =
          context.read<ProfileProvider>().instructorDetails;
      if (details != null) {
        _experienceController.text =
            details.yearsExperience.toString();
        _certifications = List.from(details.certifications);
        _locationsServed = List.from(details.locationsServed);
        _languages = List.from(details.languages);
        _selectedSurfStyles = List.from(details.surfStyles);
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _certController.dispose();
    _locationController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _saveBasicProfile() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final success = await profileProvider.updateProfile(
      userId: authProvider.userId,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (success && mounted) {
      await authProvider.refreshProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _saveInstructorDetails() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final years =
        int.tryParse(_experienceController.text) ?? 0;

    final success = await profileProvider.updateInstructorDetails(
      instructorId: authProvider.userId,
      yearsExperience: years,
      certifications: _certifications,
      surfStyles: _selectedSurfStyles,
      locationsServed: _locationsServed,
      languages: _languages,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instructor details updated!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _changeAvatar() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final url = await profileProvider.pickAndUploadAvatar(
      authProvider.userId,
    );

    if (url != null && mounted) {
      await authProvider.refreshProfile();
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<NotificationProvider>().unsubscribe();
      await context.read<AuthProvider>().logout();
    }
  }

  void _addChip(
    TextEditingController controller,
    List<String> list,
  ) {
    final text = controller.text.trim();
    if (text.isNotEmpty && !list.contains(text)) {
      setState(() {
        list.add(text);
        controller.clear();
      });
    }
  }

  void _removeChip(List<String> list, String item) {
    setState(() => list.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final profile = authProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Experience'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ---- BASIC INFO TAB ----
          _buildBasicInfoTab(profile, profileProvider),

          // ---- EXPERIENCE TAB ----
          _buildExperienceTab(profileProvider),
        ],
      ),
    );
  }

  // ---------- BASIC INFO TAB ----------
  // ignore: strict_top_level_inference
  Widget _buildBasicInfoTab(profile, ProfileProvider profileProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor:
                    AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 55,
                        color: AppTheme.primaryColor,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _changeAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            profile?.fullName ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 32),

          // Name
          _buildLabel('Full Name'),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 20),

          // Phone
          _buildLabel('Phone Number'),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone_outlined),
              hintText: 'Enter phone number',
            ),
          ),
          const SizedBox(height: 20),

          // Bio
          _buildLabel('Bio'),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tell students about yourself...',
            ),
          ),
          const SizedBox(height: 32),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  profileProvider.isLoading ? null : _saveBasicProfile,
              child: profileProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ),

          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon:
                  const Icon(Icons.logout, color: AppTheme.errorColor),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ---------- EXPERIENCE TAB ----------
  Widget _buildExperienceTab(ProfileProvider profileProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Years of experience
          _buildLabel('Years of Experience'),
          TextFormField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.timeline),
              hintText: 'e.g. 5',
            ),
          ),

          const SizedBox(height: 24),

          // Surf Styles
          _buildLabel('Surf Styles'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allSurfStyles.map((style) {
              final isSelected =
                  _selectedSurfStyles.contains(style);
              return FilterChip(
                label: Text(style),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSurfStyles.add(style);
                    } else {
                      _selectedSurfStyles.remove(style);
                    }
                  });
                },
                selectedColor:
                    AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.darkText,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Certifications
          _buildLabel('Certifications'),
          _buildChipInput(
            controller: _certController,
            list: _certifications,
            hint: 'Add certification',
          ),

          const SizedBox(height: 24),

          // Locations
          _buildLabel('Locations Served'),
          _buildChipInput(
            controller: _locationController,
            list: _locationsServed,
            hint: 'Add location',
          ),

          const SizedBox(height: 24),

          // Languages
          _buildLabel('Languages Spoken'),
          _buildChipInput(
            controller: _languageController,
            list: _languages,
            hint: 'Add language',
          ),

          const SizedBox(height: 32),

          // Save
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: profileProvider.isLoading
                  ? null
                  : _saveInstructorDetails,
              child: profileProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Save Experience'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ---------- CHIP INPUT ----------
  Widget _buildChipInput({
    required TextEditingController controller,
    required List<String> list,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                ),
                onFieldSubmitted: (_) =>
                    _addChip(controller, list),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => _addChip(controller, list),
              icon: const Icon(
                Icons.add_circle,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
          ],
        ),
        if (list.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: list.map((item) {
              return Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeChip(list, item),
                backgroundColor:
                    AppTheme.primaryColor.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: AppTheme.primaryColor,
                ),
                deleteIconColor: AppTheme.primaryColor,
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),
      ),
    );
  }
}
