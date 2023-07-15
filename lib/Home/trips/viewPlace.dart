import 'package:atrip/Home/trips/createAtrip.dart';
import 'package:atrip/Home/trips/place_location.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../component/ImageView.dart';
import '../../component/loading.dart';

class viewPlace extends StatefulWidget {
  final place;
  final cityName;
  const viewPlace({Key? key, required this.place, required this.cityName})
      : super(key: key);

  @override
  State<viewPlace> createState() => _viewPlaceState();
}

class _viewPlaceState extends State<viewPlace> {
  Map<String, dynamic>? placeDetails;
  List<String> photoUrls = [];
  var activeIndex = 0;
  var userRating = 0.0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    fetchPlacePhotos(widget.place.id);

    fetchPlaceDetails(widget.place.id)
        .then((data) => setState(() {
              placeDetails = data;
            }))
        .catchError((error) => print(error));
  }

  Future<Map<String, dynamic>> fetchPlaceDetails(String placeId) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$API_KEY';
    final response = await http.get(Uri.parse(apiUrl));
    print(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return data['result'];
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  Future<void> fetchPlacePhotos(String placeId) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=photos&key=$API_KEY';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final photos = data['result']['photos'] as List<dynamic>;
      photoUrls.add(widget.place.photoUrl);
      setState(() {
        photoUrls = photos.map((photo) {
          final photoReference = photo['photo_reference'] as String;
          final maxWidth = 400; // Set your desired max width for the photos
          return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$API_KEY';
        }).toList();
      });
    } else {
      throw Exception('Failed to fetch place photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return RatingDialog(placeId: widget.place.id,);
                  },
                );
              },
              child: Icon(
                Icons.star,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                            height: 250,
                            autoPlay: photoUrls.length > 1 ? true : false,
                            autoPlayInterval: Duration(seconds: 5),
                            pauseAutoPlayOnTouch: true,
                            pauseAutoPlayOnManualNavigate: true,
                            viewportFraction: 1,
                            enableInfiniteScroll:
                                photoUrls.length > 1 ? true : false,
                            enlargeCenterPage: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            onPageChanged: (index, reason) =>
                                setState(() => activeIndex = index),
                          ),
                          itemCount: photoUrls.length,
                          itemBuilder: (context, index, realIndex) {
                            final urlImage = photoUrls[index];
                            return buildimage(urlImage, index);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: buildIndicator()),
                ],
              ),
            ),
            Expanded(
                flex: 5,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: HexColor("FFF8E7"),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.place.name,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Rating (Past Visitors)",
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        placeRating(widget.place.rating),
                                        SizedBox(width: 10),
                                        Text(
                                          widget.place.rating
                                              .toStringAsFixed(1),
                                          style: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: widget.place.isOpen == null
                                    ? Colors.grey
                                    : widget.place.isOpen
                                        ? Colors.green
                                        : Colors.red),
                            child: Text(
                              widget.place.isOpen == null
                                  ? "Unavailable"
                                  : widget.place.isOpen
                                      ? "Open"
                                      : "Currently Close",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        child: Container(
                          child: placeDetails != null
                              ? ListView(
                                  padding: EdgeInsets.all(10.0),
                                  children: [
                                    Text(
                                      'Address:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(placeDetails!['formatted_address'] ??
                                        'N/A'),
                                    SizedBox(height: 20.0),
                                    Text(
                                      'Phone Number:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(placeDetails![
                                            'formatted_phone_number'] ??
                                        'N/A'),
                                    SizedBox(height: 20.0),
                                    Text(
                                      'Opening Hours:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      placeDetails!['opening_hours'] != null
                                          ? placeDetails!['opening_hours']
                                                  ['weekday_text']
                                              .join('\n')
                                          : 'N/A',
                                      style: TextStyle(
                                          color:
                                              placeDetails!['opening_hours'] !=
                                                      null
                                                  ? Colors.black54
                                                  : Colors.black),
                                    ),
                                    SizedBox(height: 20.0),
                                    Text(
                                      'Price Level:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      placeDetails!['price_level'] != null
                                          ? '${placeDetails!['price_level']}'
                                          : 'N/A',
                                    ),
                                  ],
                                )
                              : Center(
                                  child: CircularProgressIndicator(
                                  color: Colors.deepOrange,
                                )),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 80),
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
          height: 40,
          child: new TextButton(
              style: TextButton.styleFrom(primary: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => ViewLocation(
                              lat: widget.place.lat,
                              lng: widget.place.lng,
                              name: widget.place.name,
                            )));
              },
              child: Text(
                'Get Location',
                style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              )),
        ),
      ),
    );
  }

  Widget placeRating(double rating) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 20,
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

  Widget buildIndicator() {
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: photoUrls.length,
      effect: SlideEffect(
        dotWidth: 12,
        dotHeight: 12,
        activeDotColor: HexColor('#E2824E'),
        dotColor: HexColor('#D9D9D9'),
      ),
    );
  }

  Widget buildimage(String urlImage, int index) {
    return InkWell(
      onTap: () async {
        await showDialog(
            context: context, builder: (_) => ImageDialog(img: urlImage));
      },
      child: Stack(
        children: [
          Center(
            child: CircularProgressIndicator(
              color: HexColor('#FAB916'),
            ),
          ),
          Center(
            child: Container(
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
                  urlImage,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: HexColor('#FAB916'),
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
        ],
      ),
    );
  }
}


class RatingDialog extends StatefulWidget {
  final placeId;

  const RatingDialog({super.key, required this.placeId});
  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double userRating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate the place'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: RatingBar.builder(
              initialRating: userRating,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemSize: 35,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  userRating = rating;
                });
              },
            ),
          ),
          SizedBox(height: 10,),
          Text("Rating: $userRating")
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () async {
            var uid = FirebaseAuth.instance.currentUser!.uid;
            var placeId = widget.placeId;

            try {
              showLoading(context);

              // Check if the user has already rated the place
              final querySnapshot = await FirebaseFirestore.instance
                  .collection('ratings')
                  .where('userId', isEqualTo: uid)
                  .where('placeId', isEqualTo: placeId)
                  .get();

              if (querySnapshot.docs.isNotEmpty) {
                // User has already rated this place
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                final snackBar = SnackBar(
                  content: Text(
                    'You have already rated this place',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: HexColor('#555555'),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              // User has not rated this place before, proceed to save the rating
              final ratingData = {
                'userId': uid,
                'placeId': placeId,
                'rating': userRating,
              };

              await FirebaseFirestore.instance.collection('ratings').add(ratingData);

              Navigator.of(context).pop();
              Navigator.of(context).pop();

              final snackBar = SnackBar(
                content: Text(
                  'Rating saved successfully',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: HexColor('#555555'),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              print('Rating saved successfully.');
            } catch (e) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              final snackBar = SnackBar(
                content: Text(
                  'Failed to save rating',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: HexColor('#555555'),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              print('Failed to save rating: $e');
            }
          },
        ),
      ],
    );
  }
}
