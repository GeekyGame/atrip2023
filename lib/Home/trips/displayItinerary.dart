import 'dart:convert' as js;
import 'dart:math';
import 'dart:ui';
import 'package:atrip/Home/homeScreen.dart';
import 'package:atrip/Home/trips/viewPlace.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../component/calc_time.dart';
import '../../component/loading.dart';
import '../../component/places_class.dart';
import 'ItineraryMapPage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'createAtrip.dart';

class displayItinerary extends StatefulWidget {
  final List<Place> rearrangedPlaces;
  final Restaurants;
  final cityName;
  final days;
  final Ppd;
  final lat;
  final lng;
  final id;
  final state;
  final isEgypt;

  displayItinerary({
    required this.rearrangedPlaces,
    required this.Restaurants,
    required this.cityName,
    required this.days,
    required this.Ppd,
    required this.lat,
    required this.lng,
    required this.id,
    required this.state,
    required this.isEgypt,

  });

  @override
  _displayItineraryState createState() => _displayItineraryState();
}

class _displayItineraryState extends State<displayItinerary> {
  var cur = 1;

  ScrollController _controller1 = ScrollController();
  ScrollController _controller2 = ScrollController();
  List<File> _photos = [];
  var _photosUrl = [];

  Set<Marker> _markers = Set();
  var temperature;
  var windspeed;


