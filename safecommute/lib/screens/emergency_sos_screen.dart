import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/app_colors.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  _EmergencySosScreenState createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countdownController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _countdownAnimation;

  Timer? _countdownTimer;
  int _countdownSeconds = 10;
  bool _isCountdownActive = false;
  bool _isLocationSharing = false;
  bool _silentMode = false;
  final String _currentLocation = 'Johannesburg CBD, South Africa';

  final List<Map<String, String>> _emergencyContacts = [
    {'name': 'Police', 'number': '10111', 'icon': 'police'},
    {'name': 'Medical', 'number': '10177', 'icon': 'medical'},
    {'name': 'Fire', 'number': '10111', 'icon': 'fire'},
    {'name': 'Private Security', 'number': '0800 123 456', 'icon': 'security'},
  ];

  final List<Map<String, String>> _personalContacts = [
    {'name': 'John Doe', 'number': '+27 82 123 4567'},
    {'name': 'Jane Smith', 'number': '+27 83 987 6543'},
    {'name': 'Emergency Contact', 'number': '+27 84 555 0123'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _countdownController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _countdownAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alertRed,
      appBar: AppBar(
        backgroundColor: AppColors.alertRed,
        foregroundColor: Colors.white,
        title: Text(
          'EMERGENCY SOS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Emergency Status
              if (_isCountdownActive) _buildCountdownSection(),

              // Location Info
              _buildLocationInfo(),

              SizedBox(height: 24),

              // Main Emergency Button
              Expanded(child: Center(child: _buildMainEmergencyButton())),

              SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),

              SizedBox(height: 24),

              // Emergency Contacts
              _buildEmergencyContacts(),

              SizedBox(height: 16),

              // Personal Contacts
              _buildPersonalContacts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'CALLING EMERGENCY SERVICES IN',
            style: TextStyle(
              color: AppColors.alertRed,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          AnimatedBuilder(
            animation: _countdownAnimation,
            builder: (context, child) {
              return Text(
                '$_countdownSeconds',
                style: TextStyle(
                  color: AppColors.alertRed,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelCountdown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                  child: Text('CANCEL'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _callEmergencyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alertRed,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('CALL NOW'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.alertRed, size: 24),
              SizedBox(width: 8),
              Text(
                'Current Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _currentLocation,
            style: TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.share_location,
                color: _isLocationSharing
                    ? AppColors.primarySafetyGreen
                    : Colors.grey,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                _isLocationSharing
                    ? 'Sharing live location'
                    : 'Location sharing off',
                style: TextStyle(
                  color: _isLocationSharing
                      ? AppColors.primarySafetyGreen
                      : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Switch(
                value: _isLocationSharing,
                onChanged: (value) {
                  setState(() {
                    _isLocationSharing = value;
                  });
                },
                activeColor: AppColors.primarySafetyGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainEmergencyButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: _isCountdownActive ? null : _startEmergencyCountdown,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emergency, size: 60, color: AppColors.alertRed),
                  SizedBox(height: 8),
                  Text(
                    'EMERGENCY',
                    style: TextStyle(
                      color: AppColors.alertRed,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'CALL',
                    style: TextStyle(
                      color: AppColors.alertRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.volume_off,
            title: 'Silent\nAlarm',
            isActive: _silentMode,
            onTap: () {
              setState(() {
                _silentMode = !_silentMode;
              });
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.phone_callback,
            title: 'Fake\nCall',
            isActive: false,
            onTap: _startFakeCall,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.share,
            title: 'Share\nLocation',
            isActive: _isLocationSharing,
            onTap: _shareLocationWithContacts,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Card(
      color: isActive ? AppColors.primarySafetyGreen : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppColors.textDark,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Services',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _emergencyContacts.length,
            itemBuilder: (context, index) {
              final contact = _emergencyContacts[index];
              return Container(
                width: 120,
                margin: EdgeInsets.only(right: 12),
                child: Card(
                  child: InkWell(
                    onTap: () => _callNumber(contact['number']!),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getEmergencyIcon(contact['icon']!),
                            size: 32,
                            color: AppColors.alertRed,
                          ),
                          SizedBox(height: 8),
                          Text(
                            contact['name']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Emergency Contacts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _personalContacts.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final contact = _personalContacts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primarySafetyGreen,
                  child: Text(
                    contact['name']![0],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(contact['name']!),
                subtitle: Text(contact['number']!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.call,
                        color: AppColors.primarySafetyGreen,
                      ),
                      onPressed: () => _callNumber(contact['number']!),
                    ),
                    IconButton(
                      icon: Icon(Icons.message, color: AppColors.primaryBlue),
                      onPressed: () => _sendSMS(contact['number']!),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getEmergencyIcon(String type) {
    switch (type) {
      case 'police':
        return Icons.local_police;
      case 'medical':
        return Icons.local_hospital;
      case 'fire':
        return Icons.local_fire_department;
      case 'security':
        return Icons.security;
      default:
        return Icons.emergency;
    }
  }

  void _startEmergencyCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdownSeconds = 10;
    });

    _countdownController.forward();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        _callEmergencyNow();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownController.reset();
    setState(() {
      _isCountdownActive = false;
      _countdownSeconds = 10;
    });
  }

  void _callEmergencyNow() {
    _cancelCountdown();
    _callNumber('10111'); // South African police emergency number
  }

  void _callNumber(String number) {
    // We can try use url_launcher to make the call
    // For now, we'll show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Call'),
        content: Text('Calling $number...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _sendSMS(String number) {
    //We can try use url_launcher to send SMS
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency SMS'),
        content: Text('Sending emergency message to $number...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startFakeCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fake Call'),
        content: Text('Starting fake call for safety...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareLocationWithContacts() {
    setState(() {
      _isLocationSharing = !_isLocationSharing;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLocationSharing
              ? 'Location sharing enabled'
              : 'Location sharing disabled',
        ),
      ),
    );
  }
}
