// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_bottom_navigation.dart';
import '../../widgets/safety_status_widget.dart';
import '../../widgets/emergency_button.dart';
import '../../widgets/emergency_type_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final bool _isOnline = true;
  final String _currentLocation = 'Johannesburg CBD';
  String _safetyLevel = 'Safe';
  bool _showEmergencySelector = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              width: 28,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.shield),
            ),
            SizedBox(width: 8),
            Text('SafeCommute'),
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _isOnline
                  ? AppColors.primarySafetyGreen
                  : AppColors.alertRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(width: 4),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/profile-settings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Header
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentLocation,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Plan Safe Route Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/route-planning'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Plan Safe Route',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Safety Status Widget
                  SafetyStatusWidget(
                    safetyLevel: _safetyLevel,
                    location: _currentLocation,
                  ),
                  SizedBox(height: 24),

                  // Emergency SOS Button
                  EmergencyButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/emergency-sos'),
                  ),
                  SizedBox(height: 24),

                  // Recent Safety Alerts
                  Text(
                    'Recent Safety Alerts',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 16),
                  _buildRecentAlerts(),
                  SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 16),
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
          // Emergency Type Selector Overlay
          if (_showEmergencySelector)
            GestureDetector(
              onTap: _hideEmergencySelector,
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Spacer(),
                    EmergencyTypeSelector(
                      onEmergencySelected: _handleEmergencySelected,
                      onCancel: _hideEmergencySelector,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        onEmergencyTap: _showEmergencyTypeSelector,
      ),
    );
  }

  Widget _buildRecentAlerts() {
    final alerts = [
      {
        'title': 'Suspicious Activity',
        'location': 'Park Station',
        'time': '5 min ago',
        'severity': 'moderate',
        'distance': '0.5 km',
      },
      {
        'title': 'Theft Reported',
        'location': 'Bree Street Taxi Rank',
        'time': '15 min ago',
        'severity': 'high',
        'distance': '1.2 km',
      },
      {
        'title': 'All Clear',
        'location': 'Johannesburg CBD',
        'time': '30 min ago',
        'severity': 'safe',
        'distance': '0.1 km',
      },
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Container(
            width: 280,
            margin: EdgeInsets.only(right: 12),
            child: Card(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/safety-alerts'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _getSeverityIcon(alert['severity'] as String),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alert['title'] as String,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              alert['location'] as String,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            alert['time'] as String,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            alert['distance'] as String,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.report_problem,
            title: 'Report\nIncident',
            color: AppColors.warningAmber,
            onTap: () => Navigator.pushNamed(context, '/safety-reporting'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.notifications,
            title: 'View\nAlerts',
            color: AppColors.primaryBlue,
            onTap: () => Navigator.pushNamed(context, '/safety-alerts'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.share_location,
            title: 'Share\nLocation',
            color: AppColors.primarySafetyGreen,
            onTap: _shareLocation,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSeverityIcon(String severity) {
    Color color;
    IconData icon;

    switch (severity.toLowerCase()) {
      case 'safe':
        color = AppColors.primarySafetyGreen;
        icon = Icons.check_circle;
        break;
      case 'moderate':
        color = AppColors.warningAmber;
        icon = Icons.warning;
        break;
      case 'high':
        color = AppColors.alertRed;
        icon = Icons.dangerous;
        break;
      default:
        color = AppColors.primarySafetyGreen;
        icon = Icons.info;
    }

    return Icon(icon, color: color, size: 20);
  }

  Future<void> _refreshData() async {
    // Simulate data refresh
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _safetyLevel = [
        'Safe',
        'Moderate',
        'High',
      ][DateTime.now().millisecond % 3];
    });
  }

  void _shareLocation() {
    // Implement location sharing functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Location'),
        content: Text(
          'Your current location will be shared with your emergency contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Location shared successfully')),
              );
            },
            child: Text('Share'),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/route-planning');
        break;
      case 2:
        Navigator.pushNamed(context, '/safety-alerts');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }

  void _showEmergencyTypeSelector() {
    setState(() {
      _showEmergencySelector = true;
    });
  }

  void _hideEmergencySelector() {
    setState(() {
      _showEmergencySelector = false;
    });
  }

  void _handleEmergencySelected(String emergencyType) {
    _hideEmergencySelector();

    // Handle the selected emergency type
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Alert'),
        content: Text(
          'You selected: ${emergencyType.toUpperCase()}\n\nInitiating emergency protocol...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Navigate to emergency handling screen or call emergency services
              Navigator.pushNamed(
                context,
                '/emergency-sos',
                arguments: emergencyType,
              );
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}
