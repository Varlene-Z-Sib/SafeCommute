// screens/route_planning_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_bottom_navigation.dart';

class RoutePlanningScreen extends StatefulWidget {
  @override
  _RoutePlanningScreenState createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  int _currentIndex = 1;
  String _selectedRoutePreference = 'safest';
  List<String> _selectedTransportTypes = ['taxi', 'bus'];
  bool _showRouteResults = false;

  final List<Map<String, dynamic>> _routeOptions = [
    {
      'id': 1,
      'safetyRating': 4.5,
      'estimatedTime': '35 min',
      'cost': 'R18',
      'transportTypes': ['taxi', 'walking'],
      'safetyLevel': 'safe',
      'highlights': ['Well-lit route', 'Active security'],
      'warnings': [],
      'steps': [
        'Walk to Park Station (5 min)',
        'Take taxi to Gandhi Square (15 min)',
        'Walk to destination (15 min)',
      ],
    },
    {
      'id': 2,
      'safetyRating': 3.8,
      'estimatedTime': '28 min',
      'cost': 'R15',
      'transportTypes': ['bus', 'walking'],
      'safetyLevel': 'moderate',
      'highlights': ['Frequent service'],
      'warnings': ['Crowded during peak hours'],
      'steps': [
        'Walk to Bus Stop A (3 min)',
        'Take Bus 42 to City Center (20 min)',
        'Walk to destination (5 min)',
      ],
    },
    {
      'id': 3,
      'safetyRating': 3.2,
      'estimatedTime': '22 min',
      'cost': 'R12',
      'transportTypes': ['train', 'walking'],
      'safetyLevel': 'moderate',
      'highlights': ['Cheapest option'],
      'warnings': ['Limited evening service', 'Crowded platforms'],
      'steps': [
        'Walk to Metro Station (8 min)',
        'Take train to Central (10 min)',
        'Walk to destination (4 min)',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Planning'),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () => Navigator.pushNamed(context, '/live-navigation'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          _buildSearchSection(),

          // Filters Section
          _buildFiltersSection(),

          // Route Results or Empty State
          Expanded(
            child: _showRouteResults
                ? _buildRouteResults()
                : _buildEmptyState(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // From Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _fromController,
              decoration: InputDecoration(
                hintText: 'From location',
                prefixIcon: Icon(
                  Icons.my_location,
                  color: AppColors.primaryBlue,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.gps_fixed),
                  onPressed: _useCurrentLocation,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),

          SizedBox(height: 12),

          // Swap Button
          Center(
            child: GestureDetector(
              onTap: _swapLocations,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.swap_vert, color: Colors.white, size: 20),
              ),
            ),
          ),

          SizedBox(height: 12),

          // To Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _toController,
              decoration: InputDecoration(
                hintText: 'To location',
                prefixIcon: Icon(Icons.location_on, color: AppColors.alertRed),
                suffixIcon: IconButton(
                  icon: Icon(Icons.star_border),
                  onPressed: _showFavorites,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Search Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _searchRoutes,
              child: Text('Find Safe Routes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Preferences',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 12),

          // Route Preference Toggles
          Row(
            children: [
              Expanded(
                child: _buildPreferenceChip('Safest', 'safest', Icons.shield),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildPreferenceChip('Fastest', 'fastest', Icons.speed),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildPreferenceChip(
                  'Cheapest',
                  'cheapest',
                  Icons.attach_money,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Text(
            'Transport Types',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 12),

          // Transport Type Filters
          Wrap(
            spacing: 8,
            children: [
              _buildTransportChip('Taxi', 'taxi', Icons.local_taxi),
              _buildTransportChip('Bus', 'bus', Icons.directions_bus),
              _buildTransportChip('Train', 'train', Icons.train),
              _buildTransportChip('Walking', 'walking', Icons.directions_walk),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceChip(String label, String value, IconData icon) {
    bool isSelected = _selectedRoutePreference == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRoutePreference = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportChip(String label, String value, IconData icon) {
    bool isSelected = _selectedTransportTypes.contains(value);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTransportTypes.remove(value);
          } else {
            _selectedTransportTypes.add(value);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySafetyGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primarySafetyGreen
                : AppColors.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'Enter your destinations',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Find the safest routes for your journey',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteResults() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _routeOptions.length,
      itemBuilder: (context, index) {
        final route = _routeOptions[index];
        return _buildRouteCard(route);
      },
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    Color safetyColor = _getSafetyColor(route['safetyLevel']);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showRouteDetails(route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with safety rating and time/cost
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 40,
                        decoration: BoxDecoration(
                          color: safetyColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: i < route['safetyRating'].floor()
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                route['safetyRating'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: safetyColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            route['safetyLevel'].toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: safetyColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        route['estimatedTime'],
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        route['cost'],
                        style: TextStyle(
                          color: AppColors.primarySafetyGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Transport types
              Row(
                children: [
                  Text(
                    'Transport: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  ...route['transportTypes']
                      .map<Widget>(
                        (type) => Container(
                          margin: EdgeInsets.only(right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTransportIcon(type),
                                size: 16,
                                color: AppColors.primaryBlue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                type.toString().toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),

              SizedBox(height: 12),

              // Safety highlights and warnings
              if (route['highlights'].isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primarySafetyGreen,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        route['highlights'].join(', '),
                        style: TextStyle(
                          color: AppColors.primarySafetyGreen,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
              ],

              if (route['warnings'].isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppColors.warningAmber,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        route['warnings'].join(', '),
                        style: TextStyle(
                          color: AppColors.warningAmber,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRouteDetails(route),
                      child: Text('View Details'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _startNavigation(route),
                      child: Text('Start Navigation'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  IconData _getTransportIcon(String type) {
    switch (type.toLowerCase()) {
      case 'taxi':
        return Icons.local_taxi;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'walking':
        return Icons.directions_walk;
      default:
        return Icons.directions;
    }
  }

  void _useCurrentLocation() {
    setState(() {
      _fromController.text = 'Current Location';
    });
  }

  void _swapLocations() {
    final temp = _fromController.text;
    setState(() {
      _fromController.text = _toController.text;
      _toController.text = temp;
    });
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Favorite Locations',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.work),
                    title: Text('Work'),
                    subtitle: Text('Sandton City'),
                    onTap: () {
                      _toController.text = 'Sandton City';
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    subtitle: Text('Soweto'),
                    onTap: () {
                      _toController.text = 'Soweto';
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.school),
                    title: Text('University'),
                    subtitle: Text('Wits University'),
                    onTap: () {
                      _toController.text = 'Wits University';
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchRoutes() {
    if (_fromController.text.isNotEmpty && _toController.text.isNotEmpty) {
      setState(() {
        _showRouteResults = true;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter both locations')));
    }
  }

  void _showRouteDetails(Map<String, dynamic> route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  padding: EdgeInsets.all(16),
                  children: [
                    Text(
                      'Route Details',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 16),
                    ...route['steps']
                        .map<Widget>(
                          (step) => Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(step),
                          ),
                        )
                        .toList(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _saveRoute(route),
                            child: Text('Save Route'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _shareRoute(route),
                            child: Text('Share Route'),
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

  void _startNavigation(Map<String, dynamic> route) {
    Navigator.pushNamed(context, '/live-navigation');
  }

  void _saveRoute(Map<String, dynamic> route) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Route saved successfully')));
  }

  void _shareRoute(Map<String, dynamic> route) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Route shared successfully')));
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
        // Already on route planning
        break;
      case 2:
        Navigator.pushNamed(context, '/safety-reporting');
        break;
      case 3:
        Navigator.pushNamed(context, '/safety-alerts');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }
}
