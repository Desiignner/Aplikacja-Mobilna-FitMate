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

  List<double> _getWeeklyChartData() {
    List<double> weeklyVolumes = List.filled(7, 0.0);
    final today = DateTime.now();
    // Poniedziałek jest 1, Niedziela jest 7.
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
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ValueListenableBuilder<Map<String, double>>(
        valueListenable: _appData.statistics,
        builder: (context, stats, child) {
          final weeklyVolumes = _getWeeklyChartData();
          final double maxVolume = weeklyVolumes.isNotEmpty ? weeklyVolumes.reduce(max) : 0.0;
          final double chartMaxY = maxVolume == 0 ? 100.0 : (maxVolume * 1.2);

          final totalVolume = stats['totalVolume'] ?? 0.0;
          final formattedVolume = NumberFormat("#,##0", "en_US").format(totalVolume);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Volume", style: TextStyle(fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text("$formattedVolume kg", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(height: 4),
                      const Text("all time", style: TextStyle(color: secondaryTextColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Weekly Progress", style: TextStyle(fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: chartMaxY,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                                  if (value == 0) return const Text('');
                                  return Text(value.toInt().toString(), style: const TextStyle(color: secondaryTextColor, fontSize: 10));
                              })),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(color: secondaryTextColor, fontSize: 12);
                                    String text;
                                    switch (value.toInt()) {
                                      case 0: text = 'Mon'; break;
                                      case 1: text = 'Tue'; break;
                                      case 2: text = 'Wed'; break;
                                      case 3: text = 'Thu'; break;
                                      case 4: text = 'Fri'; break;
                                      case 5: text = 'Sat'; break;
                                      case 6: text = 'Sun'; break;
                                      default: text = ''; break;
                                    }
                                    return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
                                  },
                                ),
                              ),
                              // ================================
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            barGroups: List.generate(7, (index) => BarChartGroupData(
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
                  )
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}