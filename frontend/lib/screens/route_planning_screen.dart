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

  List<Map<String, dynamic>> _stations = [];
  bool _loadingStations = true;
  String? _stationLoadError;

  // true means next tap sets "from", false sets "to"
  bool _settingFrom = true;

  final String _baseUrl = "http://127.0.0.1:8000"; // adjust to 10.0.2.2:8000 on Android emulator if needed
  final String _googleApiKey = "AIzaSyBU_hJukxYCZXxU5BTIzh651c4gYcKH9Uk"; // replace with your Geocoding-enabled key

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadStations();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
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

  Future<void> _loadStations() async {
    setState(() {
      _loadingStations = true;
      _stationLoadError = null;
    });
    try {
      final uri = Uri.parse("$_baseUrl/stations");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body);
        _stations = raw.map<Map<String, dynamic>>((station) {
          return {
            'id': station['id'],
            'name': station['name'],
            'lat': station['lat'],
            'lng': station['lng'],
            'safety_level': (station['safety_level'] ?? 'unknown').toString().toLowerCase(),
          };
        }).toList();
        _refreshMarkers();
      } else {
        setState(() {
          _stationLoadError = 'Failed to load stations (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _stationLoadError = e.toString();
      });
    } finally {
      setState(() {
        _loadingStations = false;
      });
    }
  }

  void _refreshMarkers() {
    final markers = <Marker>{};

    // station markers
    for (var station in _stations) {
      final safety = station['safety_level'] ?? 'unknown';
      markers.add(
        Marker(
          markerId: MarkerId('station_${station['id']}'),
          position: LatLng(station['lat'], station['lng']),
          icon: BitmapDescriptor.defaultMarkerWithHue(_hueForSafety(safety)),
          infoWindow: InfoWindow(
            title: station['name'],
            snippet: 'Safety: ${safety.toUpperCase()}',
            onTap: () => _onStationTapped(station),
          ),
          onTap: () => _onStationTapped(station),
        ),
      );
    }

    // origin / destination markers
    if (_fromLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId("from"),
        position: _fromLocation!,
        infoWindow: const InfoWindow(title: "From"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }
    if (_toLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId("to"),
        position: _toLocation!,
        infoWindow: const InfoWindow(title: "To"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    setState(() {
      _markers = markers;
    });
  }

  double _hueForSafety(String level) {
    switch (level.toLowerCase()) {
      case 'green':
        return BitmapDescriptor.hueGreen;
      case 'yellow':
        return BitmapDescriptor.hueYellow;
      case 'orange':
        return BitmapDescriptor.hueOrange;
      case 'red':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }

  void _onStationTapped(Map<String, dynamic> station) {
    final latLng = LatLng(station['lat'], station['lng']);
    setState(() {
      if (_settingFrom) {
        _fromLocation = latLng;
        _fromController.text = station['name'];
      } else {
        _toLocation = latLng;
        _toController.text = station['name'];
      }
      _refreshMarkers();
    });
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
  }

  Future<void> _geocodeAndSet(String input, bool isFrom) async {
    if (input.trim().isEmpty) return;
    final encoded = Uri.encodeComponent(input);
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?address=$encoded&key=$_googleApiKey");
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final loc = data['results'][0]['geometry']['location'];
          final latLng = LatLng(loc['lat'], loc['lng']);
          setState(() {
            if (isFrom) {
              _fromLocation = latLng;
              _fromController.text = input;
            } else {
              _toLocation = latLng;
              _toController.text = input;
            }
            _refreshMarkers();
          });
          _mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Geocoding failed: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geocoding error: $e')),
      );
    }
  }

  Future<void> _searchRoutes() async {
    if (_fromLocation == null || _toLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both origin and destination')),
      );
      return;
    }

    setState(() {
      _isLoadingRoutes = true;
      _showRouteResults = false;
    });

    final uri = Uri.parse("$_baseUrl/routes");
    final body = {
      "origin": {"lat": _fromLocation!.latitude, "lng": _fromLocation!.longitude},
      "destination": {"lat": _toLocation!.latitude, "lng": _toLocation!.longitude},
      "preference": "safest",
      "transport_types": ["taxi", "bus"],
    };

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _routeOptions = data.map((r) => RouteOption.fromJson(r)).toList();
          _selectedRoute = _routeOptions.isNotEmpty ? _routeOptions.first : null;
          _showRouteResults = true;
          _isLoadingRoutes = false;
        });
        if (_selectedRoute != null) _displayRouteOnMap(_selectedRoute!);
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingRoutes = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch routes: $e')),
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
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Route Planning'),
        actions: [
          IconButton(
            icon: Icon(_settingFrom ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: _settingFrom ? 'Setting FROM' : 'Setting TO',
            onPressed: () {
              setState(() {
                _settingFrom = !_settingFrom;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fromController,
                        decoration: const InputDecoration(labelText: 'From'),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (v) => _geocodeAndSet(v, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _toController,
                        decoration: const InputDecoration(labelText: 'To'),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (v) => _geocodeAndSet(v, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoadingRoutes ? null : _searchRoutes,
                    child: _isLoadingRoutes
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Find Safe Routes'),
                  ),
                )
              ],
            ),
          ),
          if (_loadingStations)
            const LinearProgressIndicator()
          else if (_stationLoadError != null)
            Container(
              color: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Stations load error: $_stationLoadError')),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStations),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (c) {
                    _mapController = c;
                    _refreshMarkers();
                    _mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 14));
                  },
                  initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 14),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  onTap: (LatLng pos) {
                    setState(() {
                      if (_settingFrom) {
                        _fromLocation = pos;
                        _fromController.text = 'Custom location';
                      } else {
                        _toLocation = pos;
                        _toController.text = 'Custom location';
                      }
                      _refreshMarkers();
                    });
                    _mapController.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));
                  },
                ),
                if (_showRouteResults)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _routeOptions
                            .map(
                              (route) => ListTile(
                                title: Text('${route.distance} • ${route.duration} • ${route.cost}'),
                                subtitle: Text('Safety: ${route.safetyLevel}'),
                                trailing: ElevatedButton(
                                  onPressed: () => _selectRoute(route),
                                  child: const Text('Select'),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
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
