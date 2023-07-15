/*
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../component/loading.dart';
import 'generateItinerary.dart';
import 'locate_location.dart';


var API_KEY = "AIzaSyB8eEZ9nyPWA_5cTHm1_ADp0SP0ZvG4Xzw";

class createAtrip extends StatefulWidget {
  final current;
  final locate;
  final LAT;
  final LNG;
  final cityName;
  const createAtrip({Key? key, this.current, this.locate, this.LAT, this.LNG, this.cityName})
      : super(key: key);

  @override
  State<createAtrip> createState() => _createAtripState();
}

class _createAtripState extends State<createAtrip> {

  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _location;
  var cityName;
  var LAT;
  var LNG;
  bool current = false;
  bool locate = false;
  bool bg1 = false;
  bool bg2 = false;
  bool bg3 = false;
  bool T1 = false;
  bool T2 = false;
  bool T3 = false;
  bool T4 = false;
  bool T5 = false;
  bool E1 = false;
  bool E2 = false;
  bool E3 = false;

  var DOF_check = "";

  var mm = [
    '1',
    '2',
    '3',
    '4',
    '5'
  ];
  var tr = [
    'Friends',
    'Family',
    'Couple',
    'Alone',
  ];
  var icons = [
    Image(image: AssetImage("assets/icons/friends.png"), width: 25),
    Icon(Icons.family_restroom),
    Icon(Icons.people),
    Icon(Icons.person),
  ];
  var dropdownvalue_mm;
  var dropdownvalue_tr;
  TextEditingController _Dayscontroller = TextEditingController();
  bool isDays = false;
  Color _textFieldColor = Colors.black;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dropdownvalue_mm = mm[2];
    dropdownvalue_tr = tr[0];

    LAT = widget.LAT != null ? widget.LAT : "";
    LNG = widget.LNG != null ? widget.LNG : "";
    if(LAT != "" && LNG != ""){
      setState(() {
        E1 = false;
      });
    }
    cityName = widget.cityName;
    current = widget.current != null ? widget.current : false;
    locate = widget.locate != null ? widget.locate : false;
  }

  Future<void> checkAndSaveLocationServices(context) async {
    showLoading(context);
    Location location = new Location();

    _serviceEnabled = await location.serviceEnabled();

    if (_serviceEnabled) {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        GetAndSaveUserLocation();
      } else {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted == PermissionStatus.granted) {
          GetAndSaveUserLocation();
        }
      }
    } else {
      _serviceEnabled = await location.requestService();
      if (_serviceEnabled) {
        _permissionGranted = await location.hasPermission();
        if (_permissionGranted == PermissionStatus.granted) {
          GetAndSaveUserLocation();
        } else {
          _permissionGranted = await location.requestPermission();
          if (_permissionGranted == PermissionStatus.granted) {
            GetAndSaveUserLocation();
          }
        }
      }
    }
  }

  GetAndSaveUserLocation() async {
    Location location = new Location();

    _location = await location.getLocation().then((_location) async {
      var ls = await getCityAndCountry(_location.latitude!,_location.longitude!);
      if(ls[0] != ''){
        setState(()  {
          cityName= ls[0];
        });
      }
      setState(() {
        LAT = _location.latitude!;
        LNG = _location.longitude!;
      });
      setState(() {
        current = true;
        locate = false;
        E1 = false;
      });
      Navigator.of(context).pop();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     print("$LAT, $LNG");
      //   },
      // ),
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: _buildappbar(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Start Location:',
                      style: new TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 15),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () async {
                              checkAndSaveLocationServices(context);
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: current
                                      ? Colors.deepOrange
                                      : Colors.white,
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
                                child: Row(
                                  children: [
                                    Text(
                                      'current location',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: !current
                                            ? Colors.deepOrange
                                            : Colors.white,
                                      ),
                                    ),
                                    current
                                        ? Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      ],
                                    )
                                        : Container()
                                  ],
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (context) => locate_location(
                                      late: 30.050488715547054,
                                      long: 31.230264981056525,
                                    ),
                                  ));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color:
                                locate ? Colors.deepOrange : Colors.white,
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
                              child: Row(
                                children: [
                                  Text(
                                    'locate on map',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: !locate
                                          ? Colors.deepOrange
                                          : Colors.white,
                                    ),
                                  ),
                                  locate
                                      ? Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    ],
                                  )
                                      : Container()
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    locate || current
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          '* Location Located',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    )
                        : Container(),
                    E1 ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          '* Pleaase Locate yor Trip Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                        : Container()
                  ],
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Divider(thickness: 2),
                ),
                SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Time Management:',
                      style: new TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 25),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Trip Duration:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 15),
                            Container(
                              height: 40,
                              width: 80,
                              margin: EdgeInsets.only(left: 5, right: 5),
                              padding: EdgeInsets.symmetric(vertical: 6.0,horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: HexColor('#80858E'),
                                ),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _Dayscontroller,
                                  onChanged: (value) {
                                    if (int.tryParse(value) == null || !(1 <= int.parse(value) && int.parse(value) <= 21)) {
                                      // Value is not a number between 1 and 21
                                      setState(() {
                                        _textFieldColor = Colors.red;
                                        isDays = false;
                                      });
                                    } else {
                                      // Value is a number between 1 and 21
                                      setState(() {
                                        _textFieldColor = Colors.black;
                                        isDays = true;
                                      });
                                    }
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(color: _textFieldColor),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(width: 5),
                                Text('day(s)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    )),
                                SizedBox(width: 15),
                                !isDays ? Text('Max days: 21',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    )):Container(),
                              ],
                            ),

                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Text(
                              'Places / Day:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 18),
                            Container(
                              height: 40,
                              width: 80,
                              margin: EdgeInsets.only(left: 5, right: 5),
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: HexColor('#80858E'),
                                ),
                              ),
                              child: DropdownButton(
                                isExpanded: true,
                                underline: SizedBox(),
                                value: dropdownvalue_mm,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: mm.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (newValue) {
                                  setState(() {
                                    dropdownvalue_mm = newValue!;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 5),
                            Text('place(s)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Divider(thickness: 2),
                ),
                SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Who are you travelling with ?',
                      style: new TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 25),
                    Container(
                      height: 40,
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 5, right: 5),
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: HexColor('#80858E'),
                        ),
                      ),
                      child: DropdownButton(
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                        isExpanded: true,
                        underline: SizedBox(),
                        value: dropdownvalue_tr,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        iconSize: 30,
                        items: tr.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Row(
                              children: [
                                icons[tr.indexOf(items)],
                                SizedBox(
                                  width: 10,
                                ),
                                Text(items),
                              ],
                            ),
                          );
                        }).toList(),
                        // After selecting the desired option,it will
                        // change button value to selected value
                        onChanged: (newValue) {
                          setState(() {
                            dropdownvalue_tr = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Divider(thickness: 2),
                ),
                SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'choose your trip preferences:',
                      style: new TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 25),
                    Container(
                      height: 150,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap:(){
                                  setState(() {
                                    T1 = !T1;
                                    E2 = false;
                                  });
                                },
                                child: Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.deepOrange),
                                  ),
                                  child: T1 ?Center(
                                      child: Text(
                                        String.fromCharCode(Icons.check.codePoint),
                                        style: TextStyle(
                                          fontFamily: Icons.check.fontFamily,
                                          package: Icons.check.fontPackage,
                                          color: Colors.deepOrange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))
                                      :Container(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Cultural Tourism",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap:(){
                                  setState(() {
                                    T2 = !T2;
                                    E2 = false;
                                  });
                                },
                                child: Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.deepOrange),
                                  ),
                                  child: T2 ?Center(
                                      child: Text(
                                        String.fromCharCode(Icons.check.codePoint),
                                        style: TextStyle(
                                          fontFamily: Icons.check.fontFamily,
                                          package: Icons.check.fontPackage,
                                          color: Colors.deepOrange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))
                                      :Container(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Medical Tourism",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap:(){
                                  setState(() {
                                    T3 = !T3;
                                    E2 = false;
                                  });
                                },
                                child: Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.deepOrange),
                                  ),
                                  child: T3 ?Center(
                                      child: Text(
                                        String.fromCharCode(Icons.check.codePoint),
                                        style: TextStyle(
                                          fontFamily: Icons.check.fontFamily,
                                          package: Icons.check.fontPackage,
                                          color: Colors.deepOrange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))
                                      :Container(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Religious Tourism",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap:(){
                                  setState(() {
                                    T4 = !T4;
                                    E2 = false;
                                  });
                                },
                                child: Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.deepOrange),
                                  ),
                                  child: T4 ?Center(
                                      child: Text(
                                        String.fromCharCode(Icons.check.codePoint),
                                        style: TextStyle(
                                          fontFamily: Icons.check.fontFamily,
                                          package: Icons.check.fontPackage,
                                          color: Colors.deepOrange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))
                                      :Container(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Recreational Tourism",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap:(){
                                  setState(() {
                                    T5 = !T5;
                                    E2 = false;
                                  });
                                },
                                child: Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.deepOrange),
                                  ),
                                  child: T5 ?Center(
                                      child: Text(
                                        String.fromCharCode(Icons.check.codePoint),
                                        style: TextStyle(
                                          fontFamily: Icons.check.fontFamily,
                                          package: Icons.check.fontPackage,
                                          color: Colors.deepOrange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))
                                      :Container(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Row(
                                children: [
                                  Text(
                                    "Others",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "(Related to trip country)",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    E2 ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          '* Please Select 1 type at least',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                        : Container()
                  ],
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Divider(thickness: 2),
                ),
                SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Budget:',
                      style: new TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 25),
                    Wrap(
                      runSpacing: 10,
                      spacing: 15,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              bg1 = true;
                              bg2 = false;
                              bg3 = false;
                              E3 = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: bg1 ? Colors.deepOrange : Colors.white,
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
                            child: Text(
                              "Economy \$",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: !bg1 ? Colors.deepOrange : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              bg1 = false;
                              bg2 = true;
                              bg3 = false;
                              E3 = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: bg2 ? Colors.deepOrange : Colors.white,
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
                            child: Text(
                              "Normal \$\$",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: !bg2 ? Colors.deepOrange : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              bg1 = false;
                              bg2 = false;
                              bg3 = true;
                              E3 = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: bg3 ? Colors.deepOrange : Colors.white,
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
                            child: Text(
                              "Luxury \$\$\$",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: !bg3 ? Colors.deepOrange : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    E3 ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          '* Please Choose Your Budget',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                        : Container()
                  ],
                ),
                SizedBox(height: 40),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [HexColor("#f5d3a5"), HexColor("#7a4f25")],
                      ),
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(2, 5), // changes position of shadow
                        ),
                      ],
                    ),
                    width: 200,
                    height: 45,
                    child: TextButton(
                      onPressed: () async {
                        _checkData();
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                      ),
                      child: Text(
                        'Generate Itinerary',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  _checkData() async {
    var flg1 = false;
    var flg2 = false;
    var flg3 = false;

    var prefList = [];
    var filteredList = [];
    var cost ;
    if(cityName != null){
      setState(() {
        E1 = false;
        flg1 = true;
      });
    }
    else{
      setState(() {
        E1 = true;
        flg1 = false;
      });
    }
    if (T1 || T2 || T3 || T4 || T5){
      setState(() {
        E2 = false;
        flg2 = true;
      });
      prefList = [
        T1 ? 'Cultural Tourism':'',
        T2 ? 'Medical Tourism':'',
        T3 ? 'Religious Tourism':'',
        T4 ? 'Recreational Tourism':'',
        T5 ? 'Others':'',
      ];
      filteredList = prefList.where((element) => element.isNotEmpty).toList();

    }
    else{
      setState(() {
        E2 = true;
        flg2 = false;
      });
    }
    if(bg1 || bg2 || bg3){
      setState(() {
        E3 = false;
        flg3 = true;
      });
      cost = bg1 ? "Economy": bg2 ? "Normal" :bg3 ? "Luxury" : "" ;
    }
    else{
      setState(() {
        E3 = true;
        flg3 = false;

      });
    }
    if(flg1 && flg2 && flg3 && isDays){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=> generateItinerary(lat: LAT,lng: LNG, cityName: cityName, prefList: filteredList,cost: cost, days: _Dayscontroller.text, PpD: dropdownvalue_mm,)));
    }else{
      const snackBar = const SnackBar(
          content: Text(
            'Please Check your choices',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
        padding: const EdgeInsets.only(top: 15.0),
        child: Text(
          "Create a new Trip",
          style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

*/
