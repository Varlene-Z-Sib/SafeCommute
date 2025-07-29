// widgets/emergency_type_selector.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class EmergencyTypeSelector extends StatelessWidget {
  final Function(String) onEmergencySelected;
  final VoidCallback onCancel;

  const EmergencyTypeSelector({
    Key? key,
    required this.onEmergencySelected,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: 40),
          Text(
            'Emergency Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'What best describes your emergency?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 40),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // First row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmergencyButton(
                        icon: Icons.favorite,
                        label: 'Sensitive',
                        color: Colors.red,
                        onTap: () => onEmergencySelected('sensitive'),
                      ),
                      _buildEmergencyButton(
                        icon: Icons.access_time,
                        label: 'Test',
                        color: Colors.green,
                        onTap: () => onEmergencySelected('test'),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Second row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmergencyButton(
                        icon: Icons.directions_car_filled,
                        label: 'Accident',
                        color: Colors.teal,
                        onTap: () => onEmergencySelected('accident'),
                      ),
                      _buildEmergencyButton(
                        icon: Icons.security,
                        label: 'Crime',
                        color: Colors.blue,
                        onTap: () => onEmergencySelected('crime'),
                      ),
                      _buildEmergencyButton(
                        icon: Icons.medical_services,
                        label: 'Medical',
                        color: Colors.red,
                        onTap: () => onEmergencySelected('medical'),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Third row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmergencyButton(
                        icon: Icons.local_fire_department,
                        label: 'Fire',
                        color: Colors.orange,
                        onTap: () => onEmergencySelected('fire'),
                      ),
                      _buildEmergencyButton(
                        icon: Icons.more_horiz,
                        label: 'Other',
                        color: Colors.red,
                        onTap: () => onEmergencySelected('other'),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Cancel button
                  GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 30),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 35),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
