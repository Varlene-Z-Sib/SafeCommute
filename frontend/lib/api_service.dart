import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const bool useEmulator = true; //gle for emulator
  static const String hostIp = '192.168.x.y'; // replace with your PC LAN IP

  static String get baseUrl {
    if (useEmulator) return 'http://127.0.0.1:8000';
    return 'http://$hostIp:8000';
  }

  String buildImageUrl(String filename) {
  return '${ApiConfig.baseUrl.replaceFirst(RegExp(r'/\$'), '')}/uploads/$filename';
}

}

class ApiService {
  String get baseUrl => ApiConfig.baseUrl;

  Future<List<dynamic>> fetchStations() async {
    final response = await http.get(Uri.parse('$baseUrl/stations'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load stations: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> submitIncident({
    required String stationId,
    required String type,
    required String description,
    required String severity,
    required bool anonymous,
    double? lat,
    double? lng,
  }) async {
    final payload = {
      "station_id": stationId,
      "type": type,
      "description": description,
      "severity": severity,
      "anonymous": anonymous,
      if (lat != null) "lat": lat,
      if (lng != null) "lng": lng,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/safety-reports'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to submit incident: ${response.statusCode} ${response.body}');
    }
  }

  /// If you want to support image upload later, backend must accept multipart.
  Future<Map<String, dynamic>> submitIncidentWithImage({
    required String stationId,
    required String type,
    required String description,
    required String severity,
    required bool anonymous,
    double? lat,
    double? lng,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/safety-reports');                           
    final request = http.MultipartRequest('POST', uri);

    request.fields['station_id'] = stationId;
    request.fields['type'] = type;
    request.fields['description'] = description;
    request.fields['severity'] = severity;
    request.fields['anonymous'] = anonymous.toString();
    if (lat != null) request.fields['lat'] = lat.toString();
    if (lng != null) request.fields['lng'] = lng.toString();

    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception(
          'Failed to submit incident with image: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<Map<String, dynamic>?> getNearestStation(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stations/nearby?lat=$lat&lng=$lng&radius_km=5'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      if (list.isNotEmpty) return list[0];
    }
    return null;
  }
}
