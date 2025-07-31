// screens/enhanced_route_planning_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../widgets/custom_bottom_navigation.dart';

class RoutePlanningScreen extends StatefulWidget {
  @override
  _RoutePlanningScreenState createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  late GoogleMapController _mapController;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // Map and Location variables
  LatLng _currentPosition = LatLng(-26.2041, 28.0473); // Johannesburg default
  LatLng? _fromLocation;
  LatLng? _toLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Route data - This will come from your backend API
  List<RouteOption> _routeOptions = [];
  RouteOption? _selectedRoute;
  bool _isLoadingRoutes = false;
  bool _showRouteResults = false;

  // Filters
  String _selectedRoutePreference = 'safest';
  List<String> _selectedTransportTypes = ['taxi', 'bus'];

  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Route Planning'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          _buildSearchSection(),

          // Map and Results
          Expanded(
            child: _showRouteResults ? _buildMapWithResults() : _buildMapOnly(),
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
              onTap: () => _showLocationPicker(true),
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
              onTap: () => _showLocationPicker(false),
            ),
          ),

          SizedBox(height: 16),

          // Transport Type Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTransportChip('Taxi', 'taxi', Icons.local_taxi),
                SizedBox(width: 8),
                _buildTransportChip('Bus', 'bus', Icons.directions_bus),
                SizedBox(width: 8),
                _buildTransportChip('Train', 'train', Icons.train),
                SizedBox(width: 8),
                _buildTransportChip(
                  'Walking',
                  'walking',
                  Icons.directions_walk,
                ),
                SizedBox(width: 8),
                _buildTransportChip('Uber', 'uber', Icons.car_rental),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Search Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingRoutes ? null : _searchRoutes,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoadingRoutes
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Finding Safe Routes...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 8),
                        Text('Find Safe Routes'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapOnly() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _currentPosition,
        zoom: 14.0,
      ),
      markers: _markers,
      polylines: _polylines,
      onTap: _onMapTap,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildMapWithResults() {
    return Column(
      children: [
        // Map View
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 14.0,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

              // Route info overlay
              if (_selectedRoute != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildRouteInfoCard(_selectedRoute!),
                ),
            ],
          ),
        ),

        // Route Options List
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
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

                // Route options
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _routeOptions.length,
                    itemBuilder: (context, index) {
                      final route = _routeOptions[index];
                      return _buildRouteOptionCard(route, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfoCard(RouteOption route) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.duration,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${route.distance} • ${route.cost}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSafetyColor(route.safetyLevel),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getSafetyIcon(route.safetyLevel),
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        route.safetyLevel.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // ETA and Safety Rating
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'ETA: ${route.eta}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(width: 16),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      size: 16,
                      color: i < route.safetyRating.floor()
                          ? Colors.amber
                          : Colors.grey[300],
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  route.safetyRating.toString(),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteOptionCard(RouteOption route, int index) {
    bool isSelected = _selectedRoute?.id == route.id;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => _selectRoute(route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.duration,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: isSelected ? AppColors.primaryBlue : null,
                            ),
                      ),
                      Text(
                        '${route.distance} • ${route.cost}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            size: 16,
                            color: i < route.safetyRating.floor()
                                ? Colors.amber
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getSafetyColor(route.safetyLevel),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          route.safetyLevel.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Transport types
              Row(
                children: route.transportTypes
                    .take(3)
                    .map(
                      (type) => Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Icon(
                          _getTransportIcon(type),
                          size: 20,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                    .toList(),
              ),

              SizedBox(height: 8),

              // Recent reports
              if (route.recentReports.isNotEmpty) ...[
                Text(
                  'Recent Reports:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                ...route.recentReports
                    .take(2)
                    .map(
                      (report) => Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(
                              _getReportIcon(report.type),
                              size: 12,
                              color: _getReportColor(report.severity),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${report.description} (${report.timeAgo})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getReportColor(report.severity),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],

              SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRouteDetails(route),
                      child: Text('Details'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _startNavigation(route),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primarySafetyGreen,
                      ),
                      child: Text('Navigate'),
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

  // Helper Widgets
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

  // Helper Methods
  Color _getSafetyColor(String level) {
    switch (level.toLowerCase()) {
      case 'safe':
        return AppColors.primarySafetyGreen;
      case 'moderate':
        return AppColors.warningAmber;
      case 'high':
      case 'dangerous':
        return AppColors.alertRed;
      default:
        return AppColors.primarySafetyGreen;
    }
  }

  IconData _getSafetyIcon(String level) {
    switch (level.toLowerCase()) {
      case 'safe':
        return Icons.shield;
      case 'moderate':
        return Icons.warning;
      case 'high':
      case 'dangerous':
        return Icons.dangerous;
      default:
        return Icons.shield;
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
      case 'uber':
        return Icons.car_rental;
      default:
        return Icons.directions;
    }
  }

  IconData _getReportIcon(String type) {
    switch (type.toLowerCase()) {
      case 'theft':
        return Icons.warning;
      case 'harassment':
        return Icons.report_problem;
      case 'accident':
        return Icons.car_crash;
      case 'delay':
        return Icons.access_time;
      case 'overcrowding':
        return Icons.people;
      default:
        return Icons.info;
    }
  }

  Color _getReportColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return AppColors.primarySafetyGreen;
      case 'medium':
        return AppColors.warningAmber;
      case 'high':
        return AppColors.alertRed;
      default:
        return Colors.grey;
    }
  }

  // Core Methods
  void _getCurrentLocation() {
    // TODO: Implement actual GPS location getting
    // For now, just center on Johannesburg
    setState(() {
      _currentPosition = LatLng(-26.2041, 28.0473);
    });

    if (_mapController != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }

  void _useCurrentLocation() {
    setState(() {
      _fromController.text = 'Current Location';
      _fromLocation = _currentPosition;
      _updateMarkers();
    });
  }

  void _swapLocations() {
    final tempText = _fromController.text;
    final tempLocation = _fromLocation;

    setState(() {
      _fromController.text = _toController.text;
      _toController.text = tempText;
      _fromLocation = _toLocation;
      _toLocation = tempLocation;
      _updateMarkers();
    });
  }

  void _showLocationPicker(bool isFromLocation) {
    // TODO: Implement location picker or search
    // For now, show some common locations
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
                isFromLocation ? 'Select From Location' : 'Select To Location',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.business),
                    title: Text('Johannesburg CBD'),
                    onTap: () => _selectLocation(
                      'Johannesburg CBD',
                      LatLng(-26.2041, 28.0473),
                      isFromLocation,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_city),
                    title: Text('Sandton'),
                    onTap: () => _selectLocation(
                      'Sandton',
                      LatLng(-26.1076, 28.0567),
                      isFromLocation,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.train),
                    title: Text('Park Station'),
                    onTap: () => _selectLocation(
                      'Park Station',
                      LatLng(-26.2085, 28.0416),
                      isFromLocation,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Soweto'),
                    onTap: () => _selectLocation(
                      'Soweto',
                      LatLng(-26.2678, 27.8546),
                      isFromLocation,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectLocation(String name, LatLng location, bool isFromLocation) {
    setState(() {
      if (isFromLocation) {
        _fromController.text = name;
        _fromLocation = location;
      } else {
        _toController.text = name;
        _toLocation = location;
      }
      _updateMarkers();
    });
    Navigator.pop(context);
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 250,
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
                      _toLocation = LatLng(-26.1076, 28.0567);
                      _updateMarkers();
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    subtitle: Text('Soweto'),
                    onTap: () {
                      _toController.text = 'Soweto';
                      _toLocation = LatLng(-26.2678, 27.8546);
                      _updateMarkers();
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

  void _updateMarkers() {
    Set<Marker> markers = {};

    if (_fromLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('from'),
          position: _fromLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'From'),
        ),
      );
    }

    if (_toLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('to'),
          position: _toLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'To'),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _searchRoutes() {
    if (_fromLocation == null || _toLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select both locations')));
      return;
    }

    setState(() {
      _isLoadingRoutes = true;
    });

    // TODO: Replace this with actual API call to your backend
    // Your backend will call Google Maps API and return enhanced route data
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _routeOptions = _getMockRoutes(); // This will be replaced with API call
        _selectedRoute = _routeOptions.isNotEmpty ? _routeOptions.first : null;
        _showRouteResults = true;
        _isLoadingRoutes = false;
      });

      if (_selectedRoute != null) {
        _displayRouteOnMap(_selectedRoute!);
      }
    });
  }

  void _selectRoute(RouteOption route) {
    setState(() {
      _selectedRoute = route;
    });
    _displayRouteOnMap(route);
  }

  void _displayRouteOnMap(RouteOption route) {
    // Create polyline for the route
    Set<Polyline> polylines = {
      Polyline(
        polylineId: PolylineId('route_${route.id}'),
        points: route.routePoints,
        color: _getSafetyColor(route.safetyLevel),
        width: 5,
        patterns: route.safetyLevel.toLowerCase() == 'high'
            ? [PatternItem.dash(20), PatternItem.gap(10)]
            : [],
      ),
    };

    setState(() {
      _polylines = polylines;
    });
  }

  void _onMapTap(LatLng position) {
    // Handle map tap if needed
  }

  void _showRouteDetails(RouteOption route) {
    // Show detailed route information
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RouteDetailsScreen(route: route)),
    );
  }

  void _startNavigation(RouteOption route) {
    Navigator.pushNamed(context, '/live-navigation', arguments: route);
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
        Navigator.pushNamed(context, '/safety-alerts');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }

  // Mock data - Replace this with actual API call to your backend
  List<RouteOption> _getMockRoutes() {
    return [
      RouteOption(
        id: 'route_1',
        duration: '35 min',
        distance: '12.5 km',
        cost: 'R18',
        eta: '2:45 PM',
        transportTypes: ['taxi', 'walking'],
        safetyLevel: 'safe',
        safetyRating: 4.2,
        routePoints: [
          _fromLocation!,
          LatLng(-26.1985, 28.0345),
          LatLng(-26.1876, 28.0289),
          _toLocation!,
        ],
        recentReports: [
          SafetyReportSummary(
            type: 'delay',
            description: 'Minor traffic delay',
            timeAgo: '10 min ago',
            severity: 'low',
          ),
        ],
      ),
      RouteOption(
        id: 'route_2',
        duration: '42 min',
        distance: '14.2 km',
        cost: 'R15',
        eta: '2:52 PM',
        transportTypes: ['bus', 'walking'],
        safetyLevel: 'moderate',
        safetyRating: 3.8,
        routePoints: [
          _fromLocation!,
          LatLng(-26.1945, 28.0412),
          LatLng(-26.1823, 28.0356),
          _toLocation!,
        ],
        recentReports: [
          SafetyReportSummary(
            type: 'overcrowding',
            description: 'Bus overcrowding reported',
            timeAgo: '25 min ago',
            severity: 'medium',
          ),
        ],
      ),
    ];
  }
}

// Simple data classes for the frontend
class RouteOption {
  final String id;
  final String duration;
  final String distance;
  final String cost;
  final String eta;
  final List<String> transportTypes;
  final String safetyLevel;
  final double safetyRating;
  final List<LatLng> routePoints;
  final List<SafetyReportSummary> recentReports;

  RouteOption({
    required this.id,
    required this.duration,
    required this.distance,
    required this.cost,
    required this.eta,
    required this.transportTypes,
    required this.safetyLevel,
    required this.safetyRating,
    required this.routePoints,
    this.recentReports = const [],
  });

  // Convert from JSON when receiving from your backend
  factory RouteOption.fromJson(Map<String, dynamic> json) {
    return RouteOption(
      id: json['id'],
      duration: json['duration'],
      distance: json['distance'],
      cost: json['cost'],
      eta: json['eta'],
      transportTypes: List<String>.from(json['transport_types']),
      safetyLevel: json['safety_level'],
      safetyRating: json['safety_rating'].toDouble(),
      routePoints: (json['route_points'] as List)
          .map((point) => LatLng(point['lat'], point['lng']))
          .toList(),
      recentReports: (json['recent_reports'] as List)
          .map((report) => SafetyReportSummary.fromJson(report))
          .toList(),
    );
  }
}

class SafetyReportSummary {
  final String type;
  final String description;
  final String timeAgo;
  final String severity;

  SafetyReportSummary({
    required this.type,
    required this.description,
    required this.timeAgo,
    required this.severity,
  });

  factory SafetyReportSummary.fromJson(Map<String, dynamic> json) {
    return SafetyReportSummary(
      type: json['type'],
      description: json['description'],
      timeAgo: json['time_ago'],
      severity: json['severity'],
    );
  }
}

// Placeholder for Route Details Screen
class RouteDetailsScreen extends StatelessWidget {
  final RouteOption route;

  const RouteDetailsScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route Details')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration: ${route.duration}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text('Distance: ${route.distance}'),
            Text('Cost: ${route.cost}'),
            Text('ETA: ${route.eta}'),
            Text('Safety Rating: ${route.safetyRating}/5.0'),
            SizedBox(height: 16),
            Text(
              'Transport Types:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(route.transportTypes.join(', ')),
            SizedBox(height: 16),
            if (route.recentReports.isNotEmpty) ...[
              Text(
                'Recent Reports:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ...route.recentReports.map(
                (report) => ListTile(
                  title: Text(report.description),
                  subtitle: Text('${report.type} - ${report.timeAgo}'),
                  leading: Icon(
                    Icons.warning,
                    color: report.severity == 'high'
                        ? Colors.red
                        : report.severity == 'medium'
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              ),
            ],
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/live-navigation',
                    arguments: route,
                  );
                },
                child: Text('Start Navigation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
