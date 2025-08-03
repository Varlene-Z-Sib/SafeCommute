import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  String _currentLocation = 'Fetching location...';
  Position? _currentPosition;

  late AudioPlayer _audioPlayer;
  SharedPreferences? _prefs;

  List<Map<String, String>> _emergencyContacts = [
    {'name': 'Police', 'number': '10111', 'icon': 'police'},
    {'name': 'Medical', 'number': '10177', 'icon': 'medical'},
    {'name': 'Fire', 'number': '10111', 'icon': 'fire'},
    {'name': 'Private Security', 'number': '0800 123 456', 'icon': 'security'},
  ];

  List<Map<String, String>> _personalContacts = [
    {'name': 'John Doe', 'number': '+27 82 123 4567'},
    {'name': 'Jane Smith', 'number': '+27 83 987 6543'},
    {'name': 'Emergency Contact', 'number': '+27 84 555 0123'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _audioPlayer = AudioPlayer();
    _loadPreferences();
    _requestLocationPermissionAndFetch();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _countdownController = AnimationController(
      duration: const Duration(seconds: 10),
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

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocationSharing = _prefs?.getBool('location_sharing') ?? false;
      _silentMode = _prefs?.getBool('silent_mode') ?? false;
    });
    final emJson = _prefs?.getString('emergency_contacts');
    final perJson = _prefs?.getString('personal_contacts');
    if (emJson != null) {
      _emergencyContacts = List<Map<String, String>>.from(
          jsonDecode(emJson).map((e) => Map<String, String>.from(e)));
    }
    if (perJson != null) {
      _personalContacts = List<Map<String, String>>.from(
          jsonDecode(perJson).map((e) => Map<String, String>.from(e)));
    }
  }

  Future<void> _savePreferences() async {
    await _prefs?.setBool('location_sharing', _isLocationSharing);
    await _prefs?.setBool('silent_mode', _silentMode);
    await _prefs?.setString('emergency_contacts', jsonEncode(_emergencyContacts));
    await _prefs?.setString('personal_contacts', jsonEncode(_personalContacts));
  }

  Future<void> _requestLocationPermissionAndFetch() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        setState(() {
          _currentLocation = 'Location permission denied';
        });
        return;
      }
    }
    _fetchCurrentLocation();
  }
