import 'package:fitmate/models/plan.dart';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/screens/active_workout_screen.dart';
import 'package:fitmate/screens/workout_summary_screen.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final AppDataService _appData = AppDataService();
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadData();
  }

  Future<void> _loadData() async {
    await _appData.loadScheduledWorkouts();
    if (mounted) setState(() {});
  }

  List<ScheduledWorkout> _getWorkoutsForDay(DateTime day) {
    return _appData.getWorkoutsForDay(day);
  }

  void _showScheduleDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardBackgroundColor,
          title: const Text('Schedule a Workout'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _appData.plans.length,
              itemBuilder: (context, index) {
                final plan = _appData.plans[index];
                return ListTile(
                  title: Text(plan.name,
                      style: const TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _appData.scheduleWorkout(plan, date);
                    if (mounted) setState(() {});
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.white)))
          ],
        );
      },
    );
  }

  void _deleteWorkout(ScheduledWorkout workout) async {
    await _appData.deleteScheduledWorkout(workout);
    if (mounted) setState(() {});
  }

  void _markWorkoutAsCompleted(ScheduledWorkout workout) async {
    await _appData.completeWorkout(workout, context);
    if (mounted) setState(() {});
  }

  void _startWorkout(ScheduledWorkout workout) async {
    final bool? workoutFinished = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (context) => ActiveWorkoutScreen(workout: workout)),
    );
    if (workoutFinished == true && mounted) {
      await _appData.completeWorkout(workout, context);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutsForSelectedDay =
        _getWorkoutsForDay(_selectedDay ?? _focusedDay);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Calendar'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add, color: primaryColor),
              onPressed: () => _showScheduleDialog(_selectedDay ?? _focusedDay))
        ],
      ),
      body: Column(
        children: [
          TableCalendar<ScheduledWorkout>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
              CalendarFormat.twoWeeks: '2 weeks',
              CalendarFormat.week: 'Week',
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getWorkoutsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonTextStyle: const TextStyle(color: Colors.white),
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: secondaryTextColor),
                borderRadius: BorderRadius.circular(12.0),
              ),
              titleTextStyle: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              leftChevronIcon:
                  const Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon:
                  const Icon(Icons.chevron_right, color: Colors.white),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                  color: todayBackgroundColor, shape: BoxShape.circle),
              todayTextStyle: const TextStyle(color: todayTextColor),
              selectedDecoration:
                  BoxDecoration(color: primaryColor, shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              markerMargin: const EdgeInsets.only(top: 0),
              markersAlignment: Alignment.topCenter,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: workoutsForSelectedDay.length,
              itemBuilder: (context, index) {
                final workout = workoutsForSelectedDay[index];
                return _ActivityTile(
                  workout: workout,
                  onDelete: () => _deleteWorkout(workout),
                  onMarkAsCompleted: () => _markWorkoutAsCompleted(workout),
                  onStart: () => _startWorkout(workout),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ScheduledWorkout workout;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsCompleted;
  final VoidCallback onStart;

  const _ActivityTile({
    required this.workout,
    required this.onDelete,
    required this.onMarkAsCompleted,
    required this.onStart,
  });

  void _editOrViewWorkout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutSummaryScreen(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = workout.status == WorkoutStatus.completed;
    final icon = isCompleted ? Icons.check_circle : Icons.pending_actions;
    final color = isCompleted ? primaryColor : secondaryTextColor;

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (isCompleted) {
            _editOrViewWorkout(context);
          } else {
            onStart();
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.planName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        isCompleted
                            ? 'Completed at ${workout.time}'
                            : 'Planned',
                        style: TextStyle(color: color, fontSize: 14)),
                  ],
                ),
              ),
              // Widoczne przyciski akcji
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Przycisk "Oznacz jako ukończony" (tylko dla zaplanowanych)
                  if (!isCompleted)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white70),
                      tooltip: 'Mark as Completed',
                      onPressed: onMarkAsCompleted,
                    ),
                  // Przycisk "Usuń"
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
