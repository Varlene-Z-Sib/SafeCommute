import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/route_planning_screen.dart';
import 'screens/live_navigation_screen.dart';
// import 'screens/safety_reporting_screen.dart';
// import 'screens/safety_alerts_screen.dart';
import 'screens/emergency_sos_screen.dart';
import 'screens/profile_settings_screen.dart';

import 'utils/app_colors.dart';
import 'utils/app_theme.dart';
import 'api_service.dart';

void main() {
  // Toggle between test mode and full app mode
  bool testBackend = true;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: testBackend ? BackendTestPage() : SafeCommuteApp(),
  ));
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
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
        // '/route-planning': (context) => RoutePlanningScreen(),
        // '/live-navigation': (context) => LiveNavigationScreen(),
        // '/safety-reporting': (context) => SafetyReportingScreen(),
        // '/safety-alerts': (context) => SafetyAlertsScreen(),
        '/emergency-sos': (context) => EmergencySosScreen(),
        '/profile-settings': (context) => ProfileSettingsScreen(),
        '/test': (context) => BackendTestPage(),
      },
    );
  }
}

// 🔧 Backend test screen
class BackendTestPage extends StatefulWidget {
  @override
  _BackendTestPageState createState() => _BackendTestPageState();
}

class _BackendTestPageState extends State<BackendTestPage> {
  String _response = "Waiting for API...";

  @override
  void initState() {
    super.initState();
    testApiCall();
  }

  Future<void> testApiCall() async {
    final url = Uri.parse('http://127.0.0.1:8000/hello'); // For Android emulator
    try {
      final response = await http.get(url);
      setState(() {
        _response = 'Status: ${response.statusCode}\nBody: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test Backend Connection")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_response),
        ),
      ),
    );
  }
}

// 🧭 Station screen (optional preview of station data from backend)
class StationScreen extends StatefulWidget {
  @override
  _StationScreenState createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> stations = [];

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  void fetchStations() async {
    try {
      final data = await apiService.fetchStations();
      setState(() {
        stations = data;
      });
    } catch (e) {
      print('Error fetching stations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stations')),
      body: ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          return ListTile(
            title: Text(station['name']),
            subtitle: Text('Safety: ${station['safety_level']}'),
          );
        },
      ),
    );
  }
}
