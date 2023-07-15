import 'package:atrip/Home/trips/displayItinerary.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';


class viewCategory extends StatefulWidget {
  final list;
  final name;
  const viewCategory({Key? key, required this.list, required this.name}) : super(key: key);

  @override
  State<viewCategory> createState() => _viewCategoryState();
}

class _viewCategoryState extends State<viewCategory> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: _buildappbar(name: widget.name),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.list.length,
        itemBuilder: (BuildContext context, int index) {
          var place = widget.list[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
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
              child:Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: HexColor('#EEEEEE'),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child:Container(
                        margin: EdgeInsets.all(8),
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
                            place.imgUrl,                                        fit: BoxFit.cover,
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
                      width: 20,
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Flexible(
                            child: Text(
                                place.cityName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Flexible(
                            child: Text(
                                "Days: ${place.days}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Flexible(
                            child: Text(
                                "Places per Day: ${place.Ppd}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                                'preferences:\n${place.prefList.map((item) => '$item').join(', ')}',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,

                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class _buildappbar extends StatelessWidget {
  final name;

  const _buildappbar({super.key, required this.name});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
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
              colors: [HexColor("#f5d3a5"), HexColor("#D3AC78"), HexColor("#AC7428")],
            ),
            borderRadius: new BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0))),
      ),
      title: Text(
        name,
        style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
      ),
    );
  }
}
