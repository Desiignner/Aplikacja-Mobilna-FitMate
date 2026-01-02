import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:flutter/material.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:intl/intl.dart';

class ActivityCalendarWidget extends StatelessWidget {
  const ActivityCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AppDataService appData = AppDataService();
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    // Adjusted for Monday start: Mon(1)->0, ..., Sun(7)->6
    final weekdayOfFirstDay = (firstDayOfMonth.weekday - 1) % 7;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthName = DateFormat.MMMM().format(now);

    return ValueListenableBuilder<Map<String, double>>(
      valueListenable: appData
          .statistics, // Rebuild when stats change (implies workouts changed)
      builder: (context, stats, child) {
        // Get completed workout days for current month
        final completedDays = appData.scheduledWorkouts
            .where((w) =>
                w.status == WorkoutStatus.completed &&
                w.date.year == now.year &&
                w.date.month == now.month)
            .map((w) => w.date.day)
            .toSet();

        // Get planned workout days for current month (excluding those also completed)
        final plannedDays = appData.scheduledWorkouts
            .where((w) =>
                w.status == WorkoutStatus.planned &&
                w.date.year == now.year &&
                w.date.month == now.month)
            .map((w) => w.date.day)
            .toSet();

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$monthName Activity',
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              _buildCalendarGrid(now, weekdayOfFirstDay, daysInMonth,
                  completedDays, plannedDays),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(DateTime now, int weekdayOfFirstDay,
      int daysInMonth, Set<int> completedDays, Set<int> plannedDays) {
    const daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S']; // Start on Monday

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek
              .map((day) => Text(day,
                  style:
                      const TextStyle(color: secondaryTextColor, fontSize: 12)))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 4,
          ),
          itemCount: daysInMonth + weekdayOfFirstDay,
          itemBuilder: (context, index) {
            if (index < weekdayOfFirstDay) {
              return const SizedBox
                  .shrink(); // Empty space before the first day
            }

            final day = index - weekdayOfFirstDay + 1;
            final isToday = day == now.day;
            final isCompleted = completedDays.contains(day);
            final isPlanned = plannedDays.contains(day);

            // Determine base decoration based on status
            BoxDecoration baseDecoration;
            if (isCompleted) {
              baseDecoration = BoxDecoration(
                color: Colors.grey, // Grey for "Done"
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(6),
              );
            } else if (isPlanned) {
              baseDecoration = BoxDecoration(
                color: const Color(0xFF1B5E20), // Dark Green
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(6),
              );
            } else {
              baseDecoration = const BoxDecoration(
                shape: BoxShape.circle,
              );
            }

            // Apply "Today" indicator (Red Border) on top
            BoxDecoration decoration = baseDecoration;
            if (isToday) {
              decoration = baseDecoration.copyWith(
                border: Border.all(color: Colors.red, width: 2),
              );
            }

            return Center(
              child: Container(
                width: 30, // Fixed size for perfect centering
                height: 30,
                alignment: Alignment.center,
                decoration: decoration,
                child: Text(
                  '$day',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height:
                        1.0, // Force line height to 1.0 for better centering
                    fontWeight: (isCompleted || isPlanned || isToday)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
