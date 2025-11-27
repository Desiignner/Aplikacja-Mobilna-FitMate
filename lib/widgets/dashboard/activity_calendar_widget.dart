import 'package:flutter/material.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:intl/intl.dart';

class ActivityCalendarWidget extends StatelessWidget {
  const ActivityCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Dane do symulacji
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    // Dzień tygodnia (poniedziałek=1, niedziela=7). Przesunięcie dla siatki zaczynającej się od niedzieli.
    final weekdayOfFirstDay = firstDayOfMonth.weekday % 7;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthName = DateFormat.MMMM().format(now);

    // Symulacja dni z treningiem
    final workoutDays = {15, 21, 22, 23, 24};

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$monthName Activity', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          _buildCalendarGrid(now, weekdayOfFirstDay, daysInMonth, workoutDays),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
      DateTime now, int weekdayOfFirstDay, int daysInMonth, Set<int> workoutDays) {
    const daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek
              .map((day) => Text(day, style: const TextStyle(color: secondaryTextColor, fontSize: 12)))
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
              return const SizedBox.shrink(); // Puste miejsce przed pierwszym dniem miesiąca
            }

            final day = index - weekdayOfFirstDay + 1;
            final isToday = day == now.day;
            final isWorkoutDay = workoutDays.contains(day);

            return Container(
              alignment: Alignment.center,
              decoration: isToday
                  ? BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                '$day',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isWorkoutDay ? FontWeight.bold : FontWeight.normal,
                  decoration: isWorkoutDay ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: Colors.white,
                  decorationThickness: 2,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}