Future<void> _fetchCurrentLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = 'Location services disabled';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = 'Location permission denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation = 'Location permissions permanently denied';
      });
      return;
    }

    // Try to get GPS position
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation =
          'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, '
          'Lng: ${_currentPosition!.longitude.toStringAsFixed(5)}';
    });

    if (_isLocationSharing) {
      await _sendLocationToBackend();
    }
  } catch (e) {
    // Fallback: IP-based location
    try {
      final response = await Uri.parse("https://ipapi.co/json/").resolveUri(Uri());
      setState(() {
        _currentLocation = 'Using IP-based location';
      });
    } catch (e2) {
      setState(() {
        _currentLocation = 'Failed to get location';
      });
    }
  }
}


  Future<void> _sendLocationToBackend() async {
  if (_currentPosition != null) {
    final url = Uri.parse('http://127.0.0.1:8000/location/update');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "lat": _currentPosition!.latitude,
        "lng": _currentPosition!.longitude,
        "user_id": "device_001",
        "share": _isLocationSharing
      }),
    );
    debugPrint("Backend location response: ${response.body}");
  }
}


  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startEmergencyCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdownSeconds = 10;
    });
    _countdownController.forward(from: 0);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });
      if (_countdownSeconds <= 0) {
        _callEmergencyNow();
      }
    });
    if (!_silentMode) {
      _playAlarmSound();
      _vibrateDevice();
    }
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownController.reset();
    setState(() {
      _isCountdownActive = false;
      _countdownSeconds = 10;
    });
    _stopAlarmSound();
  }

  Future<void> _callEmergencyNow() async {
    _cancelCountdown();
    await _callNumber('10111');
  }

  Future<void> _callNumber(String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      _showDialog(
        title: 'Call Failed',
        message: 'Could not initiate call to $number',
      );
    }
  }

  Future<void> _sendSMS(String number) async {
    final Uri smsUri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      _showDialog(
        title: 'SMS Failed',
        message: 'Could not send SMS to $number',
      );
    }
  }

  void _startFakeCall() {
    _showDialog(
      title: 'Fake Call',
      message: 'Starting fake call for safety...',
    );
  }

  void _shareLocationWithContacts() {
    setState(() {
      _isLocationSharing = !_isLocationSharing;
    });
    _savePreferences();
    if (_isLocationSharing) _sendLocationToBackend();
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

  void _toggleSilentMode() {
    setState(() {
      _silentMode = !_silentMode;
    });
    _savePreferences();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_silentMode ? 'Silent mode enabled' : 'Silent mode disabled'),
      ),
    );
  }

  Future<void> _playAlarmSound() async {
    await _audioPlayer.setSource(AssetSource('assets/sounds/alarm.mp3'));
    await _audioPlayer.resume();
  }

  Future<void> _stopAlarmSound() async {
    await _audioPlayer.stop();
  }

  void _vibrateDevice() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 500, 1000, 500], repeat: 1);
    }
  }

  void _showDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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

  Future<void> _openEditContactsDialog({required bool isEmergency}) async {
    List<Map<String, String>> contacts =
        isEmergency ? _emergencyContacts : _personalContacts;

    TextEditingController nameController = TextEditingController();
    TextEditingController numberController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          void _addContact() {
            if (nameController.text.isEmpty || numberController.text.isEmpty) return;
            setStateDialog(() {
              contacts.add({
                'name': nameController.text,
                'number': numberController.text,
                if (isEmergency) 'icon': 'custom'
              });
            });
            nameController.clear();
            numberController.clear();
          }

          void _removeContact(int index) {
            setStateDialog(() {
              contacts.removeAt(index);
            });
          }

          return AlertDialog(
            title: Text(isEmergency
                ? 'Edit Emergency Contacts'
                : 'Edit Personal Contacts'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          title: Text('${contact['name']}'),
                          subtitle: Text('${contact['number']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeContact(index),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: numberController,
                      decoration: const InputDecoration(labelText: 'Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _addContact,
                      child: const Text('Add Contact'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (isEmergency) {
                    _emergencyContacts = List.from(contacts);
                  } else {
                    _personalContacts = List.from(contacts);
                  }
                  _savePreferences();
                  Navigator.pop(context);
                  setState(() {}); // Refresh UI
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildContactTile({
    required String name,
    required String number,
    required IconData icon,
    required VoidCallback onCall,
    required VoidCallback onSMS,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.call, size: 18, color: Colors.white),
                onPressed: onCall,
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.sms, size: 18, color: Colors.white),
                onPressed: onSMS,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightPane(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status and toggles
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentLocation,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleSilentMode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _silentMode ? Colors.grey[800] : AppColors.alertRed,
                      ),
                      icon: Icon(_silentMode ? Icons.volume_off : Icons.volume_up),
                      label: Text(_silentMode ? 'Silent On' : 'Silent Off'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _shareLocationWithContacts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isLocationSharing ? Colors.green[700] : Colors.blueGrey[700],
                      ),
                      icon: Icon(_isLocationSharing ? Icons.location_on : Icons.location_off),
                      label: Text(_isLocationSharing ? 'Sharing' : 'Share Location'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _startFakeCall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.alertRed,
                      ),
                      icon: const Icon(Icons.phone_in_talk_rounded),
                      label: const Text('Fake Call'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Contacts sections
        const SizedBox(height: 4),
        const Text(
          'Emergency Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._emergencyContacts.map(
                (c) => Row(
                  children: [
                    _buildContactTile(
                      name: c['name']!,
                      number: c['number']!,
                      icon: _getEmergencyIcon(c['icon'] ?? ''),
                      onCall: () => _callNumber(c['number']!),
                      onSMS: () => _sendSMS(c['number']!),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              // edit button
              GestureDetector(
                onTap: () => _openEditContactsDialog(isEmergency: true),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.06),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(height: 6),
                      Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Personal Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._personalContacts.map(
                (c) => Row(
                  children: [
                    _buildContactTile(
                      name: c['name']!,
                      number: c['number']!,
                      icon: Icons.person,
                      onCall: () => _callNumber(c['number']!),
                      onSMS: () => _sendSMS(c['number']!),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _openEditContactsDialog(isEmergency: false),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.06),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(height: 6),
                      Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyPanel(double maxSize) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        width: maxSize,
        height: maxSize,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: _isCountdownActive
              ? ScaleTransition(
                  scale: _countdownAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_countdownSeconds',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: AppColors.alertRed,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Calling emergency services',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: AppColors.alertRed),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.alertRed,
                            ),
                            onPressed: _cancelCountdown,
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.alertRed,
                            ),
                            onPressed: _callEmergencyNow,
                            child: const Text('Call Now'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'PRESS EMERGENCY BUTTON',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.alertRed,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current Location:',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentLocation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _startEmergencyCountdown,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alertRed,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(0),
                        fixedSize: const Size(140, 140),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.alertRed,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: _startFakeCall,
                      icon: const Icon(Icons.phone_in_talk_rounded),
                      label: const Text(
                        'Fake Call',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.alertRed,
      appBar: AppBar(
        backgroundColor: AppColors.alertRed,
        foregroundColor: Colors.white,
        title: const Text(
          'EMERGENCY SOS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_silentMode ? Icons.volume_off : Icons.volume_up),
            tooltip: _silentMode ? 'Silent Mode On' : 'Silent Mode Off',
            onPressed: _toggleSilentMode,
          ),
          IconButton(
            icon: Icon(
                _isLocationSharing ? Icons.location_on : Icons.location_off),
            tooltip:
                _isLocationSharing ? 'Stop Location Sharing' : 'Start Location Sharing',
            onPressed: _shareLocationWithContacts,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Edit Contacts',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => SizedBox(
                  height: 220,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.local_police),
                        title: const Text('Edit Emergency Contacts'),
                        onTap: () {
                          Navigator.pop(context);
                          _openEditContactsDialog(isEmergency: true);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Edit Personal Contacts'),
                        onTap: () {
                          Navigator.pop(context);
                          _openEditContactsDialog(isEmergency: false);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left emergency panel
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: _buildEmergencyPanel(
                          MediaQuery.of(context).size.width * 0.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right info / contacts
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        child: _buildRightPane(context),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildEmergencyPanel(
                        MediaQuery.of(context).size.width * 0.85,
                      ),
                      const SizedBox(height: 20),
                      _buildRightPane(context),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
