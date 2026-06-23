// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/availability_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/profile_model.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';

class BookingFormScreen extends StatefulWidget {
  final String instructorId;

  const BookingFormScreen({
    super.key,
    required this.instructorId,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  int _selectedDuration = 60;
  String _selectedLevel = 'beginner';
  String? _selectedLocation;
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();

  List<String> _availableLocations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final instrProvider = context.read<InstructorProvider>();
      instrProvider.loadInstructorById(widget.instructorId);
      context
          .read<AvailabilityProvider>()
          .loadWeeklySchedule(widget.instructorId);

      // Set user's surf level as default
      final userLevel = context.read<AuthProvider>().profile?.surfLevel;
      if (userLevel != null) {
        setState(() => _selectedLevel = userLevel);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null; // Reset time when date changes
      });

      // Load availability for selected date
      if (mounted) {
        context.read<AvailabilityProvider>().loadAvailabilityForDate(
              instructorId: widget.instructorId,
              date: DateFormat('yyyy-MM-dd').format(date),
              dayOfWeek: date.weekday % 7, // Convert to 0=Sun
            );
      }
    }
  }

  Future<void> _handleBooking() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedLocation == null ||
        _selectedLocation!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    final success = await bookingProvider.createBooking(
      userId: authProvider.userId,
      instructorId: widget.instructorId,
      bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      startTime: _selectedTime!,
      duration: _selectedDuration,
      location: _selectedLocation!,
      surfLevel: _selectedLevel,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (success && mounted) {
      context.go('/user/booking-confirm', extra: {
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'time': _selectedTime,
        'duration': _selectedDuration,
        'location': _selectedLocation,
        'surfLevel': _selectedLevel,
        'instructorName': _getInstructorName(),
      });
    } else if (mounted && bookingProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  String _getInstructorName() {
    final data = context.read<InstructorProvider>().selectedInstructor;
    if (data != null) {
      return ProfileModel.fromMap(data).fullName;
    }
    return 'Instructor';
  }

  @override
  Widget build(BuildContext context) {
    final instructorProvider = context.watch<InstructorProvider>();
    final availabilityProvider = context.watch<AvailabilityProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final data = instructorProvider.selectedInstructor;

    // Extract locations from instructor details
    if (data != null && _availableLocations.isEmpty) {
      final details = instructorProvider.getInstructorDetails(data);
      if (details != null && details.locationsServed.isNotEmpty) {
        _availableLocations = details.locationsServed;
        _selectedLocation ??= _availableLocations.first;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Session'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/user/instructor/${widget.instructorId}'),
        ),
      ),
      body: data == null
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- INSTRUCTOR INFO ----------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: data['avatar_url'] != null
                              ? NetworkImage(data['avatar_url'])
                              : null,
                          child: data['avatar_url'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['full_name'] ?? 'Instructor',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Surf Instructor',
                                style: TextStyle(
                                  color: AppTheme.greyText,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ---------- SELECT DATE ----------
                  const Text(
                    'Select Date *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? Helpers.formatDateFull(
                                    _selectedDate!.toIso8601String())
                                : 'Choose a date',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate != null
                                  ? AppTheme.darkText
                                  : AppTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---------- SELECT TIME ----------
                  const Text(
                    'Select Time *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedDate == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Please select a date first',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.greyText),
                      ),
                    )
                  else if (availabilityProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (availabilityProvider.dateSlots.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No available slots on this date',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: availabilityProvider.dateSlots.map((slot) {
                        final isSelected = _selectedTime == slot.startTime;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedTime = slot.startTime);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              Helpers.formatTime(slot.startTime),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.darkText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  // ---------- DURATION ----------
                  const Text(
                    'Duration *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: AppConstants.durations.map((dur) {
                      final isSelected = _selectedDuration == dur;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedDuration = dur);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              AppConstants.durationLabels[dur]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.darkText,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ---------- LOCATION ----------
                  const Text(
                    'Location *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_availableLocations.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableLocations.map((loc) {
                        final isSelected = _selectedLocation == loc;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedLocation = loc);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.greyText,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  loc,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: 'Enter location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      onChanged: (val) {
                        setState(() => _selectedLocation = val);
                      },
                    ),

                  const SizedBox(height: 24),

                  // ---------- SURF LEVEL ----------
                  const Text(
                    'Surf Level *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: AppConstants.surfLevels.map((level) {
                      final isSelected = _selectedLevel == level;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedLevel = level);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              Helpers.surfLevelDisplay(level),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.darkText,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ---------- NOTES ----------
                  const Text(
                    'Notes (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          'Any special requests or notes for the instructor...',
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ---------- BOOK BUTTON ----------
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          bookingProvider.isLoading ? null : _handleBooking,
                      child: bookingProvider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Confirm Booking'),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
