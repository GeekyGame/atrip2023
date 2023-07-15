import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';

class ViewLocation extends StatefulWidget {
  final lat;
  final lng;
  final name;

  const ViewLocation({Key? key, required this.lat, required this.lng, required this.name}) : super(key: key);

  @override
  State<ViewLocation> createState() => _ViewLocationState();
}

class _ViewLocationState extends State<ViewLocation> {


  GoogleMapController? gmc;
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: _buildappbar(),
      ),
      body: map(),

    );
  }
  Widget map(){
    return Container(
      margin: EdgeInsets.all(10),
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
      child:GoogleMap(
        markers: {
          Marker(markerId: MarkerId("place location"),
            position: LatLng(widget.lat, widget.lng),
            infoWindow: InfoWindow(title: widget.name),
            // icon: BitmapDescriptor.defaultMarkerWithHue(
            //     BitmapDescriptor.hueOrange),
            onTap: (){
              gmc!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(  widget.lat ,widget.lng), 16));
            },
          )
        },
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.lat, widget.lng),
          zoom: 16,
        ),
        onMapCreated: (GoogleMapController controller) {
          //controller.setMapStyle(utils.mapsStyle);
          gmc = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );

  }
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
        padding: const EdgeInsets.only(top:15.0),
        child: Text(
          "Location",
          style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}


// class utils {
//   static String mapsStyle = '''
//   [
//   {
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#242f3e"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#746855"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.text.stroke",
//     "stylers": [
//       {
//         "color": "#242f3e"
//       }
//     ]
//   },
//   {
//     "featureType": "administrative.locality",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#d59563"
//       }
//     ]
//   },
//   {
//     "featureType": "poi",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#d59563"
//       }
//     ]
//   },
//   {
//     "featureType": "poi.park",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#263c3f"
//       }
//     ]
//   },
//   {
//     "featureType": "poi.park",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#6b9a76"
//       }
//     ]
//   },
//   {
//     "featureType": "road",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#38414e"
//       }
//     ]
//   },
//   {
//     "featureType": "road",
//     "elementType": "geometry.stroke",
//     "stylers": [
//       {
//         "color": "#212a37"
//       }
//     ]
//   },
//   {
//     "featureType": "road",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9ca5b3"
//       }
//     ]
//   },
//   {
//     "featureType": "road.highway",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#746855"
//       }
//     ]
//   },
//   {
//     "featureType": "road.highway",
//     "elementType": "geometry.stroke",
//     "stylers": [
//       {
//         "color": "#1f2835"
//       }
//     ]
//   },
//   {
//     "featureType": "road.highway",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#f3d19c"
//       }
//     ]
//   },
//   {
//     "featureType": "transit",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#2f3948"
//       }
//     ]
//   },
//   {
//     "featureType": "transit.station",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#d59563"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#17263c"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#515c6d"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "labels.text.stroke",
//     "stylers": [
//       {
//         "color": "#17263c"
//       }
//     ]
//   }
// ]
//    ''';
// }