// widgets/emergency_type_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class EmergencyTypeSelector extends StatefulWidget {
  final Function(String) onEmergencySelected;
  final VoidCallback onCancel;

  const EmergencyTypeSelector({
    Key? key,
    required this.onEmergencySelected,
    required this.onCancel,
  }) : super(key: key);

  @override
  _EmergencyTypeSelectorState createState() => _EmergencyTypeSelectorState();
}

class _EmergencyTypeSelectorState extends State<EmergencyTypeSelector>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String? _selectedType;
  bool _isSelecting = false;

  // SafeCommute-specific incident types
  final List<Map<String, dynamic>> _emergencyTypes = [
    {
      'id': 'theft',
      'label': 'Theft',
      'icon': Icons.money_off,
      'color': AppColors.alertRed,
      'description': 'Robbery, pickpocketing, stolen belongings',
      'severity': 'critical',
    },
    {
      'id': 'harassment',
      'label': 'Harassment',
      'icon': Icons.person_off,
      'color': AppColors.warningAmber,
      'description': 'Verbal abuse, intimidation, inappropriate behavior',
      'severity': 'high',
    },
    {
      'id': 'assault',
      'label': 'Violence',
      'icon': Icons.local_hospital,
      'color': AppColors.alertRed,
      'description': 'Physical assault or violence',
      'severity': 'critical',
    },
    {
      'id': 'suspicious_activity',
      'label': 'Suspicious',
      'icon': Icons.visibility,
      'color': AppColors.warningAmber,
      'description': 'Suspicious people or unusual activity',
      'severity': 'medium',
    },
    {
      'id': 'overcrowding',
      'label': 'Overcrowding',
      'icon': Icons.people,
      'color': AppColors.primaryBlue,
      'description': 'Dangerous overcrowding on transport',
      'severity': 'medium',
    },
    {
      'id': 'transport_delay',
      'label': 'Delays',
      'icon': Icons.schedule,
      'color': AppColors.warningAmber,
      'description': 'Major transport delays or cancellations',
      'severity': 'low',
    },
    {
      'id': 'accident',
      'label': 'Accident',
      'icon': Icons.car_crash,
      'color': AppColors.alertRed,
      'description': 'Traffic accident affecting transport',
      'severity': 'high',
    },
    {
      'id': 'safety_hazard',
      'label': 'Hazard',
      'icon': Icons.warning,
      'color': AppColors.warningAmber,
      'description': 'Broken lights, unsafe conditions, infrastructure issues',
      'severity': 'medium',
    },
    {
      'id': 'vandalism',
      'label': 'Vandalism',
      'icon': Icons.broken_image,
      'color': AppColors.primaryBlue,
      'description': 'Property damage, graffiti, broken facilities',
      'severity': 'low',
    },
    {
      'id': 'drug_activity',
      'label': 'Drug Activity',
      'icon': Icons.local_pharmacy,
      'color': AppColors.alertRed,
      'description': 'Drug dealing or substance abuse',
      'severity': 'high',
    },
    {
      'id': 'poor_lighting',
      'label': 'Poor Lighting',
      'icon': Icons.lightbulb_outline,
      'color': AppColors.primaryBlue,
      'description': 'Broken or inadequate lighting creating unsafe conditions',
      'severity': 'medium',
    },
    {
      'id': 'other',
      'label': 'Other',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
      'description': 'Other safety concerns not listed',
      'severity': 'medium',
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final isTablet = screenWidth > 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            height: screenHeight * 0.75,
            width: double.infinity,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildEmergencyGrid(isTablet)),
                _buildBottomSection(safeAreaBottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24),

          // SafeCommute logo/icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primarySafetyGreen, AppColors.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySafetyGreen.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(Icons.shield, color: Colors.white, size: 32),
          ),

          SizedBox(height: 20),

          Text(
            'Report Safety Issue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8),

          Text(
            'What type of safety issue would you like to report?',
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyGrid(bool isTablet) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            SizedBox(height: 20),

            // First row - 2 items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEmergencyButton(_emergencyTypes[0], 0), // Theft
                _buildEmergencyButton(_emergencyTypes[10], 10), // Poor Lighting
              ],
            ),
            SizedBox(height: 25),

            // Second row - 3 items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEmergencyButton(_emergencyTypes[6], 6), // Accident
                _buildEmergencyButton(_emergencyTypes[2], 2), // Violence
                _buildEmergencyButton(_emergencyTypes[9], 9), // Drug Activity
              ],
            ),
            SizedBox(height: 25),

            // Third row - 2 items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEmergencyButton(_emergencyTypes[7], 7), // Safety Hazard
                _buildEmergencyButton(_emergencyTypes[11], 11), // Other
              ],
            ),
            SizedBox(height: 25),

            // Fourth row - 3 compact items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCompactEmergencyButton(
                  _emergencyTypes[1],
                  1,
                ), // Harassment
                _buildCompactEmergencyButton(
                  _emergencyTypes[3],
                  3,
                ), // Suspicious Activity
                _buildCompactEmergencyButton(
                  _emergencyTypes[4],
                  4,
                ), // Overcrowding
              ],
            ),
            SizedBox(height: 20),

            // Fifth row - 2 compact items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCompactEmergencyButton(
                  _emergencyTypes[5],
                  5,
                ), // Transport Delay
                _buildCompactEmergencyButton(
                  _emergencyTypes[8],
                  8,
                ), // Vandalism
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(Map<String, dynamic> emergency, int index) {
    final isSelected = _selectedType == emergency['id'];
    final isSelecting = _isSelecting;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 30)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: GestureDetector(
            onTap: isSelecting
                ? null
                : () => _selectEmergencyTypeAndNavigate(emergency),
            onTapDown: (_) => _onTapDown(emergency['id']),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isSelected ? emergency['color'] : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? emergency['color'] : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    emergency['icon'],
                    color: isSelected ? Colors.white : emergency['color'],
                    size: 28,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 80,
                  child: Text(
                    emergency['label'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Compact version for secondary items
  Widget _buildCompactEmergencyButton(
    Map<String, dynamic> emergency,
    int index,
  ) {
    final isSelected = _selectedType == emergency['id'];
    final isSelecting = _isSelecting;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 30)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: GestureDetector(
            onTap: isSelecting
                ? null
                : () => _selectEmergencyTypeAndNavigate(emergency),
            onTapDown: (_) => _onTapDown(emergency['id']),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isSelected ? emergency['color'] : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? emergency['color'] : Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    emergency['icon'],
                    color: isSelected ? Colors.white : emergency['color'],
                    size: 22,
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  width: 70,
                  child: Text(
                    emergency['label'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(double safeAreaBottom) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + safeAreaBottom),
      child: Column(
        children: [
          // Cancel button only
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _buildActionButton(
              onTap: _handleCancel,
              icon: Icons.close,
              label: 'Cancel',
              backgroundColor: Colors.white.withOpacity(0.2),
              textColor: Colors.white,
              borderColor: Colors.white.withOpacity(0.3),
            ),
          ),

          SizedBox(height: 8),

          // Info text
          Text(
            'Tap any incident type to start reporting',
            style: TextStyle(color: Colors.white60, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1.5)
                : null,
            boxShadow: onTap != null
                ? [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: textColor,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 8),
              ] else ...[
                Icon(icon, color: textColor, size: 20),
                SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapDown(String emergencyId) {
    HapticFeedback.selectionClick();
  }

  void _selectEmergencyTypeAndNavigate(Map<String, dynamic> emergency) async {
    setState(() {
      _selectedType = emergency['id'];
      _isSelecting = true;
    });

    HapticFeedback.mediumImpact();

    // Brief delay for visual feedback
    await Future.delayed(Duration(milliseconds: 200));

    // Close the selector and navigate immediately
    await _slideController.reverse();
    widget.onEmergencySelected(_selectedType!);
  }

  void _selectEmergencyType(Map<String, dynamic> emergency) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedType = emergency['id'];
    });
  }

  void _handleCancel() async {
    HapticFeedback.lightImpact();
    await _slideController.reverse();
    widget.onCancel();
  }

  void _handleContinue() async {
    if (_selectedType == null) return;

    setState(() {
      _isSelecting = true;
    });

    HapticFeedback.mediumImpact();

    // Add a slight delay for better UX
    await Future.delayed(Duration(milliseconds: 300));

    await _slideController.reverse();
    widget.onEmergencySelected(_selectedType!);
  }

  String _getEmergencyLabel(String emergencyId) {
    final emergency = _emergencyTypes.firstWhere(
      (e) => e['id'] == emergencyId,
      orElse: () => {'label': emergencyId},
    );
    return emergency['label'];
  }
}
