import 'package:flutter/material.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/screens/auth/splash_screen.dart';

void main() {
  runApp(const AthidhiApp());
}

class AthidhiApp extends StatelessWidget {
  const AthidhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Athidhi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
