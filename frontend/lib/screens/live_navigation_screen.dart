// screens/live_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';

class LiveNavigationScreen extends StatefulWidget {
  const LiveNavigationScreen({super.key});

  @override
  _LiveNavigationScreenState createState() => _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends State<LiveNavigationScreen> {
  final bool _isNavigating = true;
  final bool _isOnline = true;
  final String _currentStep = "Walk to Park Station";
  final String _nextTransport = "Taxi to Johannesburg CBD";
  final String _eta = "12:45 PM";
  final String _currentSafetyLevel = "Safe";
  final double _routeProgress = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map View (Placeholder)
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF87CEEB).withOpacity(0.3),
                  Color(0xFF98FB98).withOpacity(0.3),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 120, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Map Integration',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Google Maps / MapBox integration required',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),

          // Top Status Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => _showExitDialog(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'ETA: $_eta',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _getSafetyIcon(_currentSafetyLevel),
                            SizedBox(width: 4),
                            Text(
                              _currentSafetyLevel,
                              style: TextStyle(
                                color: _getSafetyColor(_currentSafetyLevel),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isOnline
                          ? AppColors.primarySafetyGreen
                          : AppColors.alertRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isOnline ? Icons.wifi : Icons.wifi_off,
                          size: 14,
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
                ],
              ),
            ),
          ),

          // Route Progress Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 16,
            right: 16,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _routeProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Emergency SOS Button (Floating)
          Positioned(
            top: MediaQuery.of(context).padding.top + 120,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/emergency-sos'),
              backgroundColor: AppColors.alertRed,
              mini: true,
              child: Icon(Icons.emergency, color: Colors.white),
            ),
          ),

          // Navigation Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildNavigationBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Current Step
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_walk,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentStep,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Continue straight for 200m',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '3 min',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Next Transport
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primarySafetyGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_taxi,
                    color: AppColors.primarySafetyGreen,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next: $_nextTransport',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Platform 3 • R12.00',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySafetyGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SAFE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _reportIncident,
                    icon: Icon(Icons.report, size: 18),
                    label: Text('Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warningAmber,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareLocation,
                    icon: Icon(Icons.share_location, size: 18),
                    label: Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _getSafetyIcon(String level) {
    switch (level.toLowerCase()) {
      case 'safe':
        return Icon(
          Icons.shield,
          color: AppColors.primarySafetyGreen,
          size: 16,
        );
      case 'moderate':
        return Icon(Icons.warning, color: AppColors.warningAmber, size: 16);
      case 'high':
        return Icon(Icons.dangerous, color: AppColors.alertRed, size: 16);
      default:
        return Icon(
          Icons.shield,
          color: AppColors.primarySafetyGreen,
          size: 16,
        );
    }
  }

  Color _getSafetyColor(String level) {
    switch (level.toLowerCase()) {
      case 'safe':
        return AppColors.primarySafetyGreen;
      case 'moderate':
        return AppColors.warningAmber;
      case 'high':
        return AppColors.alertRed;
      default:
        return AppColors.primarySafetyGreen;
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Navigation'),
        content: Text(
          'Are you sure you want to exit navigation? Your route progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
            ),
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _reportIncident() {
    Navigator.pushNamed(context, '/safety-reporting');
  }

  void _shareLocation() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location shared with emergency contacts'),
        backgroundColor: AppColors.primarySafetyGreen,
      ),
    );
  }
}
