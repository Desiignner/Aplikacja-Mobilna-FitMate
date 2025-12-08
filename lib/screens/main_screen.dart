import 'package:fitmate/screens/calendar_screen.dart';
import 'package:fitmate/screens/dashboard_screen.dart';
import 'package:fitmate/screens/stats_screen.dart';
import 'package:fitmate/screens/workouts_screen.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final appData = AppDataService();
    appData.loadScheduledWorkouts();
    appData.loadPlans();
    appData.loadUserMetrics();
    appData.loadGoals();
  }

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    StatsScreen(),
    CalendarScreen(),
    WorkoutsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: cardBackgroundColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: secondaryTextColor),
            activeIcon: Icon(Icons.home, color: primaryColor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined, color: secondaryTextColor),
            activeIcon: Icon(Icons.bar_chart, color: primaryColor),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.calendar_today_outlined, color: secondaryTextColor),
            activeIcon: Icon(Icons.calendar_today, color: primaryColor),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.fitness_center_outlined, color: secondaryTextColor),
            activeIcon: Icon(Icons.fitness_center, color: primaryColor),
            label: 'Workouts',
          ),
        ],
      ),
    );
  }
}
