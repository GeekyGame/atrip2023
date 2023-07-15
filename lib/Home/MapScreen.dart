import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class PlacesPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  PlacesPage({required this.latitude, required this.longitude});

  @override
  _PlacesPageState createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  var API_KEY = "AIzaSyB8eEZ9nyPWA_5cTHm1_ADp0SP0ZvG4Xzw";

  List<Place> places = [];

/*
  Future<List<Place>> get_data(double latitude, double longitude) async {
    String apiUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?radius=5000&types=tourist_attraction&key=$API_KEY';

    final String url = '$apiUrl&location=$latitude,$longitude';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      var fetchedPlaces = <Place>[]; // Create an empty list of Place objects

      for (var result in results) {
        final name = result['name'];
        if (result.containsKey('photos') && result['photos'].isNotEmpty) {
          final photoReference = result['photos'][0]['photo_reference'];
          final types = List<String>.from(result['types']);

          final place = Place(
            name: name,
            photoUrl: getPhotoUrl(photoReference),
            types: types,
          );

          fetchedPlaces.add(place);
        }
      }

      return fetchedPlaces; // Return the list of Place objects
    } else {
      throw Exception('Failed to fetch places');
    }
  }
*/

/*
  Future<String?> getDescription(String placeId) async {
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address,formatted_phone_number,opening_hours,price_level,description&key=$API_KEY';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['result'];

      if (result.containsKey('description')) {
        return result['description'];
      }
    }

    return null;
  }
*/

  Future<List<Place>> getMuseumsByCity(String cityName) async {
    print('cityName: $cityName');
    var types = ['medical_tourism'];
    String typesParam = types.join('|');
    String apiUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json?type=$typesParam&key=$API_KEY';

    final String url = '$apiUrl&query=Medical Tourism in $cityName';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];
      final shuffledResults = results.toList()..shuffle(Random());

      List<Place> museums = [];

      for (var result in shuffledResults) {
        final name = result['name'];
        if (result.containsKey('photos') && result['photos'].isNotEmpty) {
          final photoReference = result['photos'][0]['photo_reference'];
          final types = List<String>.from(result['types']);

          final place = Place(
            name: name,
            photoUrl: getPhotoUrl(photoReference),
            types: types,
          );
          museums.add(place);
        }
      }

      return museums;
    } else {
      throw Exception('Failed to fetch museums');
    }
  }

  String getPhotoUrl(String photoReference) {
    var photoApiUrl =
        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$API_KEY';
    return photoApiUrl;
  }

  void getCityNameExample() async {
    double latitude = widget.latitude;
    double longitude = widget.longitude;

    try {
      String cityName = await getCityName(latitude, longitude);
      getMuseumsByCity(cityName).then((fetchedPlaces) {
        setState(() {
          places = fetchedPlaces;
        });
      });
    } catch (e) {
      print('Error fetching city name: $e');
    }

  }

  Future<String> getCityName(double latitude, double longitude) async {
    String apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$API_KEY';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      for (var result in results) {
        final addressComponents = result['address_components'];
        for (var component in addressComponents) {
          final types = List<String>.from(component['types']);
          if (types.contains('locality')) {
            return component['long_name'];
          }
        }
      }
    } else {
      throw Exception('Failed to fetch city name');
    }

    return '';
  }

  @override
  void initState() {
    super.initState();
    getCityNameExample();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places'),
      ),
      body: Center(
        child: places.length > 0
            ? ListView.builder(
          itemCount: places.length,
          itemBuilder: (BuildContext context, int index) {
            final place = places[index];

            return ListTile(
              leading: Image.network(place.photoUrl),
              title: Text(place.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Types: ${place.types.join(', ')}'),

                ],
              ),
            );
          },
        )
        : CircularProgressIndicator(
          color: Colors.deepOrange,
        ),
      ),
    );
  }
}

class Place {
  final String name;
  final String photoUrl;
  final List<String> types;
  final String? description;



  Place({required this.name, required this.photoUrl,required this.types,
    this.description
  });
}
