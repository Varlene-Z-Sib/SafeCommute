// services/maps_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safecommute/screens/route_planning_screen.dart';

class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = 'https://your-backend-api.com/api';

  // Headers for API requests
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer ${_getAuthToken()}', // Add if you have authentication
  };

  /// Get routes from your backend
  /// Your backend will call Google Maps API and add safety data
  static Future<List<RouteOption>> getRoutes({
    required LatLng from,
    required LatLng to,
    required List<String> transportTypes,
    required String preference,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routes/search'),
        headers: headers,
        body: json.encode({
          'from': {'lat': from.latitude, 'lng': from.longitude},
          'to': {'lat': to.latitude, 'lng': to.longitude},
          'transport_types': transportTypes,
          'preference': preference,
          'departure_time': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['routes'] as List)
            .map((route) => RouteOption.fromJson(route))
            .toList();
      } else {
        throw Exception('Failed to get routes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting routes: $e');
      rethrow;
    }
  }

  /// Search for locations (geocoding)
  static Future<List<LocationSuggestion>> searchLocations(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/locations/search?q=${Uri.encodeComponent(query)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['suggestions'] as List)
            .map((suggestion) => LocationSuggestion.fromJson(suggestion))
            .toList();
      }
    } catch (e) {
      print('Error searching locations: $e');
    }
    return [];
  }

  /// Get safety reports for an area
  static Future<List<SafetyReportSummary>> getSafetyReports(
    LatLng center,
    double radiusKm,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/safety/reports?lat=${center.latitude}&lng=${center.longitude}&radius=$radiusKm',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['reports'] as List)
            .map((report) => SafetyReportSummary.fromJson(report))
            .toList();
      }
    } catch (e) {
      print('Error getting safety reports: $e');
    }
    return [];
  }

  /// Submit a safety report
  static Future<bool> submitSafetyReport({
    required String type,
    required String description,
    required LatLng location,
    required String severity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/safety/reports'),
        headers: headers,
        body: json.encode({
          'type': type,
          'description': description,
          'location': {'lat': location.latitude, 'lng': location.longitude},
          'severity': severity,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error submitting safety report: $e');
      return false;
    }
  }

  static String _getAuthToken() {
    // TODO: Implement token management
    return 'your-auth-token';
  }
}

class LocationSuggestion {
  final String name;
  final String address;
  final LatLng coordinates;

  LocationSuggestion({
    required this.name,
    required this.address,
    required this.coordinates,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['name'],
      address: json['address'],
      coordinates: LatLng(json['lat'], json['lng']),
    );
  }
}
