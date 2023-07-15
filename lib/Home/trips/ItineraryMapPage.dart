import 'dart:typed_data';
import 'dart:ui';
import 'dart:convert' as js;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart';

import '../../component/places_class.dart';
import 'createAtrip.dart';

class MapPage extends StatefulWidget {
  final List<Place> rearrangedPlaces;
  final List<Place> Restaurants;
  final cityName;

  MapPage({required this.rearrangedPlaces, required this.cityName, required this.Restaurants});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = Set();

  //Set<Polyline> _polylines = Set();
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }



  _createMarkers() async {
    _markers.clear();
    for (int i = 0; i < widget.rearrangedPlaces.length; i++) {
      Place place = widget.rearrangedPlaces[i];
      // Load the image asset into a Uint8List
      Uint8List imageBytes = await getBytesFromAsset('assets/icons/marker/${i+1}.png', 60);



      Marker marker = Marker(
        markerId: MarkerId(place.id.toString()),
        position: LatLng(place.lat, place.lng),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: 'click to see more...',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        place.photoUrl,
                        fit: BoxFit.cover,
                      ),
                      ListTile(
                        title: Text(place.name),
                        subtitle: Text("Destination Number: ${(widget.rearrangedPlaces.indexOf(place) +1).toString()}"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        icon: BitmapDescriptor.fromBytes(imageBytes),
        onTap: (){
          _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(  place.lat ,place.lng), 16));
        },
      );
      await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _markers.add(marker);
        });

      print("place.lat: ($i) ${place.lat}");
      print("place.lng: ($i) ${place.lng}");

    }
    for (int i = 0; i < widget.Restaurants.length; i++) {
      Place Restaurant = widget.Restaurants[i];
      Marker marker = Marker(
        markerId: MarkerId(Restaurant.id.toString()),
        position: LatLng(Restaurant.lat, Restaurant.lng),
        infoWindow: InfoWindow(
          title: Restaurant.name,
          snippet: 'click to see more...',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        Restaurant.photoUrl,
                        fit: BoxFit.cover,
                      ),
                      ListTile(
                        title: Text(Restaurant.name),
                        subtitle: Text("Destination Number: ${(widget.Restaurants.indexOf(Restaurant) +1).toString()}"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: (){
          _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(  Restaurant.lat ,Restaurant.lng), 16));
        },
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
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: _buildappbar(cityName: widget.cityName),
      ),

      body: Container(
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
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.rearrangedPlaces[0].lat,
                widget.rearrangedPlaces[0].lng),
            zoom: 12,
          ),
          markers: _markers,
          //polylines: _polylines,
          onMapCreated: (controller) {
            setState(() {
              _mapController = controller;
            });
          },
        ),
      ),
    );
  }
}
class _buildappbar extends StatelessWidget {
  final cityName;

  const _buildappbar({super.key, required this.cityName});

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
        padding: const EdgeInsets.only(top:15.0),
        child: Text(
          "${cityName} Places",
          style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}



