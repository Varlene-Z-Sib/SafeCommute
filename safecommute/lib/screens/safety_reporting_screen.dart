// screens/safety_reporting_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../utils/app_colors.dart';

class SafetyReportingScreen extends StatefulWidget {
  final String? preSelectedIncidentType;

  const SafetyReportingScreen({super.key, this.preSelectedIncidentType});

  @override
  _SafetyReportingScreenState createState() => _SafetyReportingScreenState();
}

class _SafetyReportingScreenState extends State<SafetyReportingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _submitAnimationController;

  // Form controllers
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  // Form state based on SafetyReport domain class
  String _selectedIncidentType = '';
  String _selectedSeverity = 'medium';
  DateTime _incidentTime = DateTime.now();
  String _currentLocation = 'Johannesburg CBD, South Africa';
  bool _isAnonymous = false;
  bool _shareLocation = true;
  bool _isSubmitting = false;
  File? _selectedImage;

  // Incident types based on SafetyReport domain class
  final List<Map<String, dynamic>> _incidentTypes = [
    {
      'id': 'theft',
      'label': 'Theft',
      'icon': Icons.money_off,
      'description': 'Robbery, pickpocketing, or theft of belongings',
      'color': AppColors.alertRed,
    },
    {
      'id': 'harassment',
      'label': 'Harassment',
      'icon': Icons.person_off,
      'description': 'Verbal abuse, inappropriate behavior, or intimidation',
      'color': AppColors.warningAmber,
    },
    {
      'id': 'assault',
      'label': 'Assault',
      'icon': Icons.local_hospital,
      'description': 'Physical violence or assault',
      'color': AppColors.alertRed,
    },
    {
      'id': 'vandalism',
      'label': 'Vandalism',
      'icon': Icons.broken_image,
      'description': 'Property damage or vandalism',
      'color': AppColors.warningAmber,
    },
    {
      'id': 'suspicious_activity',
      'label': 'Suspicious Activity',
      'icon': Icons.visibility,
      'description': 'Unusual or concerning behavior',
      'color': AppColors.primaryBlue,
    },
    {
      'id': 'safety_hazard',
      'label': 'Safety Hazard',
      'icon': Icons.warning,
      'description':
          'Infrastructure issues, broken lighting, unsafe conditions',
      'color': AppColors.warningAmber,
    },
    {
      'id': 'other',
      'label': 'Other',
      'icon': Icons.more_horiz,
      'description': 'Other safety concerns not listed above',
      'color': AppColors.primaryBlue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _submitAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _locationController.text = _currentLocation;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _submitAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Safety Incident'),
        actions: [
          TextButton(
            onPressed: _selectedIncidentType.isNotEmpty ? _submitReport : null,
            child: Text(
              'SUBMIT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _selectedIncidentType.isNotEmpty
                    ? AppColors.primaryBlue
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmergencyBanner(),
              SizedBox(height: 24),
              _buildIncidentTypeSelection(),
              SizedBox(height: 24),
              _buildSeveritySelection(),
              SizedBox(height: 24),
              _buildLocationSection(),
              SizedBox(height: 24),
              _buildTimeSelection(),
              SizedBox(height: 24),
              _buildDescriptionSection(),
              SizedBox(height: 24),
              _buildImageSection(),
              SizedBox(height: 24),
              _buildPrivacyOptions(),
              SizedBox(height: 32),
              _buildSubmitButton(),
              SizedBox(height: 16),
              _buildSafetyTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.alertRed, AppColors.alertRed.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.emergency, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In immediate danger?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Call emergency services: 10111',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/emergency-sos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.alertRed,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('SOS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What happened?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 8),
        Text(
          'Select the type of incident you want to report',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _incidentTypes.length,
          itemBuilder: (context, index) {
            final incident = _incidentTypes[index];
            return _buildIncidentTypeCard(incident);
          },
        ),
      ],
    );
  }

  Widget _buildIncidentTypeCard(Map<String, dynamic> incident) {
    bool isSelected = _selectedIncidentType == incident['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIncidentType = incident['id'];
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? incident['color'].withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? incident['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: incident['color'].withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              incident['icon'],
              size: 32,
              color: isSelected ? incident['color'] : Colors.grey[600],
            ),
            SizedBox(height: 8),
            Text(
              incident['label'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? incident['color'] : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              incident['description'],
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeveritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How serious was this incident?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSeverityOption(
                'low',
                'Minor',
                'Non-threatening situation',
                AppColors.primarySafetyGreen,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildSeverityOption(
                'medium',
                'Moderate',
                'Concerning situation',
                AppColors.warningAmber,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildSeverityOption(
                'high',
                'Serious',
                'Dangerous situation',
                AppColors.alertRed,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildSeverityOption(
                'critical',
                'Critical',
                'Immediate danger',
                AppColors.alertRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeverityOption(
    String value,
    String label,
    String description,
    Color color,
  ) {
    bool isSelected = _selectedSeverity == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSeverity = value;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.circle, size: 12, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isSelected ? color : Colors.grey[800],
              ),
            ),
            Text(
              description,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where did this happen?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Enter location or transport stop',
              prefixIcon: Icon(Icons.location_on, color: AppColors.primaryBlue),
              suffixIcon: IconButton(
                icon: Icon(Icons.my_location),
                onPressed: _useCurrentLocation,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the incident location';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.share_location,
              size: 16,
              color: _shareLocation
                  ? AppColors.primarySafetyGreen
                  : Colors.grey,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _shareLocation
                    ? 'Precise location will be shared with authorities'
                    : 'Only general area will be shared',
                style: TextStyle(
                  fontSize: 12,
                  color: _shareLocation
                      ? AppColors.primarySafetyGreen
                      : Colors.grey[600],
                ),
              ),
            ),
            Switch(
              value: _shareLocation,
              onChanged: (value) {
                setState(() {
                  _shareLocation = value;
                });
              },
              activeColor: AppColors.primarySafetyGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When did this happen?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListTile(
            leading: Icon(Icons.access_time, color: AppColors.primaryBlue),
            title: Text(_formatDateTime(_incidentTime)),
            subtitle: Text('Tap to change time'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: _selectDateTime,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 8),
        Text(
          'Provide additional details to help others stay safe',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Describe what happened, who was involved, etc.',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photo (Optional)',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 8),
        Text(
          'Photos help authorities understand the situation better',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        if (_selectedImage != null) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _removeImage,
                  icon: Icon(Icons.delete, color: AppColors.alertRed),
                  label: Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.alertRed,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Change'),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: InkWell(
              onTap: _selectImage,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey[600]),
                  SizedBox(height: 8),
                  Text(
                    'Tap to add photo',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacyOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Options',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Report anonymously'),
                subtitle: Text('Your identity will not be shared'),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                  });
                },
                activeColor: AppColors.primarySafetyGreen,
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.info_outline, color: AppColors.primaryBlue),
                title: Text('How we use your report'),
                subtitle: Text('Learn about data handling and privacy'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: _showPrivacyInfo,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedIncidentType.isNotEmpty && !_isSubmitting
            ? _submitReport
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Submit Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSafetyTips() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySafetyGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primarySafetyGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.primarySafetyGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Safety Tips',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primarySafetyGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Trust your instincts - if something feels wrong, it probably is\n'
            '• Stay in well-lit, populated areas when possible\n'
            '• Keep emergency contacts easily accessible\n'
            '• Report incidents promptly to help keep others safe',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 5) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _incidentTime,
      firstDate: DateTime.now().subtract(Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_incidentTime),
      );

      if (time != null) {
        setState(() {
          _incidentTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _useCurrentLocation() {
    setState(() {
      _locationController.text = _currentLocation;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Using current location'),
        backgroundColor: AppColors.primarySafetyGreen,
      ),
    );
  }

  void _selectImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 150,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _chooseFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _takePhoto() {
    // Simulate taking a photo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Camera functionality not implemented in demo')),
    );
  }

  void _chooseFromGallery() {
    // Simulate choosing from gallery
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gallery functionality not implemented in demo')),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy & Data Handling'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How we handle your report:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Reports are shared with relevant authorities'),
              Text('• Location data helps improve safety for everyone'),
              Text('• Anonymous reports protect your identity'),
              Text('• Photos are encrypted and stored securely'),
              SizedBox(height: 16),
              Text(
                'Your safety data helps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Other commuters make informed decisions'),
              Text('• Authorities allocate resources effectively'),
              Text('• Improve overall public transport safety'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _submitAnimationController.forward();

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primarySafetyGreen),
            SizedBox(width: 8),
            Text('Report Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thank you for helping keep our community safe.'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySafetyGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report ID: #SR${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text('Status: Under Review', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/safety-alerts');
            },
            child: Text('View Alerts'),
          ),
        ],
      ),
    );
  }
}
