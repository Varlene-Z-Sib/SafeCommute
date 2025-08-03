import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../utils/app_colors.dart';

class RoutePlanningScreen extends StatefulWidget {
  @override
  _RoutePlanningScreenState createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  late GoogleMapController _mapController;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  LatLng _currentPosition = LatLng(-26.2041, 28.0473);
  LatLng? _fromLocation;
  LatLng? _toLocation;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  List<RouteOption> _routeOptions = [];
  RouteOption? _selectedRoute;
  bool _isLoadingRoutes = false;
  bool _showRouteResults = false;

  final String _baseUrl = "http://127.0.0.1:8000"; // Android emulator localhost

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    if (_mapController != null) {
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 14));
    }
  }

  Future<void> _searchRoutes() async {
    if (_fromLocation == null || _toLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both origin and destination')),
      );
      return;
    }

    setState(() {
      _isLoadingRoutes = true;
      _showRouteResults = false;
    });

    final uri = Uri.parse("$_baseUrl/routes");
final response = await http.post(
  uri,
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "origin": {"lat": _fromLocation!.latitude, "lng": _fromLocation!.longitude},
    "destination": {"lat": _toLocation!.latitude, "lng": _toLocation!.longitude},
    "preference": "safest", // or "fastest"
    "transport_types": ["taxi", "bus"], // optional
  }),
);
  

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _routeOptions = (data['routes'] as List).map((r) => RouteOption.fromJson(r)).toList();
        _selectedRoute = _routeOptions.isNotEmpty ? _routeOptions.first : null;
        _showRouteResults = true;
        _isLoadingRoutes = false;
      });
      if (_selectedRoute != null) _displayRouteOnMap(_selectedRoute!);
    } else {
      setState(() {
        _isLoadingRoutes = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch routes')),
      );
    }
  }

  void _displayRouteOnMap(RouteOption route) {
    final polylines = {
      Polyline(
        polylineId: PolylineId(route.id),
        points: route.routePoints,
        color: _getSafetyColor(route.safetyLevel),
        width: 5,
      )
    };
    setState(() => _polylines = polylines);
  }

  void _selectRoute(RouteOption route) {
    setState(() => _selectedRoute = route);
    _displayRouteOnMap(route);
  }

  Color _getSafetyColor(String level) {
    switch (level.toLowerCase()) {
      case 'safe':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'dangerous':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Route Planning')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              TextField(
                controller: _fromController,
                decoration: InputDecoration(labelText: 'From'),
                onTap: () => _pickLocation(true),
              ),
              TextField(
                controller: _toController,
                decoration: InputDecoration(labelText: 'To'),
                onTap: () => _pickLocation(false),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoadingRoutes ? null : _searchRoutes,
                child: _isLoadingRoutes ? CircularProgressIndicator() : Text('Find Safe Routes'),
              )
            ]),
          ),
          Expanded(
            child: Stack(children: [
              GoogleMap(
                onMapCreated: (c) => _mapController = c,
                initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 14),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
              ),
              if (_showRouteResults)
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _routeOptions
                          .map((route) => ListTile(
                                title: Text('${route.distance} • ${route.duration} • ${route.cost}'),
                                subtitle: Text('Safety: ${route.safetyLevel}'),
                                trailing: ElevatedButton(
                                  onPressed: () => _selectRoute(route),
                                  child: Text('Select'),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                )
            ]),
          ),
        ],
      ),
    );
  }

  void _pickLocation(bool isFrom) async {
    // You can replace this with a place picker or location picker UI
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: [
          ListTile(
            title: Text("Johannesburg CBD"),
            onTap: () {
              Navigator.pop(context);
              final loc = LatLng(-26.2041, 28.0473);
              setState(() {
                if (isFrom) {
                  _fromLocation = loc;
                  _fromController.text = "Johannesburg CBD";
                } else {
                  _toLocation = loc;
                  _toController.text = "Johannesburg CBD";
                }
                _updateMarkers();
              });
            },
          ),
          ListTile(
            title: Text("Sandton"),
            onTap: () {
              Navigator.pop(context);
              final loc = LatLng(-26.1076, 28.0567);
              setState(() {
                if (isFrom) {
                  _fromLocation = loc;
                  _fromController.text = "Sandton";
                } else {
                  _toLocation = loc;
                  _toController.text = "Sandton";
                }
                _updateMarkers();
              });
            },
          )
        ],
      ),
    );
  }

  void _updateMarkers() {
    final newMarkers = <Marker>{};
    if (_fromLocation != null) {
      newMarkers.add(Marker(
        markerId: MarkerId("from"),
        position: _fromLocation!,
        infoWindow: InfoWindow(title: "From"),
      ));
    }
    if (_toLocation != null) {
      newMarkers.add(Marker(
        markerId: MarkerId("to"),
        position: _toLocation!,
        infoWindow: InfoWindow(title: "To"),
      ));
    }
    setState(() => _markers = newMarkers);
  }
}

class RouteOption {
  final String id;
  final String duration;
  final String distance;
  final String cost;
  final String safetyLevel;
  final List<LatLng> routePoints;

  RouteOption({
    required this.id,
    required this.duration,
    required this.distance,
    required this.cost,
    required this.safetyLevel,
    required this.routePoints,
  });

  factory RouteOption.fromJson(Map<String, dynamic> json) {
    return RouteOption(
      id: json['id'],
      duration: json['duration'],
      distance: json['distance'],
      cost: json['cost'],
      safetyLevel: json['safety_level'],
      routePoints: (json['route_points'] as List)
          .map((pt) => LatLng(pt['lat'], pt['lng']))
          .toList(),
    );
  }
}
