// screens/safety_alerts_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/app_colors.dart';
import '../../widgets/custom_bottom_navigation.dart';

class SafetyAlertsScreen extends StatefulWidget {
  const SafetyAlertsScreen({super.key});

  @override
  _SafetyAlertsScreenState createState() => _SafetyAlertsScreenState();
}

class _SafetyAlertsScreenState extends State<SafetyAlertsScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 2;
  String _selectedFilter = 'all';
  String _selectedSeverity = 'all';
  bool _showActiveOnly = true;
  late AnimationController _refreshController;

  // Mock data based on RealTimeAlert domain class
  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'alertType': 'SAFETY_INCIDENT',
      'message':
          'Suspicious activity reported near Park Station. Increased police presence advised.',
      'severity': 'HIGH',
      'location': {
        'centerLat': -26.2041,
        'centerLng': 28.0473,
        'address': 'Park Station, Johannesburg CBD',
      },
      'createdAt': DateTime.now().subtract(Duration(minutes: 5)),
      'expiresAt': DateTime.now().add(Duration(hours: 2)),
      'isActive': true,
      'affectedStops': ['Park Station', 'Gandhi Square'],
      'reportCount': 3,
    },
    {
      'id': '2',
      'alertType': 'TRANSPORT_DELAY',
      'message':
          'Rea Vaya bus service experiencing 15-minute delays on Rapid Route 1.',
      'severity': 'MEDIUM',
      'location': {
        'centerLat': -26.1951,
        'centerLng': 28.0340,
        'address': 'Braamfontein',
      },
      'createdAt': DateTime.now().subtract(Duration(minutes: 12)),
      'expiresAt': DateTime.now().add(Duration(hours: 1)),
      'isActive': true,
      'affectedStops': ['Wits University', 'Library Gardens'],
      'reportCount': 1,
    },
    {
      'id': '3',
      'alertType': 'SAFETY_INCIDENT',
      'message':
          'Theft reported at Bree Street Taxi Rank. Commuters advised to be extra vigilant.',
      'severity': 'CRITICAL',
      'location': {
        'centerLat': -26.2023,
        'centerLng': 28.0436,
        'address': 'Bree Street Taxi Rank',
      },
      'createdAt': DateTime.now().subtract(Duration(minutes: 18)),
      'expiresAt': DateTime.now().add(Duration(hours: 3)),
      'isActive': true,
      'affectedStops': ['Bree Street Taxi Rank'],
      'reportCount': 5,
    },
    {
      'id': '4',
      'alertType': 'WEATHER',
      'message':
          'Heavy rain affecting visibility. Exercise caution at all outdoor transport stops.',
      'severity': 'MEDIUM',
      'location': {
        'centerLat': -26.2041,
        'centerLng': 28.0473,
        'address': 'Johannesburg CBD Area',
      },
      'createdAt': DateTime.now().subtract(Duration(hours: 1)),
      'expiresAt': DateTime.now().add(Duration(hours: 4)),
      'isActive': true,
      'affectedStops': ['Multiple stops in CBD'],
      'reportCount': 1,
    },
    {
      'id': '5',
      'alertType': 'MAINTENANCE',
      'message':
          'Scheduled maintenance at Johannesburg Station. Platform 3 temporarily closed.',
      'severity': 'LOW',
      'location': {
        'centerLat': -26.1961,
        'centerLng': 28.0386,
        'address': 'Johannesburg Station',
      },
      'createdAt': DateTime.now().subtract(Duration(hours: 2)),
      'expiresAt': DateTime.now().add(Duration(hours: 6)),
      'isActive': true,
      'affectedStops': ['Johannesburg Station'],
      'reportCount': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Alerts'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshAlerts),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          _buildFilterChips(),
          Expanded(child: _buildAlertsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/safety-reporting'),
        backgroundColor: AppColors.primaryBlue,
        child: Icon(Icons.add_alert),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final activeAlerts = _alerts.where((alert) => alert['isActive']).length;
    final criticalAlerts = _alerts
        .where((alert) => alert['severity'] == 'CRITICAL' && alert['isActive'])
        .length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Active Alerts',
              activeAlerts.toString(),
              Icons.warning,
              AppColors.warningAmber,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Critical',
              criticalAlerts.toString(),
              Icons.dangerous,
              AppColors.alertRed,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Your Area',
              '2',
              Icons.location_on,
              AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            SizedBox(width: 8),
            _buildFilterChip('Safety', 'SAFETY_INCIDENT'),
            SizedBox(width: 8),
            _buildFilterChip('Transport', 'TRANSPORT_DELAY'),
            SizedBox(width: 8),
            _buildFilterChip('Weather', 'WEATHER'),
            SizedBox(width: 8),
            _buildFilterChip('Maintenance', 'MAINTENANCE'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppColors.primaryBlue,
    );
  }

  Widget _buildAlertsList() {
    List<Map<String, dynamic>> filteredAlerts = _alerts.where((alert) {
      bool matchesFilter =
          _selectedFilter == 'all' || alert['alertType'] == _selectedFilter;
      bool matchesSeverity =
          _selectedSeverity == 'all' || alert['severity'] == _selectedSeverity;
      bool matchesActive = !_showActiveOnly || alert['isActive'];

      return matchesFilter && matchesSeverity && matchesActive;
    }).toList();

    // Sort by severity and creation time
    filteredAlerts.sort((a, b) {
      const severityOrder = {'CRITICAL': 4, 'HIGH': 3, 'MEDIUM': 2, 'LOW': 1};
      int severityCompare =
          (severityOrder[b['severity']] ?? 0) -
          (severityOrder[a['severity']] ?? 0);
      if (severityCompare != 0) return severityCompare;
      return b['createdAt'].compareTo(a['createdAt']);
    });

    if (filteredAlerts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredAlerts.length,
        itemBuilder: (context, index) {
          return _buildAlertCard(filteredAlerts[index]);
        },
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAlertDetails(alert),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getSeverityIcon(alert['severity']),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getAlertTypeDisplay(alert['alertType']),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getSeverityColor(alert['severity']),
                          ),
                        ),
                        Text(
                          alert['severity'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alert['isActive']
                          ? AppColors.primarySafetyGreen.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alert['isActive'] ? 'ACTIVE' : 'EXPIRED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: alert['isActive']
                            ? AppColors.primarySafetyGreen
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                alert['message'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      alert['location']['address'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        _getTimeAgo(alert['createdAt']),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (alert['reportCount'] > 1)
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${alert['reportCount']} reports',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No alerts found',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for safety updates',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _getSeverityIcon(String severity) {
    IconData icon;
    Color color = _getSeverityColor(severity);

    switch (severity) {
      case 'CRITICAL':
        icon = Icons.dangerous;
        break;
      case 'HIGH':
        icon = Icons.warning;
        break;
      case 'MEDIUM':
        icon = Icons.info;
        break;
      case 'LOW':
        icon = Icons.check_circle;
        break;
      default:
        icon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return AppColors.alertRed;
      case 'HIGH':
        return AppColors.warningAmber;
      case 'MEDIUM':
        return AppColors.primaryBlue;
      case 'LOW':
        return AppColors.primarySafetyGreen;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _getAlertTypeDisplay(String alertType) {
    switch (alertType) {
      case 'SAFETY_INCIDENT':
        return 'Safety Alert';
      case 'TRANSPORT_DELAY':
        return 'Transport Delay';
      case 'WEATHER':
        return 'Weather Alert';
      case 'MAINTENANCE':
        return 'Maintenance';
      default:
        return alertType;
    }
  }

  String _getTimeAgo(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        _getSeverityIcon(alert['severity']),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getAlertTypeDisplay(alert['alertType']),
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              Text(
                                '${alert['severity']} PRIORITY',
                                style: TextStyle(
                                  color: _getSeverityColor(alert['severity']),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      alert['message'],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 20),
                    _buildDetailRow(
                      'Location',
                      alert['location']['address'],
                      Icons.location_on,
                    ),
                    _buildDetailRow(
                      'Reported',
                      _getTimeAgo(alert['createdAt']),
                      Icons.access_time,
                    ),
                    _buildDetailRow(
                      'Expires',
                      _getTimeAgo(alert['expiresAt']),
                      Icons.schedule,
                    ),
                    if (alert['affectedStops'] is List &&
                        alert['affectedStops'].isNotEmpty)
                      _buildDetailRow(
                        'Affected Stops',
                        alert['affectedStops'].join(', '),
                        Icons.train,
                      ),
                    if (alert['reportCount'] > 1)
                      _buildDetailRow(
                        'Reports',
                        '${alert['reportCount']} people reported this',
                        Icons.people,
                      ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareAlert(alert),
                            icon: Icon(Icons.share),
                            label: Text('Share'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _reportAdditionalInfo(alert),
                            icon: Icon(Icons.add_comment),
                            label: Text('Add Info'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Alerts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alert Type'),
            DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Types')),
                DropdownMenuItem(
                  value: 'SAFETY_INCIDENT',
                  child: Text('Safety Incidents'),
                ),
                DropdownMenuItem(
                  value: 'TRANSPORT_DELAY',
                  child: Text('Transport Delays'),
                ),
                DropdownMenuItem(
                  value: 'WEATHER',
                  child: Text('Weather Alerts'),
                ),
                DropdownMenuItem(
                  value: 'MAINTENANCE',
                  child: Text('Maintenance'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Severity'),
            DropdownButton<String>(
              value: _selectedSeverity,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Severities')),
                DropdownMenuItem(value: 'CRITICAL', child: Text('Critical')),
                DropdownMenuItem(value: 'HIGH', child: Text('High')),
                DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                DropdownMenuItem(value: 'LOW', child: Text('Low')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSeverity = value!;
                });
              },
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Active alerts only'),
              value: _showActiveOnly,
              onChanged: (value) {
                setState(() {
                  _showActiveOnly = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshAlerts() async {
    _refreshController.forward();
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    _refreshController.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alerts updated'),
        backgroundColor: AppColors.primarySafetyGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareAlert(Map<String, dynamic> alert) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Alert shared successfully')));
  }

  void _reportAdditionalInfo(Map<String, dynamic> alert) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/safety-reporting');
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/route-planning');
        break;
      case 2:
        // Already on safety alerts
        break;
      case 3:
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }
}
