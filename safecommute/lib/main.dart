import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/route_planning_screen.dart';
import 'screens/live_navigation_screen.dart';
import 'screens/safety_reporting_screen.dart';
import 'screens/safety_alerts_screen.dart';
import 'screens/stations_screen.dart';
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/auth':
            return MaterialPageRoute(builder: (_) => AuthScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomeScreen());
          case '/route-planning':
            return MaterialPageRoute(builder: (_) => RoutePlanningScreen());
          case '/live-navigation':
            return MaterialPageRoute(builder: (_) => LiveNavigationScreen());
          case '/safety-reporting':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => SafetyReportingScreen(
                preSelectedIncidentType: args?['incidentType'],
              ),
            );
          case '/safety-alerts':
            return MaterialPageRoute(builder: (_) => SafetyAlertsScreen());
          case '/stations':
            return MaterialPageRoute(builder: (_) => StationsScreen());
          case '/emergency-sos':
            return MaterialPageRoute(builder: (_) => EmergencySosScreen());
          case '/profile-settings':
            return MaterialPageRoute(builder: (_) => ProfileSettingsScreen());
          default:
            return MaterialPageRoute(builder: (_) => AuthScreen());
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
