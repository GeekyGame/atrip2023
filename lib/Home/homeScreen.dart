import 'package:atrip/Home/trips/displayItinerary.dart';
import 'package:atrip/Home/userMenu/user_menu.dart';
import 'package:atrip/Home/viewCategory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../component/places_class.dart';
import '../get_start/SplashScreen.dart';
import 'trips/createAtrip.dart';


class homeScreen extends StatefulWidget {
  const homeScreen({Key? key}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreen();
}

class _homeScreen extends State<homeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<PlaceView> ongoingList = [] ;
  List<PlaceView> pastList = [];
  bool flg = false;

  getData() async {
    print("++++++++++++++++++++++++++++++++++++++++++++++");
    var uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final ItineraryCollection = userDoc.reference.collection('itineraries');

      final ongoingDocs = await ItineraryCollection.where('state' ,isEqualTo: 'ongoing').get();
      final pastDocs = await ItineraryCollection.where('state' ,isEqualTo: 'past').get();

      for (final doc in ongoingDocs.docs) {
        print("Hello1");
        final data = doc.data();

        GeoPoint location = data['location'];
        double latitude = location.latitude;
        double longitude = location.longitude;

        var placeView = PlaceView(
          Fireid: doc.id,
          lat: latitude,
          lng: longitude,
          places: data['attractions']
              .map<Place>((attraction) => Place(
            id: attraction['id'],
            name: attraction['name'],
            lat: attraction['lat'],
            lng: attraction['lng'],
            photoUrl: attraction['photoUrl'],
            types: List<String>.from(attraction['types']),
            rating: attraction['rating'],
            description: attraction['description'],
            cost: attraction['cost'],
            workHour: attraction['workHour'],
            isOpen: attraction['isOpen'],
          ))
              .toList(),
          Restaurants: data['Restaurants']
              .map<Place>((Restaurants) => Place(
            id: Restaurants['id'],
            name: Restaurants['name'],
            lat: Restaurants['lat'],
            lng: Restaurants['lng'],
            photoUrl: Restaurants['photoUrl'],
            types: List<String>.from(Restaurants['types']),
            rating: Restaurants['rating'],
            description: Restaurants['description'],
            cost: Restaurants['cost'],
            workHour: Restaurants['workHour'],
            isOpen: Restaurants['isOpen'],
          ))
              .toList(),
          cityName: data['cityName'],
          imgUrl: data['imgUrl'],
          days: data['days'],
          Ppd: data['Ppd'],
          state: data['state'],
          prefList: data['prefList'],
        );

        setState(() {
          ongoingList.add(placeView);
        });
      }

      for (final doc in pastDocs.docs) {
        print("Hello2");
        final data = doc.data();

        GeoPoint location = data['location'];
        double latitude = location.latitude;
        double longitude = location.longitude;

        var placeView = PlaceView(
          Fireid: doc.id,
          lat: latitude,
          lng: longitude,
          places: data['attractions']
              .map<Place>((attraction) => Place(
            id: attraction['id'],
            name: attraction['name'],
            lat: attraction['lat'],
            lng: attraction['lng'],
            photoUrl: attraction['photoUrl'],
            types: List<String>.from(attraction['types']),
            rating: attraction['rating'],
            description: attraction['description'],
            cost: attraction['cost'],
            workHour: attraction['workHour'],
            isOpen: attraction['isOpen'],
          ))
              .toList(),
          Restaurants: data['Restaurants']
              .map<Place>((Restaurants) => Place(
            id: Restaurants['id'],
            name: Restaurants['name'],
            lat: Restaurants['lat'],
            lng: Restaurants['lng'],
            photoUrl: Restaurants['photoUrl'],
            types: List<String>.from(Restaurants['types']),
            rating: Restaurants['rating'],
            description: Restaurants['description'],
            cost: Restaurants['cost'],
            workHour: Restaurants['workHour'],
            isOpen: Restaurants['isOpen'],
          ))
              .toList(),
          cityName: data['cityName'],
          imgUrl: data['imgUrl'],
          days: data['days'],
          Ppd: data['Ppd'],
          state: data['state'],
          prefList: data['prefList'],
        );

        setState(() {
          pastList.add(placeView);
        });
      }
      print("length : ${ongoingList.length}");
      setState(() {
        flg = true;
      });
    } catch (e) {
      // Handle any potential errors
      print('Error retrieving rearranged places: $e');
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void _navigateToAnotherPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Splash()),
    );
  }

  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
        drawer: user_menu(),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        child:Center(child: Image(image: AssetImage("assets/icons/map-travel.png"), height: 30,color: Colors.white,)),
        onPressed: ()  {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => createAtrip(),
            ),
          );
        },
        backgroundColor: Colors.deepOrange,
      ),
      body: SafeArea(child:
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/sky2.png"),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed:() {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    SizedBox(width: 10,),
                    Text("aTrip",
                      style: new TextStyle(
                          color: Colors.black,
                          fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_outlined,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed:() {
                    _navigateToAnotherPage();
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            Text("Adventures",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff252525),
                )),
            SizedBox( height: 30),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Ongoing",
                            style: TextStyle(color:Colors.black54,fontSize: 18, fontWeight: FontWeight.w500)
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (builder)=>viewCategory(list: ongoingList, name:'onGoing')));
                          },
                          child: Text("See All",
                              style: TextStyle(fontSize: 14, decoration: TextDecoration.underline, color: Color(0xff935B36))
                          ),
                        ),

                      ],
                    ),
                  ),
                  SizedBox( height: 5),
                  Expanded(
                    child:
                    !flg ?
                    Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepOrange,)):
                    ongoingList.length >0 ?
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ongoingList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var place = ongoingList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 20),
                          child: InkWell(
                            onTap: () async {
                              Navigator.push(context, MaterialPageRoute(builder: (builder) => displayItinerary(
                                rearrangedPlaces: place.places,
                                Restaurants: place.Restaurants,
                                cityName: place.cityName,
                                days: place.days,
                                Ppd: place.Ppd,
                                lat: place.lat,
                                lng: place.lng,
                                id: place.Fireid,
                                state: place.state,
                                isEgypt: isInEgypt(place.lat, place.lng),
                              )));
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 170,
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
                                      place.imgUrl,
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
                                Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: Container(
                                        padding: EdgeInsets.all(4),
                                        height: 50,
                                        width: 170,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft:Radius.circular(10) ),

                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("City: ${place.cityName}",style: TextStyle(color: Colors.white),maxLines: 1,overflow: TextOverflow.ellipsis),
                                            Text("days: ${place.days}",style: TextStyle(color: Colors.white),),

                                          ],
                                        )))
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        :Center(child: Text("You haven't made any trips yet\nPlease reload the page to show itineraries if found",textAlign: TextAlign.center,)),
                  ),
                ],
              ),
            ),
            SizedBox( height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Divider(thickness: 2),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Past",
                            style: TextStyle(color:Colors.black54,fontSize: 18, fontWeight: FontWeight.w500)
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (builder)=>viewCategory(list: pastList, name:'Past')));
                          },
                          child: Text("See All",
                              style: TextStyle(fontSize: 14, decoration: TextDecoration.underline, color: Color(0xff935B36))
                          ),
                        ),

                      ],
                    ),
                  ),
                  Expanded(
                    child: !flg ?
                    Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepOrange,)):
                    pastList.length >0 ?
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pastList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var place = pastList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 20),
                          child: InkWell(
                            onTap: () async {
                              Navigator.push(context, MaterialPageRoute(builder: (builder) => displayItinerary(
                                rearrangedPlaces: place.places,
                                Restaurants: place.Restaurants,
                                cityName: place.cityName,
                                days: place.days,
                                Ppd: place.Ppd,
                                lat: place.lat,
                                lng: place.lng,
                                id: place.Fireid,
                                state: place.state,
                                isEgypt: isInEgypt(place.lat, place.lng),
                              )));
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 170,
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
                                      place.imgUrl,
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
                                Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: Container(
                                        padding: EdgeInsets.all(4),
                                        height: 50,
                                        width: 170,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft:Radius.circular(10) ),

                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("City: ${place.cityName}",style: TextStyle(color: Colors.white),maxLines: 1,overflow: TextOverflow.ellipsis),
                                            Text("days: ${place.days}",style: TextStyle(color: Colors.white),),

                                          ],
                                        )))
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        :Center(child: Text("You haven't made any trips yet\nPlease reload the page to show itineraries if found",textAlign: TextAlign.center,),),
                  ),
                ],
              ),
            ),
            SizedBox( height: 30),

          ],
        ),
        )
      )

    );
  }
}


class PlaceView {
  final  Fireid;
  final  lat;
  final  lng;
  final  places;
  final  cityName;
  final  imgUrl;
  final  days;
  final  Ppd;
  final state;
  final prefList;
  final Restaurants;

  PlaceView({
    this.Fireid,
    this.lat,
    this.lng,
    this.places,
    this.cityName,
    this.imgUrl,
    this.days,
    this.Ppd,
    this.state,
    this.prefList,
    this. Restaurants
  });
}
