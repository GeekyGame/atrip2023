import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../component/loading.dart';
import '../../component/places_class.dart';
import 'createAtrip.dart';
import 'displayItinerary.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as js;

class generateItinerary extends StatefulWidget {
  final lat;
  final lng;
  final cityName;
  final days;
  final PpD;
  final prefList;
  final cost;
  const generateItinerary({
    Key? key,
    required this.lat,
    required this.lng,
    required this.cityName,
    required this.prefList,
    required this.cost,
    required this.days,
    required this.PpD,
  }) : super(key: key);

  @override
  State<generateItinerary> createState() => _generateItineraryState();
}

class _generateItineraryState extends State<generateItinerary>
    with SingleTickerProviderStateMixin {
  var _controller;
  var _animation;
  double _progress = 0.0;
  String _status = 'Generating';
  bool flg = false;
  var id;


  var culturalList = ['museum', 'exhibition', 'art', 'historical', 'temple', 'monument', 'tomb', 'cultural'];
  var medicalList = ['health', 'retreat','spa', 'hot springs', 'wellness', 'yoga'];
  var religiousList = ['mosque', 'church', 'shrine', 'worship', 'temple'];
  var recreationalList = ['mall', 'cinema', 'shopping', 'game', 'arcade', 'theme park', 'amusement park'];
  List<Place> places = [];
  List<Place> rearrangedPlaces = [];
  List<Place> Restaurants = [];
  Set<Marker> _markersRestaurant = Set();


  GenerateItinerary() async {
    var maxPlaces = int.parse(widget.days) * int.parse(widget.PpD);
    var Num = (maxPlaces / widget.prefList.length).ceil();
    var LS1, LS2, LS3, LS4, LS5;
    if (widget.prefList.contains('Cultural Tourism')) {
      for (var item in culturalList) {
        var N = (Num / culturalList.length).ceil();
        LS1 = await getDataByCity(widget.cityName, 'Cultural Tourism', item, N);
        places.addAll(LS1);
      }
    }
    if (widget.prefList.contains('Medical Tourism')) {
      for (var item in medicalList) {
        var N = (Num / medicalList.length).ceil();
        LS2 = await getDataByCity(widget.cityName, 'Medical Tourism', item, N);
        places.addAll(LS2);
      }
    }
    if (widget.prefList.contains('Religious Tourism')) {
      for (var item in religiousList) {
        var N = (Num / religiousList.length).ceil();
        LS3 =
            await getDataByCity(widget.cityName, 'Religious Tourism', item, N);
        places.addAll(LS3);
      }
    }
    if (widget.prefList.contains('Recreational Tourism')) {
      for (var item in recreationalList) {
        var N = (Num / recreationalList.length).ceil();
        LS4 = await getDataByCity(
            widget.cityName, 'Recreational Tourism', item, N);
        places.addAll(LS4);
      }
    }
    if (widget.prefList.contains('Others')) {
      LS5 = await getFamousPlaces(widget.cityName, Num);
      places.addAll(LS5);
    }
    if (places.length > maxPlaces) {
      places.shuffle(); // Shuffle the list
      places.removeRange(maxPlaces,
          places.length); // Remove elements from index num to the end
      rearrangedPlaces = rearrangePlaces(places, widget.lat, widget.lng);
      //rearrangedPlaces = rearrangePlaces(places);
    }
    else {
      rearrangedPlaces = rearrangePlaces(places, widget.lat, widget.lng);
      //rearrangedPlaces = rearrangePlaces(places);
    }
    await _handleRestaurant();
    await updateData(
      cityName: widget.cityName,
      days: widget.days,
      Ppd: widget.PpD,
      lat: widget.lat,
      lng: widget.lng,
      attractions:rearrangedPlaces.map((place) => place.toJson()).toList(),
      Restaurants: Restaurants.map((place) => place.toJson()).toList(),
    );
    setState(() {
      flg = true;
    });
  }

  getDataByCity(cityName, type, query, num) async {
    String apiUrl =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?type=$type&key=$API_KEY';

    final String url = '$apiUrl&query=$query in $cityName';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = js.json.decode(response.body);
      final results = data['results'];
      final shuffledResults = results.toList()..shuffle(Random());

      List<Place> placesList = [];

      for (var result in shuffledResults) {
        final id = result['place_id'];

        // Check if the place with the same ID already exists in the list
        bool placeExists = placesList.any((place) => place.id == id);
        bool placeExists2 = places.any((place) => place.id == id);

        if (result.containsKey('photos') &&
            result['photos'].isNotEmpty &&
            placesList.length <= num &&
            !placeExists && !placeExists2) {

          final name = result['name'];
          final photoReference = result['photos'][0]['photo_reference'];
          final types = List<String>.from(result['types']);
          final lat = result['geometry']['location']['lat'];
          final lng = result['geometry']['location']['lng'];
          bool? openNow;
          final rating = await getPlaceRating(id);

          if (result.containsKey('opening_hours')) {
            openNow = result['opening_hours']['open_now'];
          }

          final place = Place(
            name: name,
            id: id,
            lat: lat,
            lng: lng,
            photoUrl: getPhotoUrl(photoReference),
            types: types,
            rating: rating,
            isOpen: openNow,
          );
          placesList.add(place);
        }
      }


      return placesList;
    }
    else {
      throw Exception('Failed to fetch data');
    }
  }

  getFamousPlaces(String cityName, num) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=famous+places+in+$cityName&key=$API_KEY';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = js.json.decode(response.body);
      final results = data['results'];
      final shuffledResults = results.toList()..shuffle(Random());

      List<Place> placesList = [];

      for (var result in shuffledResults) {
        final id = result['place_id'];

        bool placeExists = placesList.any((place) => place.id == id);
        bool placeExists2 = places.any((place) => place.id == id);

        if (result.containsKey('photos') &&
            result['photos'].isNotEmpty &&
            placesList.length <= num &&
            !placeExists && !placeExists2) {
          bool? openNow;
          final name = result['name'];
          final photoReference = result['photos'][0]['photo_reference'];
          final types = List<String>.from(result['types']);
          final lat = result['geometry']['location']['lat'];
          final lng = result['geometry']['location']['lng'];
          if (result.containsKey('opening_hours')) {
            openNow = result['opening_hours']['open_now'];
          }
          final rating = await getPlaceRating(id);
          final place = Place(
            name: name,
            id: id,
            lat: lat,
            lng: lng,
            photoUrl: getPhotoUrl(photoReference),
            types: types,
            rating: rating,
            isOpen: openNow,
          );
          placesList.add(place);
        }
      }
      return placesList;
    } else {
      throw Exception('Failed to fetch famous places');
    }
  }

  getPhotoUrl(String photoReference) {
    var photoApiUrl =
        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$API_KEY';
    return photoApiUrl;
  }

  Future<double> getPlaceRating(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=rating&key=$API_KEY';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseData = js.json.decode(response.body);
      final result = responseData['result'];
      if (result.containsKey('rating')) {
        final rating = result['rating'];
        return double.parse(rating.toString());
      } else {
        return 0.0; // Default rating of zero if rating is not found
      }
    } else {
      throw Exception('Failed to fetch place rating');
    }
  }

  List<Place> rearrangePlaces(List<Place> places, double inputLat, double inputLng) {
    List<Place> rearrangedPlaces = [];

    // Calculate the distance between two sets of coordinates using the Haversine formula

    double shortestDistance = double.infinity;
    var nearestPlace;

    // Find the nearest place to the input coordinates
    for (int i = 0; i < places.length; i++) {
      double distance =
          calculateDistance(places[i].lat, places[i].lng, inputLat, inputLng);
      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearestPlace = places[i];
      }
    }

    rearrangedPlaces.add(nearestPlace);

    // Remove the nearest place from the original list
    places.remove(nearestPlace);

    // Rearrange the remaining places based on their distances
    while (places.isNotEmpty) {
      double shortestDistance = double.infinity;
      var nearestPlace;

      // Find the nearest place to the last added place
      for (int i = 0; i < places.length; i++) {
        double distance = calculateDistance(rearrangedPlaces.last.lat,
            rearrangedPlaces.last.lng, places[i].lat, places[i].lng);
        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearestPlace = places[i];
        }
      }

      rearrangedPlaces.add(nearestPlace);

      // Remove the nearest place from the original list
      places.remove(nearestPlace);
    }

    return rearrangedPlaces;
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = (lat2 - lat1) * pi / 180;
    double dLng = (lng2 - lng1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  Future<String> getImageUrlByCityName(String cityName) async {
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$cityName&inputtype=textquery&fields=photos&key=$API_KEY';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = js.json.decode(response.body);
      final photoReference = data['candidates'][0]['photos'][0]['photo_reference'];
      final maxWidth = 800; // Specify the maximum width of the image
      final imageUrl =
          'https://maps.googleapis.com/maps/api/place/photo?photoreference=$photoReference&maxwidth=$maxWidth&key=$API_KEY';
      return imageUrl;
    } else {
      throw Exception('Failed to fetch image');
    }
  }

  getBestRestaurant(double lat, double lng, radius) async {
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    String location = '$lat,$lng';
    String type = 'restaurant';
    String keyword = '';

    String url =
        '$apiUrl?location=$location&radius=$radius&type=$type&keyword=$keyword&key=$API_KEY';

    final response = await http.get(Uri.parse(url));
    //print(url);
    if (response.statusCode == 200) {
      final data = js.json.decode(response.body);
      final results = data['results'];
      final shuffledResults = results.toList()..shuffle(Random());

      try {
        for (var i = 0; i < shuffledResults.length; i++) {
          if (shuffledResults[i].containsKey('photos') &&
              shuffledResults[i]['photos'].isNotEmpty ) {
            bool? openNow;
            final name = shuffledResults[0]['name'];
            final photoReference =
            shuffledResults[0]['photos'][0]['photo_reference'];
            final id = shuffledResults[0]['place_id'];
            final types = List<String>.from(shuffledResults[0]['types']);
            final lat = shuffledResults[0]['geometry']['location']['lat'];
            final lng = shuffledResults[0]['geometry']['location']['lng'];
            _markersRestaurant.add(Marker(
              markerId: MarkerId(id.toString()),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            )
            );
            final rating = await getPlaceRating(id);
            //double distance = calculateDistance(lat, lng, widget.lat, widget.lng);
            if (shuffledResults[0].containsKey('opening_hours')) {
              openNow = shuffledResults[0]['opening_hours']['open_now'];
            }
            final place = Place(
                name: name,
                id: id,
                lat: lat,
                lng: lng,
                photoUrl: getPhotoUrl(photoReference),
                types: types,
                rating: rating,
                isOpen: openNow);
            Restaurants.add(place);
            return;
          }
        }
      } catch (e) {
        radius += 500;
        await getBestRestaurant(lat, lng, radius);
      }
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  _handleRestaurant() async {
    for (var place in rearrangedPlaces) {
      await getBestRestaurant(place.lat, place.lng, 1000);
    }
  }

  Future<void> updateData({attractions, Restaurants,cityName, lat, lng, Ppd, days}) async {
    var imgUrl = await getImageUrlByCityName(cityName);
    try {
      var uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      id = userDoc.collection('itineraries').id;
      // Create a new document in the "ongoing" collection
      final newDocRef = await userDoc.collection('itineraries').add({
        'attractions': attractions,
        'Restaurants':Restaurants,
        'cityName': cityName,
        'imgUrl': imgUrl,
        'location': GeoPoint(lat, lng),
        'Ppd': Ppd,
        'days': days,
        'state': 'ongoing',
        'prefList': widget.prefList,
      });
      id = newDocRef.id;

      print('New document created in "ongoing" collection with ID: ${newDocRef
          .id}');
    } catch (e) {
      print('Error creating new document: $e');
    }
  }

  bool isInEgypt(double latitude, double longitude) {
    // Define the latitude and longitude boundaries of Egypt
    final double egyptMinLatitude = 22.0;
    final double egyptMaxLatitude = 31.6;
    final double egyptMinLongitude = 25.0;
    final double egyptMaxLongitude = 36.9;

    // Check if the location is within the boundaries of Egypt
    if (latitude >= egyptMinLatitude &&
        latitude <= egyptMaxLatitude &&
        longitude >= egyptMinLongitude &&
        longitude <= egyptMaxLongitude) {
      return true;
    }

    return false;
  }


  next_page() async {
    await Future.delayed(Duration(milliseconds: 500));
    showLoading(context);
    while (!flg) {
      await Future.delayed(Duration(seconds: 1));
    }
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => displayItinerary(
          rearrangedPlaces: rearrangedPlaces,
          Restaurants: Restaurants,
          cityName: widget.cityName,
          days: widget.days,
          Ppd: widget.PpD,
          lat: widget.lat,
          lng: widget.lng,
          id: id,
          state: "ongoing",
          isEgypt: isInEgypt(widget.lat, widget.lng),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    GenerateItinerary();
    _controller = AnimationController(
      duration: Duration(seconds: 15),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.addListener(() {
      setState(() {
        _progress = _animation.value;
        if (_progress >= 1.0) {
          _status = 'Generate Itinerary complete';
          next_page();
        } else if (_progress >= 0.8) {
          _status = 'Generating ....';
        } else if (_progress >= 0.6) {
          _status = 'Generating ...';
        } else if (_progress >= 0.4) {
          _status = 'Generating ..';
        } else if (_progress >= 0.2) {
          _status = 'Generating .';
        }
      });
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    image: DecorationImage(
                        image: AssetImage("assets/generate.jpg"),
                        fit: BoxFit.cover)),
              ),
              SizedBox(height: 30),
              Text(_status,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: MediaQuery.of(context).size.width * _progress,
                      height: 35,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: _progress >= 1.0
                              ? BorderRadius.circular(50)
                              : BorderRadius.circular(50)),
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
}
