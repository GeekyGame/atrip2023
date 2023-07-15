import 'dart:convert';
import 'package:atrip/Home/trips/createAtrip.dart';
import 'package:http/http.dart' as http;

Future<String> getTravelTime(double originLat, double originLng, double destLat, double destLng) async {
  final apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=$originLat,$originLng&destination=$destLat,$destLng&key=$API_KEY';

  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    final routes = jsonData['routes'] as List<dynamic>;
    if (routes.isNotEmpty) {
      final legs = routes[0]['legs'] as List<dynamic>;
      if (legs.isNotEmpty) {
        final duration = legs[0]['duration']['text'];
        return duration;
      }
    }
  }

  return 'Unable to calculate travel time';
}
