import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../utils/helpers.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<String> availableSlots;
  final String? selectedSlot;
  final List<String> bookedSlots;
  final ValueChanged<String> onSlotSelected;

  const TimeSlotPicker({
    super.key,
    required this.availableSlots,
    this.selectedSlot,
    this.bookedSlots = const [],
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (availableSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 36,
              color: AppTheme.greyText,
            ),
            SizedBox(height: 8),
            Text(
              'No available time slots',
              style: TextStyle(
                color: AppTheme.greyText,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: availableSlots.map((slot) {
        final isSelected = selectedSlot == slot;
        final isBooked = bookedSlots.contains(slot);

        return GestureDetector(
          onTap: isBooked ? null : () => onSlotSelected(slot),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.grey.shade100
                  : isSelected
                      ? AppTheme.primaryColor
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBooked
                    ? Colors.grey.shade300
                    : isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
              ),
            ),
            child: Text(
              Helpers.formatTime(slot),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isBooked
                    ? Colors.grey.shade400
                    : isSelected
                        ? Colors.white
                        : AppTheme.darkText,
                decoration: isBooked
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
