// screens/stations_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../widgets/custom_bottom_navigation.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  _StationsScreenState createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 2;
  String _selectedTransportType = 'all';
  String _selectedSafetyLevel = 'all';
  String _searchQuery = '';
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  late AnimationController _refreshController;

  // Mock data based on TransportStop domain class - will be replaced with backend data
  final List<Map<String, dynamic>> _stations = [
    {
      'id': '1',
      'stopId': 'PS001',
      'name': 'Park Station',
      'type': 'train',
      'location': {
        'latitude': -26.2041,
        'longitude': 28.0473,
        'address': 'Park Station, Johannesburg CBD',
      },
      'safetyLevel': 'yellow',
      'recentReportsCount': 3,
      'averageRating': 3.2,
      'operatingHours': ['05:00 - 22:00'],
      'distance': 0.5,
      'upvotes': 45,
      'downvotes': 23,
      'lastUpdated': DateTime.now().subtract(Duration(minutes: 15)),
    },
    {
      'id': '2',
      'stopId': 'GS001',
      'name': 'Gandhi Square',
      'type': 'taxi',
      'location': {
        'latitude': -26.2023,
        'longitude': 28.0436,
        'address': 'Gandhi Square, Johannesburg CBD',
      },
      'safetyLevel': 'green',
      'recentReportsCount': 0,
      'averageRating': 4.1,
      'operatingHours': ['04:00 - 23:00'],
      'distance': 0.8,
      'upvotes': 78,
      'downvotes': 12,
      'lastUpdated': DateTime.now().subtract(Duration(minutes: 8)),
    },
    {
      'id': '3',
      'stopId': 'BS001',
      'name': 'Bree Street Taxi Rank',
      'type': 'taxi',
      'location': {
        'latitude': -26.2023,
        'longitude': 28.0436,
        'address': 'Bree Street, Johannesburg CBD',
      },
      'safetyLevel': 'red',
      'recentReportsCount': 8,
      'averageRating': 2.1,
      'operatingHours': ['05:00 - 20:00'],
      'distance': 1.2,
      'upvotes': 23,
      'downvotes': 67,
      'lastUpdated': DateTime.now().subtract(Duration(minutes: 3)),
    },
    {
      'id': '4',
      'stopId': 'WU001',
      'name': 'Wits University',
      'type': 'bus',
      'location': {
        'latitude': -26.1951,
        'longitude': 28.0340,
        'address': 'University of the Witwatersrand, Braamfontein',
      },
      'safetyLevel': 'green',
      'recentReportsCount': 1,
      'averageRating': 4.5,
      'operatingHours': ['05:30 - 21:30'],
      'distance': 2.1,
      'upvotes': 156,
      'downvotes': 8,
      'lastUpdated': DateTime.now().subtract(Duration(minutes: 25)),
    },
    {
      'id': '5',
      'stopId': 'RB001',
      'name': 'Rea Vaya Braamfontein',
      'type': 'bus',
      'location': {
        'latitude': -26.1934,
        'longitude': 28.0357,
        'address': 'Jorissen Street, Braamfontein',
      },
      'safetyLevel': 'yellow',
      'recentReportsCount': 2,
      'averageRating': 3.8,
      'operatingHours': ['05:00 - 22:30'],
      'distance': 1.9,
      'upvotes': 92,
      'downvotes': 18,
      'lastUpdated': DateTime.now().subtract(Duration(minutes: 42)),
    },
    {
      'id': '6',
      'stopId': 'JS001',
      'name': 'Johannesburg Station',
      'type': 'train',
      'location': {
        'latitude': -26.1961,
        'longitude': 28.0386,
        'address': 'Johannesburg Station, City Centre',
      },
      'safetyLevel': 'yellow',
      'recentReportsCount': 4,
      'averageRating': 3.0,
      'operatingHours': ['04:30 - 23:00'],
      'distance': 0.7,
      'upvotes': 34,
      'downvotes': 29,
      'lastUpdated': DateTime.now().subtract(Duration(hours: 1, minutes: 12)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadStations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Stations'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshStations),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndSummary(),
          _buildFilterChips(),
          Expanded(child: _buildStationsList()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildSearchAndSummary() {
    final totalStations = _getFilteredStations().length;
    final safeStations = _getFilteredStations()
        .where((s) => s['safetyLevel'] == 'green')
        .length;
    final unsafeStations = _getFilteredStations()
        .where((s) => s['safetyLevel'] == 'red')
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
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stations...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          SizedBox(height: 16),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total',
                  totalStations.toString(),
                  Icons.train,
                  AppColors.primaryBlue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Safe',
                  safeStations.toString(),
                  Icons.check_circle,
                  AppColors.primarySafetyGreen,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Unsafe',
                  unsafeStations.toString(),
                  Icons.warning,
                  AppColors.alertRed,
                ),
              ),
            ],
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
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
            _buildFilterChip('All Types', 'all', _selectedTransportType),
            SizedBox(width: 8),
            _buildFilterChip('Taxi', 'taxi', _selectedTransportType),
            SizedBox(width: 8),
            _buildFilterChip('Bus', 'bus', _selectedTransportType),
            SizedBox(width: 8),
            _buildFilterChip('Train', 'train', _selectedTransportType),
            SizedBox(width: 16),
            _buildSafetyChip('All Safety', 'all', _selectedSafetyLevel),
            SizedBox(width: 8),
            _buildSafetyChip('Safe', 'green', _selectedSafetyLevel),
            SizedBox(width: 8),
            _buildSafetyChip('Caution', 'yellow', _selectedSafetyLevel),
            SizedBox(width: 8),
            _buildSafetyChip('Unsafe', 'red', _selectedSafetyLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue) {
    bool isSelected = selectedValue == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTransportType = value;
        });
      },
      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppColors.primaryBlue,
    );
  }

  Widget _buildSafetyChip(String label, String value, String selectedValue) {
    bool isSelected = selectedValue == value;
    Color chipColor = _getSafetyColor(value);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSafetyLevel = value;
        });
      },
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
    );
  }

  Widget _buildStationsList() {
    List<Map<String, dynamic>> filteredStations = _getFilteredStations();

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading stations...'),
          ],
        ),
      );
    }

    if (filteredStations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshStations,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredStations.length,
        itemBuilder: (context, index) {
          return _buildStationCard(filteredStations[index]);
        },
      ),
    );
  }

  Widget _buildStationCard(Map<String, dynamic> station) {
    Color safetyColor = _getSafetyColor(station['safetyLevel']);
    String safetyText = _getSafetyText(station['safetyLevel']);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showStationDetails(station),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Transport type icon
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTransportIcon(station['type']),
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),

                  SizedBox(width: 12),

                  // Station info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station['name'],
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: 2),
                        Text(
                          station['location']['address'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Safety indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: safetyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSafetyIcon(station['safetyLevel']),
                          size: 14,
                          color: safetyColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          safetyText.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: safetyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Station stats
              Row(
                children: [
                  _buildStatChip(
                    Icons.star,
                    station['averageRating'].toStringAsFixed(1),
                    AppColors.warningAmber,
                  ),
                  SizedBox(width: 8),
                  _buildStatChip(
                    Icons.location_on,
                    '${station['distance']} km',
                    AppColors.primaryBlue,
                  ),
                  SizedBox(width: 8),
                  if (station['recentReportsCount'] > 0)
                    _buildStatChip(
                      Icons.report,
                      '${station['recentReportsCount']} reports',
                      AppColors.alertRed,
                    ),
                  Spacer(),
                  Text(
                    'Updated ${_getTimeAgo(station['lastUpdated'])}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Operating hours
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Hours: ${station['operatingHours'][0]}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.train, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No stations found',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredStations() {
    return _stations.where((station) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          station['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          station['location']['address'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      bool matchesType =
          _selectedTransportType == 'all' ||
          station['type'] == _selectedTransportType;

      bool matchesSafety =
          _selectedSafetyLevel == 'all' ||
          station['safetyLevel'] == _selectedSafetyLevel;

      return matchesSearch && matchesType && matchesSafety;
    }).toList();
  }

  IconData _getTransportIcon(String type) {
    switch (type) {
      case 'taxi':
        return Icons.local_taxi;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      default:
        return Icons.directions;
    }
  }

  Color _getSafetyColor(String level) {
    switch (level) {
      case 'green':
        return AppColors.primarySafetyGreen;
      case 'yellow':
        return AppColors.warningAmber;
      case 'red':
        return AppColors.alertRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _getSafetyText(String level) {
    switch (level) {
      case 'green':
        return 'Safe';
      case 'yellow':
        return 'Caution';
      case 'red':
        return 'Unsafe';
      default:
        return 'Unknown';
    }
  }

  IconData _getSafetyIcon(String level) {
    switch (level) {
      case 'green':
        return Icons.check_circle;
      case 'yellow':
        return Icons.warning;
      case 'red':
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call - replace with actual backend call
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshStations() async {
    _refreshController.forward();

    // Simulate API refresh - replace with actual backend call
    await Future.delayed(Duration(seconds: 1));

    _refreshController.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stations updated'),
        backgroundColor: AppColors.primarySafetyGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Stations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transport Type'),
            DropdownButton<String>(
              value: _selectedTransportType,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Types')),
                DropdownMenuItem(value: 'taxi', child: Text('Taxi')),
                DropdownMenuItem(value: 'bus', child: Text('Bus')),
                DropdownMenuItem(value: 'train', child: Text('Train')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTransportType = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Safety Level'),
            DropdownButton<String>(
              value: _selectedSafetyLevel,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Levels')),
                DropdownMenuItem(value: 'green', child: Text('Safe')),
                DropdownMenuItem(value: 'yellow', child: Text('Caution')),
                DropdownMenuItem(value: 'red', child: Text('Unsafe')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSafetyLevel = value!;
                });
              },
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

  void _showStationDetails(Map<String, dynamic> station) {
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
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getTransportIcon(station['type']),
                            color: AppColors.primaryBlue,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station['name'],
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              Text(
                                'ID: ${station['stopId']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    _buildDetailSection('Location', [
                      _buildDetailRow(
                        'Address',
                        station['location']['address'],
                        Icons.location_on,
                      ),
                      _buildDetailRow(
                        'Distance',
                        '${station['distance']} km away',
                        Icons.directions,
                      ),
                      _buildDetailRow(
                        'Coordinates',
                        '${station['location']['latitude'].toStringAsFixed(4)}, ${station['location']['longitude'].toStringAsFixed(4)}',
                        Icons.gps_fixed,
                      ),
                    ]),

                    SizedBox(height: 16),

                    _buildDetailSection('Safety Information', [
                      _buildDetailRow(
                        'Safety Level',
                        _getSafetyText(station['safetyLevel']),
                        _getSafetyIcon(station['safetyLevel']),
                      ),
                      _buildDetailRow(
                        'Recent Reports',
                        '${station['recentReportsCount']} in last 7 days',
                        Icons.report,
                      ),
                      _buildDetailRow(
                        'Community Rating',
                        '${station['averageRating']}/5.0 stars',
                        Icons.star,
                      ),
                      _buildDetailRow(
                        'Community Votes',
                        '${station['upvotes']} 👍 ${station['downvotes']} 👎',
                        Icons.thumb_up,
                      ),
                    ]),

                    SizedBox(height: 16),

                    _buildDetailSection('Service Information', [
                      _buildDetailRow(
                        'Transport Type',
                        station['type'].toUpperCase(),
                        _getTransportIcon(station['type']),
                      ),
                      _buildDetailRow(
                        'Operating Hours',
                        station['operatingHours'][0],
                        Icons.access_time,
                      ),
                      _buildDetailRow(
                        'Last Updated',
                        _getTimeAgo(station['lastUpdated']),
                        Icons.update,
                      ),
                    ]),

                    SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _reportIssue(station),
                            icon: Icon(Icons.report_problem),
                            label: Text('Report Issue'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _planRoute(station),
                            icon: Icon(Icons.directions),
                            label: Text('Plan Route'),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: 12),
        ...children,
      ],
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

  void _reportIssue(Map<String, dynamic> station) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/safety-reporting',
      arguments: {'stationId': station['id'], 'stationName': station['name']},
    );
  }

  void _planRoute(Map<String, dynamic> station) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/route-planning',
      arguments: {'destination': station['name']},
    );
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
        // Already on stations
        break;
      case 3:
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }
}
