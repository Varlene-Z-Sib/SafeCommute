import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/route_planning_screen.dart';
import 'screens/live_navigation_screen.dart';
//import 'screens/safety_reporting_screen.dart';
//import 'screens/safety_alerts_screen.dart';
import 'screens/emergency_sos_screen.dart';
import 'screens/profile_settings_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(SafeCommuteApp());
}

class SafeCommuteApp extends StatelessWidget {
  const SafeCommuteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeCommute',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthScreen(),
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
        //'/route-planning': (context) => RoutePlanningScreen(),
        //'/live-navigation': (context) => LiveNavigationScreen(),
        //'/safety-reporting': (context) => SafetyReportingScreen(),
        //'/safety-alerts': (context) => SafetyAlertsScreen(),
        '/emergency-sos': (context) => EmergencySosScreen(),
        '/profile-settings': (context) => ProfileSettingsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
