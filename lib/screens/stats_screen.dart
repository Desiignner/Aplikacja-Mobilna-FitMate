import 'dart:math';
import 'package:fitmate/models/scheduled_workout.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final AppDataService _appData = AppDataService();
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    await _appData.loadScheduledWorkouts();
    if (mounted) setState(() {});
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDate =
          DateTime(_focusedDate.year, _focusedDate.month + offset, 1);
    });
  }

  // Gets chart data for the selected month broken down by weeks or days?
  // Let's stick to Weekly Progress but relevant to the selected month?
  // Actually, the original implementation was "Weekly Progress" (last 7 days?).
  // _getWeeklyChartData logic: `startOfWeek = today.subtract...` -> It was "Recent activity".
  // If we view historical months, "Weekly Progress" might be confusing.
  // Let's change it to "Monthly Progress" (Volume per week in that month/year?).
  // Or just keep "Weekly Progress" as "Recent Activity" separate from the Historical Month Stats?
  // The user asked for "stats from previous months".
  // I will replace the "Total Volume this month" card with a "Monthly Stats" card that has the navigator.

  Map<String, dynamic> _calculateMonthlyStats() {
    final startOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final endOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);

    final monthlyWorkouts = _appData.scheduledWorkouts.where((w) {
      return w.status == WorkoutStatus.completed &&
          w.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          w.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    double totalVolume = 0;
    for (var w in monthlyWorkouts) {
      for (var exercise in w.exercises) {
        for (var set in exercise.sets) {
          totalVolume += set.reps * set.weight;
        }
      }
    }

    return {
      'volume': totalVolume,
      'workouts': monthlyWorkouts.length,
    };
  }

  // Kept original weekly chart as "Recent Activity" for now, or should I make it reflect the selected month?
  // User asked "check stats from previous months".
  // I'll make the Chart reflect the selected month's 4 weeks? That's hard to align.
  // I will leave the "Weekly Progress" as distinct "Last 7 Days" (maybe rename it) and add the Historical Stats above it.

  List<double> _getWeeklyChartData() {
    List<double> weeklyVolumes = List.filled(7, 0.0);
    final today = DateTime.now(); // Always show recent week for this chart?
    // Or should this specific chart technically be "This Month's Activity"?
    // The user moved it to Stats screen to see HISTORY.
    // So the chart should probably assume the selected month if possible.
    // But rendering a whole month in a bar chart is crowded (30 bars).
    // Let's keep "Weekly Progress" as "Current Week" and just add the Historical Card.

    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final workoutsOnDay = _appData.getWorkoutsForDay(day);

      if (workoutsOnDay.isNotEmpty) {
        double dailyTotal = 0;
        for (var workout in workoutsOnDay) {
          if (workout.status == WorkoutStatus.completed) {
            for (var exercise in workout.exercises) {
              for (var set in exercise.sets) {
                dailyTotal += set.reps * set.weight;
              }
            }
          }
        }
        weeklyVolumes[i] = dailyTotal;
      }
    }
    return weeklyVolumes;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyStats = _calculateMonthlyStats();
    final formattedVolume =
        NumberFormat("#,##0", "en_US").format(monthlyStats['volume']);
    final monthName = DateFormat.MMMM().format(_focusedDate);
    final year = _focusedDate.year;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ValueListenableBuilder<Map<String, double>>(
        valueListenable: _appData.statistics,
        builder: (context, stats, child) {
          // Note: stats['totalVolume'] from appData is hardcoded for current month in service.
          // We are calculating our own monthlyStats based on _focusedDate now.

          final weeklyVolumes = _getWeeklyChartData();
          final double maxVolume =
              weeklyVolumes.isNotEmpty ? weeklyVolumes.reduce(max) : 0.0;
          final double chartMaxY = maxVolume == 0 ? 100.0 : (maxVolume * 1.2);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MONTH NAVIGATION HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text('$monthName $year',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      icon:
                          const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // MONTHLY STATS CARD
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$monthName Statistics",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Volume",
                                  style: TextStyle(color: secondaryTextColor)),
                              const SizedBox(height: 4),
                              Text("$formattedVolume kg",
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Workouts",
                                  style: TextStyle(color: secondaryTextColor)),
                              const SizedBox(height: 4),
                              Text("${monthlyStats['workouts']}",
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // CURRENT WEEK CHART (Unchanged logic, just label update maybe?)
                AppCard(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        "Current Week Activity", // Renamed from "Weekly Progress" to be clear
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: chartMaxY,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0) return const Text('');
                                      return Text(value.toInt().toString(),
                                          style: const TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 10));
                                    })),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  const style = TextStyle(
                                      color: secondaryTextColor, fontSize: 12);
                                  String text;
                                  switch (value.toInt()) {
                                    case 0:
                                      text = 'Mon';
                                      break;
                                    case 1:
                                      text = 'Tue';
                                      break;
                                    case 2:
                                      text = 'Wed';
                                      break;
                                    case 3:
                                      text = 'Thu';
                                      break;
                                    case 4:
                                      text = 'Fri';
                                      break;
                                    case 5:
                                      text = 'Sat';
                                      break;
                                    case 6:
                                      text = 'Sun';
                                      break;
                                    default:
                                      text = '';
                                      break;
                                  }
                                  return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 4,
                                      child: Text(text, style: style));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: List.generate(
                              7,
                              (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: weeklyVolumes[index].toDouble(),
                                        color: primaryColor,
                                        width: 16,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  )),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
