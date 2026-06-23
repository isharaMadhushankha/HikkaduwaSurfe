import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/availability_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 1;

  final List<String> _dayNames = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];
  final List<String> _dayFullNames = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final userId = context.read<AuthProvider>().userId;
        if (userId.isNotEmpty) {
          context.read<AvailabilityProvider>().loadWeeklySchedule(userId);
        }
      } catch (e) {
        debugPrint('=== Init error: $e ===');
      }
    });
  }

  Future<void> _addTimeSlot() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (startTime == null || !mounted) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: startTime.hour + 1, minute: 0),
    );
    if (endTime == null || !mounted) return;

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    if (endMinutes <= startMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
      }
      return;
    }

    final startStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
    final endStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

    try {
      final userId = context.read<AuthProvider>().userId;
      await context.read<AvailabilityProvider>().addSlot(
            instructorId: userId,
            dayOfWeek: _selectedDay,
            startTime: startStr,
            endTime: endStr,
          );
    } catch (e) {
      debugPrint('=== Add slot error: $e ===');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTimeSlot,
        icon: const Icon(Icons.add),
        label: const Text('Add Slot'),
      ),
      body: Consumer<AvailabilityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<dynamic> daySlots = [];
          try {
            daySlots = provider.getSlotsForDay(_selectedDay);
          } catch (e) {
            debugPrint('=== getSlotsForDay error: $e ===');
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Day Selector ──
              const Text(
                'Select Day',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final isSelected = _selectedDay == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = index),
                    child: Container(
                      width: 44,
                      height: 56,
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
                      alignment: Alignment.center,
                      child: Text(
                        _dayNames[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // ── Day Title ──
              Text(
                _dayFullNames[_selectedDay],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${daySlots.length} time slot${daySlots.length == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // ── Slots or Empty ──
              if (daySlots.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.event_busy,
                          size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'No slots for ${_dayFullNames[_selectedDay]}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap + Add Slot to set availability',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...daySlots.map((slot) {
                  String startTime = '';
                  String endTime = '';
                  String slotId = '';
                  try {
                    startTime = slot.startTime ?? '';
                    endTime = slot.endTime ?? '';
                    slotId = slot.id ?? '';
                  } catch (e) {
                    debugPrint('=== Slot field error: $e ===');
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '$startTime – $endTime',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            try {
                              final userId =
                                  context.read<AuthProvider>().userId;
                              await context
                                  .read<AvailabilityProvider>()
                                  .deleteSlot(
                                    slotId: slotId,
                                    instructorId: userId,
                                  );
                            } catch (e) {
                              debugPrint('=== Delete error: $e ===');
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
