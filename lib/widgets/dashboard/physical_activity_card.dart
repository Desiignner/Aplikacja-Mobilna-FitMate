import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:fitmate/widgets/dashboard/activity_stat_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PhysicalActivityCard extends StatelessWidget {
  const PhysicalActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Physical Activity', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.4), FlSpot(3, 2),
                      FlSpot(4, 1.8), FlSpot(5, 2.5), FlSpot(6, 2.2), FlSpot(7, 2.8),
                      FlSpot(8.5, 2.5), FlSpot(9.5, 3), FlSpot(10.5, 2.7), FlSpot(11.5, 3.2),
                    ],
                    isCurved: true,
                    color: primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: [const FlSpot(8, 2.5)],
                    color: primaryColor.withOpacity(0.5),
                    barWidth: 10,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(radius: 6, color: Colors.transparent, strokeWidth: 2, strokeColor: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('This Week', style: TextStyle(color: secondaryTextColor, fontSize: 12)),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActivityStat(label: 'Steps', value: '8 240'),
              ActivityStat(label: 'Calories', value: '720'),
              ActivityStat(label: 'Activity', value: '2h 50m'),
            ],
          ),
        ],
      ),
    );
  }
}