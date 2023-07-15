import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:geocoding/geocoding.dart';

import 'createAtrip.dart';

class locate_location extends StatefulWidget {
  final late;
  final long;
  const locate_location({Key? key, this.late, this.long}) : super(key: key);

  @override
  State<locate_location> createState() => _locate_locationState();
}

class _locate_locationState extends State<locate_location> {
  double lat = 0.0;
  double lng = 0.0;
  var zoom = 8.5;
  bool flg = false;
  var ls = ['', ''];

  String cityName = '';
  double latitude = 30.033333;
  double longitude = 31.233334;
  var gmc;
  Set<Marker> mymarker = {
    Marker(
        visible: false,
        markerId: MarkerId("Trip Location"),
        position: LatLng(30.033333, 31.233334),
        infoWindow: InfoWindow(
          title: 'Trip Location',
        ))
  };

  Future<void> getCityCoordinates(String city) async {
    try {
      List<Location> locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;

        setState(() {
          CameraPosition newPosition = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 11.5,
          );
          gmc.animateCamera(CameraUpdate.newCameraPosition(newPosition));
        });
      } else {
        const snackBar = const SnackBar(
            content: Text(
              "Could not find any result for the supplied address or coordinates",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print("Error in getCityCoordinates: $e");
      const snackBar = const SnackBar(
          content: Text(
            "Could not find any result for the supplied address or coordinates",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }
  }

  void initState() {
    super.initState();

    if (widget.late == null && widget.long == null) {
      setState(() {
        lat = 31.2047129606226;
        lng = 29.919182284679422;
      });
    } else if (widget.late != null && widget.long != null) {
      setState(() {
        lat = widget.late;
        lng = widget.long;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: _buildappbar(),
        ),
        body: Column(
            children: [
              Container(
                height: 40,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: HexColor('#80858E'),
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter city name',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        // Call the function to get city coordinates when search button is pressed
                        getCityCoordinates(cityName);
                      },
                    ),
                  ),
                  onChanged: (value) {
                    // Update the cityName variable as the user types in the text field
                    cityName = value;
                  },
                ),
              ),
              Expanded(child: map()),
              flg
                  ? Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      height: 50,
                      width: double.infinity,
                      child: Center(
                          child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text('Trip City: '),
                          Text(
                            "${ls[0]}, ${ls[1]}",
                            style: TextStyle(color: Colors.green),
                          )
                        ],
                      )),
                    )
                  : Container()
            ],
          ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 50),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(2, 5), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(21),
            ),
            height: 45,
            child: new TextButton(
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  if (flg) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => createAtrip(
                                  locate: true,
                                  LAT: lat,
                                  LNG: lng,
                                  cityName: ls[0],
                                )));
                  } else {
                    const snackBar = const SnackBar(
                        content: Text(
                          'Please Select your Trip Location',
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.white);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                )),
          ),
        ),
      ),
    );
  }

  Widget map() {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: GoogleMap(
          onTap: (latlng) async {
            ls = await getCityAndCountry(latlng.latitude, latlng.longitude);
            if (ls[0] != '') {
              setState(() {
                mymarker.remove(Marker(markerId: MarkerId("Trip Location")));
                mymarker.add(Marker(
                    visible: true,
                    markerId: MarkerId("Trip Location"),
                    position: latlng));
                flg = true;
                lat = latlng.latitude;
                lng = latlng.longitude;
              });
            } else {
              setState(() {
                mymarker.clear();
                flg = false;
                lat = 0.0;
                lng = 0.0;
              });
              const snackBar = const SnackBar(
                  content: Text(
                    'Please Select Correct Location',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.white);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          markers: mymarker,
          mapType: MapType.normal,
          initialCameraPosition:  CameraPosition(
            target: LatLng(lat, lng),
            zoom: zoom,
          ),
          onMapCreated: (GoogleMapController controller) {
            gmc = controller;
          },
        ),
      ),
    );
  }
}

getCityAndCountry(double latitude, double longitude) async {
  var API_KEY = "AIzaSyB8eEZ9nyPWA_5cTHm1_ADp0SP0ZvG4Xzw";

  String apiUrl =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$API_KEY';

  print(Uri.parse(apiUrl));
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = data['results'];

    if (results.isNotEmpty) {
      final addressComponents = results[0]['address_components'];

      String city = '';
      String country = '';

      for (var component in addressComponents) {
        final types = List<String>.from(component['types']);

        if (types.contains('administrative_area_level_1')) {
          city = component['long_name'];
        }

        if (types.contains('country')) {
          country = component['long_name'];
        }
      }

      return [city, country];
    }
  }

  return '';
}

class _buildappbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
          padding: EdgeInsets.only(left: 10, top: 20, right: 0, bottom: 20),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context)),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      flexibleSpace: Container(
        child: Container(
          alignment: Alignment.bottomCenter,
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [HexColor("#f5d3a5"), HexColor("#7a4f25")],
            ),
            borderRadius: new BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0))),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Text(
          "Locate Location",
          style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