  void openGoogleMaps(double startLat, double startLng, int i) async {
    var sourceList = widget.rearrangedPlaces;
    print("i:$i");
    int startIndex = (i - int.parse(widget.Ppd)) < 0 ? 0 : (i - int.parse(widget.Ppd)) +1;
    print("startIndex:$startIndex");
    int endIndex = i + 1;
    print("endIndex:$endIndex");

    List<LatLng> coordinates = sourceList
        .sublist(startIndex, endIndex )
        .map((place) => LatLng(place.lat, place.lng))
        .toList();

    final String apiUrl = 'https://www.google.com/maps/dir/';

    // Add the starting point to the URL
    String url = apiUrl + '$startLat,$startLng/';

    // Add the coordinates to the URL
    for (int i = 0; i < coordinates.length; i++) {
      LatLng coordinate = coordinates[i];
      url += '${coordinate.latitude},${coordinate.longitude}/';
    }
    print(url);
    // Open Google Maps
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _createMarkers() async {
    for (int i = 0; i < widget.rearrangedPlaces.length; i++) {
      Place place = widget.rearrangedPlaces[i];
      // Load the image asset into a Uint8List
      Uint8List imageBytes =
      await getBytesFromAsset('assets/icons/marker/${i + 1}.png', 50);

      // Create a BitmapDescriptor from the imageBytes
      BitmapDescriptor customIcon = BitmapDescriptor.fromBytes(imageBytes);

      Marker marker = Marker(
        markerId: MarkerId(place.id.toString()),
        position: LatLng(place.lat, place.lng),
        icon: customIcon,

      );
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _markers.add(marker);
      });
    }
  }

  // Helper function to get bytes from an asset file
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<List<String>> getPlaceImages(String placeId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('itineraries')
          .where('placeId', isEqualTo: placeId)
          .get();

      final List<String> imageLinks = [];

      querySnapshot.docs.forEach((doc) {
        final images = doc.data()['images'] as List<dynamic>;
        imageLinks.addAll(images.map((image) => image.toString()));
      });

      return imageLinks;
    } catch (e) {
      print('Error retrieving place images: $e');
      return [];
    }
  }

  Future<void> deleteItinerary(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Itinerary'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure to Delete Itinerary'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: Text('Delete',
                    style: TextStyle(color: Colors.red),),
                  onPressed: () async {
                    var uid = FirebaseAuth.instance.currentUser!.uid;
                    try {
                      showLoading(context);
                      var uid = FirebaseAuth.instance.currentUser!.uid;

                      try {
                        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
                        final itineraryCollection = userDoc.collection('itineraries');

                        await itineraryCollection.doc(widget.id).delete();

                        print('Document deleted successfully');
                      } catch (e) {
                        print('Error deleting document: $e');
                      }
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => homeScreen(),
                        ),
                      );
                      final snackBar = SnackBar(
                          content: Text(
                            'Itinerary Deleted successfully',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: HexColor('#555555'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      print('Itinerary Deleted successfully.');
                    } catch (e) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      final snackBar = SnackBar(
                          content: Text(
                            'Failed to Delete Itinerary',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: HexColor('#555555'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      print("Failed to Delete Itinerary (e): $e");
                    }
                  }),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop();
      var snackBar = SnackBar(
          content: Text(
            "Please re-signin to be able to delete your account",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print("No user is currently signed in.");
    }
  }

  Future<void> changeItineraryState(BuildContext context) async {

    try {
      showLoading(context);
      var uid = FirebaseAuth.instance.currentUser!.uid;

      try {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        final itineraryCollection = userDoc.collection('itineraries');

        await itineraryCollection.doc(widget.id).update({
          'state' : widget.state == 'ongoing' ? 'past' : 'ongoing'
        });

      } catch (e) {
        print('Error changeItineraryState: $e');
      }
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => homeScreen(),
        ),
      );
      final snackBar = SnackBar(
          content: Text(
            widget.state == 'ongoing' ? 'Itinerary Marked as Past successfully' : 'Itinerary Marked as onGoing successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: HexColor('#555555'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('Itinerary Marked as Past successfully.');
    } catch (e) {
      Navigator.of(context).pop();
      final snackBar = SnackBar(
          content: Text(
            'Failed to Delete Itinerary',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: HexColor('#555555'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print("Failed to Delete Itinerary (e): $e");
    }
  }

  getItineraryGallary() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final itineraryDoc = userDoc.collection('itineraries').doc(widget.id);

    final snapshot = await itineraryDoc.get();
    _photosUrl = snapshot.data()?['images'] as List<dynamic>;

    print(_photosUrl);
  }

  fetchWeather(double latitude, double longitude) async {
    final url = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&hourly=temperature_2m,relativehumidity_2m,windspeed_10m';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var result = js.jsonDecode(response.body);
      temperature = result['current_weather']['temperature'];
      windspeed = result['current_weather']['windspeed'];

    } else {
      throw Exception('Failed to fetch weather data');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchWeather(widget.lat,widget.lng);
    getItineraryGallary();
    _createMarkers();
    _controller1.addListener(() {
      if (_controller1.position.userScrollDirection ==
          ScrollDirection.forward ||
          _controller1.position.userScrollDirection ==
              ScrollDirection.reverse) {
        _controller2.jumpTo(_controller1.offset);
      }
    });
    _controller2.addListener(() {
      if (_controller2.position.userScrollDirection ==
          ScrollDirection.forward ||
          _controller2.position.userScrollDirection ==
              ScrollDirection.reverse) {
        _controller1.jumpTo(_controller2.offset);
      }
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: cur == 3
          ? FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.photo_library),
                          title: Text('Choose from gallery'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.camera_alt),
                          title: Text('Take a photo'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            )
          : Container(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.cityName,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: InkWell(
                    onTap: () {
                      deleteItinerary(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delete Itinerary'),
                        Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  value: 'Delete',
                ),
                PopupMenuItem(
                  child: InkWell(
                    onTap: () {
                      changeItineraryState(context);
                    },
                    child: widget.state == 'ongoing' ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mark as Past'),
                      ],
                    ):
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                      decoration: BoxDecoration(
                        color: HexColor('#eeeeee'),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Marked as Past'),
                          Icon(Icons.check,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  value: 'Past',
                ),
              ];
            },
            onSelected: (value) {
              // Handle the selected option
              if (value == 'Delete') {
                // Perform action for Option 1
              } else if (value == 'option2') {
                // Perform action for Option 2
              }
              // Add more conditions for additional options
            },
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                if(true){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPage(
                        rearrangedPlaces: widget.rearrangedPlaces,
                        cityName: widget.cityName,
                        Restaurants: widget.Restaurants,
                      ),
                    ),
                  );
                }else{

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
                child: Stack(
                  children: [
                    IgnorePointer(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(widget.rearrangedPlaces[0].lat,
                              widget.rearrangedPlaces[0].lng),
                          zoom: 12,
                        ),
                        zoomControlsEnabled: false,
                        markers: _markers,
                        onTap: null,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          height: 40,
                          width: double.infinity,
                          color: Colors.grey.withOpacity(.8),
                          child: Text(
                            "Click to view map",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    widget.isEgypt ?
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              cur = 1;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cur == 1 ? 60 : 50,
                            width: cur == 1 ? 60 : 50,
                            decoration: BoxDecoration(
                              color: cur == 1 ? HexColor('FFD4A6') : null,
                              border: cur != 1
                                  ? Border.all(
                                      color: HexColor('E2824E'), width: 2)
                                  : null,
                              borderRadius: cur != 1
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                            ),
                            child: Icon(
                              Icons.place_rounded,
                              color: HexColor('E2824E'),
                              size: 30,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              cur = 2;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cur == 2 ? 60 : 50,
                            width: cur == 2 ? 60 : 50,
                            decoration: BoxDecoration(
                              color: cur == 2 ? HexColor('FFD4A6') : null,
                              border: cur != 2
                                  ? Border.all(
                                      color: HexColor('E2824E'), width: 2)
                                  : null,
                              borderRadius: cur != 2
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                            ),
                            child: Icon(
                              Icons.local_pizza_sharp,
                              color: HexColor('E2824E'),
                              size: 30,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              cur = 3;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cur == 3 ? 60 : 50,
                            width: cur == 3 ? 60 : 50,
                            decoration: BoxDecoration(
                              color: cur == 3 ? HexColor('FFD4A6') : null,
                              border: cur != 3
                                  ? Border.all(
                                      color: HexColor('E2824E'), width: 2)
                                  : null,
                              borderRadius: cur != 3
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                            ),
                            child: Icon(
                              Icons.image,
                              color: HexColor('E2824E'),
                              size: 30,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              cur = 4;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cur == 4 ? 60 : 50,
                            width: cur == 4 ? 60 : 50,
                            decoration: BoxDecoration(
                              color: cur == 4 ? HexColor('FFD4A6') : null,
                              border: cur != 4
                                  ? Border.all(
                                      color: HexColor('E2824E'), width: 2)
                                  : null,
                              borderRadius: cur != 4
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                            ),
                            child: Icon(
                              Icons.notification_important_rounded,
                              color: HexColor('E2824E'),
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ):Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              cur = 1;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cur == 1 ? 60 : 50,
                            width: cur == 1 ? 60 : 50,
                            decoration: BoxDecoration(
                              color: cur == 1 ? HexColor('FFD4A6') : null,
                              border: cur != 1
                                  ? Border.all(
                                  color: HexColor('E2824E'), width: 2)
                                  : null,
                              borderRadius: cur != 1
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                            ),
                            child: Icon(
                              Icons.place_rounded,
                              color: HexColor('E2824E'),
                              size: 30,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              cur = 2;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cur == 2 ? 60 : 50,
                            width: cur == 2 ? 60 : 50,
                            decoration: BoxDecoration(
                              color: cur == 2 ? HexColor('FFD4A6') : null,
                              border: cur != 2
                                  ? Border.all(
                                  color: HexColor('E2824E'), width: 2)
                                  : null,
                              borderRadius: cur != 2
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                            ),
                            child: Icon(
                              Icons.local_pizza_sharp,
                              color: HexColor('E2824E'),
                              size: 30,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              cur = 3;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: cur == 3 ? 60 : 50,
                            width: cur == 3 ? 60 : 50,
                            decoration: BoxDecoration(
                              color: cur == 3 ? HexColor('FFD4A6') : null,
                              border: cur != 3
                                  ? Border.all(
                                  color: HexColor('E2824E'), width: 2)
                                  : null,
                              borderRadius: cur != 3
                                  ? BorderRadius.circular(10)
                                  : BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                            ),
                            child: Icon(
                              Icons.image,
                              color: HexColor('E2824E'),
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          color: HexColor('FFD4A6'),
                          borderRadius: cur == 1
                              ? BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10))
                              : cur == 4
                                  ? BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))
                                  : BorderRadius.circular(10),
                        ),
                        child: cur == 1
                            ? _places()
                            : cur == 2
                                ? _restaurant()
                                : cur == 3
                                    ? _gallery()
                                    : _emergency(),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _places() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itinerary:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            temperature != null ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_outlined, size: 15,),
                    Text(
                      '  $temperature °C',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.wind_power_outlined, size: 15,),
                    Text(
                      '  $windspeed m/s',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),

              ],
            ):
            Container(),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: widget.rearrangedPlaces.length,
              itemBuilder: (BuildContext context, int i) {
                var placeNum = ((i + 1) - 1) % int.parse(widget.Ppd) + 1;
                return widget.rearrangedPlaces.length > 0 ?_buildPlaceWidget(i, placeNum)
                :Container(child: Center(child: Text(
                "No Restaurants Found",
                textAlign: TextAlign.center,
                style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54),
                ),),);
              },
            ),
          ),
        ),
      ],
    );
  }

  FutureBuilder<String> _buildPlaceWidget(int i, placeNum) {
    final place = widget.rearrangedPlaces[i];
    var day = (i / int.parse(widget.Ppd).toInt() + 1).ceil();
    var futureTime = i < widget.rearrangedPlaces.length - 1
        ? getTravelTime(
            place.lat,
            place.lng,
            widget.rearrangedPlaces[i + 1].lat,
            widget.rearrangedPlaces[i + 1].lng,
          )
        : null;

    return FutureBuilder<String>(
      future: futureTime,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              height: 200,
              child: Center(
                  child: CircularProgressIndicator(
                color: Colors.deepOrange,
              )));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var time = snapshot.data;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              i % int.parse(widget.Ppd) == 0
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          i != 0
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50.0),
                                  child: Divider(thickness: 2),
                                )
                              : Container(),
                          Text(
                            'Day $day',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(top: 10),
                          alignment: Alignment.centerRight,
                          height: 200,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: HexColor('E2824E'),
                                ),
                                child: Text(
                                  "$placeNum",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(height: 5),
                              i < widget.rearrangedPlaces.length - 1 &&
                                      placeNum != int.parse(widget.Ppd).toInt()
                                  ? Column(
                                      children: [
                                        Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          height: 12,
                                          width: 2.5,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          height: 12,
                                          width: 2.5,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          height: 12,
                                          width: 2.5,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          height: 12,
                                          width: 2.5,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          height: 12,
                                          width: 2.5,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          height: 12,
                                          width: 2.5,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          height: 12,
                                          width: 2.5,
                                          color: Colors.white,
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: InkWell(
                          onTap: () {
                            //print("${place.lat}, ${place.lng}");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => viewPlace(
                                          place: place,
                                          cityName: widget.cityName,
                                        )));
                          },
                          child: Container(
                            height: 160,
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: HexColor('#ffffff'),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: 180,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        place.photoUrl,                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context, Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.deepOrange,
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(place.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Place Rating",
                                            style: TextStyle(
                                                color: Colors.black45),
                                          ),
                                          Row(
                                            children: [
                                              placeRating(place.rating),
                                              SizedBox(width: 10),
                                              Text(
                                                place.rating.toStringAsFixed(1),
                                                style: TextStyle(
                                                  color: Colors.black45,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: place.isOpen == null
                                                    ? Colors.grey
                                                    : place.isOpen
                                                        ? Colors.green
                                                        : Colors.red),
                                            child: Text(
                                              place.isOpen == null
                                                  ? "Unavailable"
                                                  : place.isOpen
                                                      ? "Open"
                                                      : "Currently Close",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Click to View",
                                            style: TextStyle(
                                                color: Colors.black45),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  i < widget.rearrangedPlaces.length - 1 &&
                          placeNum != int.parse(widget.Ppd).toInt()
                      ? Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 55),
                          child: Text(
                            "~ $time",
                            style: TextStyle(color: HexColor('E2824E')),
                          ))
                      : Container(),
                ],
              ),
              i % int.parse(widget.Ppd) == (int.parse(widget.Ppd) - 1) ?
              InkWell(
                onTap: () {
                  print(i);
                  openGoogleMaps(widget.lat,widget.lng,i);
                },
                child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(
                              2, 5), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(21),
                    ),
                    height: 40,
                    child: Text('Get Day ${day-1} Itinerary',
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500),)),
              ):
              Container(),

            ],
          );
        }
      },
    );
  }

  Widget _restaurant() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            'Restaurants Near you:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: widget.Restaurants.length > 0 ? Container(

                  child: ListView.builder(
                    itemCount: widget.Restaurants.length,
                    itemBuilder: (BuildContext context, int i) {
                      var placeNum = ((i + 1) - 1) % int.parse(widget.Ppd) + 1;

                      final restaurant = widget.Restaurants[i];
                      var day = (i / int.parse(widget.Ppd).toInt() + 1).ceil();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          i % int.parse(widget.Ppd) == 0
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      i != 0
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 50.0),
                                              child: Divider(thickness: 2),
                                            )
                                          : Container(),
                                      Text(
                                        'Day $day',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(top: 10),
                                      alignment: Alignment.centerRight,
                                      height: 200,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: HexColor('E2824E'),
                                            ),
                                            child: Text(
                                              "$placeNum",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) => viewPlace(
                                                      place: restaurant,
                                                      cityName: widget.cityName,
                                                    )));
                                      },
                                      child: Container(
                                        height: 160,
                                        padding: EdgeInsets.all(8),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: HexColor('#ffffff'),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                child: Stack(
                                                  children: [
                                                    Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            HexColor('#FAB916'),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 2,
                                                              blurRadius: 5,
                                                              offset: Offset(0,
                                                                  3), // changes position of shadow
                                                            ),
                                                          ],
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                            restaurant.photoUrl,
                                                            fit: BoxFit
                                                                .fitHeight,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(restaurant.name,
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Restaurant Rating",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black45),
                                                      ),
                                                      Row(
                                                        children: [
                                                          placeRating(restaurant
                                                              .rating),
                                                          SizedBox(width: 10),
                                                          Text(
                                                            restaurant.rating
                                                                .toStringAsFixed(
                                                                    1),
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black45,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 5,
                                                                horizontal: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: restaurant
                                                                            .isOpen ==
                                                                        null
                                                                    ? Colors
                                                                        .grey
                                                                    : restaurant
                                                                            .isOpen
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red),
                                                        child: Text(
                                                          restaurant.isOpen ==
                                                                  null
                                                              ? "Unavailable"
                                                              : restaurant
                                                                      .isOpen
                                                                  ? "Open"
                                                                  : "Currently Close",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {},
                                                        child: Text(
                                                          "View",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black45),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                )
              : Container(child: Center(child: Text(
            "No Restaurants Found",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54),
          ),),)

        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().getImage(source: source);
    if (pickedImage != null) {
      final file = File(pickedImage.path);
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child('itinerary_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      try {
        // Upload the image to Firebase Storage
        await storageRef.putFile(file);

        // Get the download URL of the uploaded image
        final downloadURL = await storageRef.getDownloadURL();

        final uid = FirebaseAuth.instance.currentUser!.uid;
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        final itineraryDoc = userDoc.collection('itineraries').doc(widget.id);

        // Update the 'images' field in the itinerary document
        await itineraryDoc.update({
          'images': FieldValue.arrayUnion([downloadURL]),
        });

        await getItineraryGallary();
        setState(() {
        });

      } catch (e) {
        print('Failed to upload image: $e');
        // Handle the error accordingly
      }
    }
  }

  Widget _buildGallery() {
    return _photosUrl.length > 0
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: _photosUrl.length,
            itemBuilder: (context, index) {
              return  InkWell(
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: (_) => ImageDialog(_photosUrl[index]));
                },
                child: Container(
                  width: 180,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _photosUrl[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepOrange,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          )
        : Container(
            child: Center(
              child: Text(
                "Your trip Gallery is empty\nClick '+' to add image",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black54),
              ),
            ),
          );
  }

  Widget _gallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            'Gallery:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(child: _buildGallery()),
      ],
    );
  }

  Widget _emergency() {
    return Column(
      children: [
        Container(
          child: Text(
            'Emergency:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EmergencyContactCard(
                    title: 'Police',
                    number: '122',
                    iconData: Icons.local_police_outlined,
                    color: Colors.black,
                  ),
                  SizedBox(height: 16.0),
                  EmergencyContactCard(
                    title: 'Ambulance',
                    number: '123',
                    iconData: Icons.add,
                    color: Colors.black,
                  ),
                  SizedBox(height: 16.0),
                  EmergencyContactCard(
                    title: 'Fire Department',
                    number: '180',
                    iconData: Icons.fire_truck_outlined,
                    color: Colors.black,
                  ),
                  SizedBox(height: 16.0),
                  EmergencyContactCard(
                    title: 'Consumer Protection',
                    number: '19588',
                    iconData: Icons.safety_divider,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget placeRating(double rating) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 15,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        // Do something with the new rating
      },
      ignoreGestures: true,
    );
  }

  Widget ImageDialog(img) {
    return Dialog(
      child: Container(
        width: double.infinity,
        height: 500,
        child: Image.network(img),
      ),
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  final String title;
  final String number;
  final IconData iconData;
  final Color color;

  const EmergencyContactCard({
    required this.title,
    required this.number,
    required this.iconData,
    required this.color,
  });
  void _makePhoneCall(context) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
    if (res != null && res) {
      // Call initiated successfully
      print('Call initiated');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to make a phone call.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              iconData,
              color: Colors.black54,
              size: 32.0,
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                _makePhoneCall(context);
              },
              icon: Icon(
                Icons.call,
                color: color,
                size: 32.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
