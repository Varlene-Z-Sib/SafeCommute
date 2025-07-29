import 'package:flutter/material.dart';
import '/utils/app_colors.dart';

// widgets/safety_status_widget.dart
class SafetyStatusWidget extends StatelessWidget {
  final String safetyLevel;
  final String location;

  const SafetyStatusWidget({
    super.key,
    required this.safetyLevel,
    required this.location,
  });

  Color _getSafetyColor() {
    switch (safetyLevel.toLowerCase()) {
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

  IconData _getSafetyIcon() {
    switch (safetyLevel.toLowerCase()) {
      case 'safe':
        return Icons.shield;
      case 'moderate':
        return Icons.warning;
      case 'high':
        return Icons.dangerous;
      default:
        return Icons.shield;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getSafetyColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getSafetyIcon(), color: _getSafetyColor(), size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety Status',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 4),
                  Text(
                    safetyLevel.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _getSafetyColor(),
                    ),
                  ),
                  Text(
                    location,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
