import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class CustomMarker extends StatefulWidget {
  final LatLng position;

  const CustomMarker({required this.position});

  @override
  _CustomMarkerState createState() => _CustomMarkerState();
}

class _CustomMarkerState extends State<CustomMarker> {
  GlobalKey _markerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _markerKey,
      child: Container(
        color: Colors.transparent,
        child: YourCustomWidget(),
      ),
    );
  }

  Future<BitmapDescriptor> _createMarkerImage() async {
    RenderRepaintBoundary boundary = _markerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      Uint8List pngBytes = byteData.buffer.asUint8List();
      return BitmapDescriptor.fromBytes(pngBytes);
    } else {
      throw Exception('Failed to convert widget to marker icon.');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createMarkerImage().then((BitmapDescriptor icon) {
        Marker marker = Marker(
          markerId: MarkerId('customMarker'),
          position: widget.position,
          icon: icon,
        );

        // Add the marker to the map
        // GoogleMapController controller = ...
        // controller.addMarker(marker);
      });
    });
  }
}

class YourCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Customize your custom widget here
    return Container(
      width: 50,
      height: 50,
      color: Colors.blue,
      child: Center(
        child: Text(
          'Custom Marker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


class CustomMarkerWidget extends StatelessWidget {
  final String name;
  final String photoUrl;

  const CustomMarkerWidget({
    required this.name,
    required this.photoUrl,
  });

  Future<Uint8List> _getImageBytes() async {
    final response = await get(Uri.parse(photoUrl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return bytes;
    }
    return Uint8List(0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _getImageBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Image.memory(
                snapshot.data!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              Text(
                name,
                style: TextStyle(fontSize: 12),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}

class WidgetMarker extends StatelessWidget {
  final String title;

  WidgetMarker(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue, // Customize the marker color as needed
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white, // Customize the marker text color as needed
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}