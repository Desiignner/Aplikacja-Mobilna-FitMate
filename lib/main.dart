import 'package:flutter/material.dart';
import 'package:fitmate/screens/login_screen.dart';
import 'package:fitmate/utils/app_colors.dart';

void main() {
  runApp(const FitmateApp());
}

class FitmateApp extends StatelessWidget {
  const FitmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitmate App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: mainBackgroundColor,
        fontFamily: 'SFProDisplay',
        appBarTheme: const AppBarTheme(
            backgroundColor: cardBackgroundColor,
            elevation: 0,
            titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      home: const LoginScreen(),
    );
  }
}
