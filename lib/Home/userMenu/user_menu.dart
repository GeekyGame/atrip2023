
import 'package:atrip/get_start/signIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../get_start/signUp.dart';
import '../../test.dart';
import '../MapScreen.dart';
import '../homeScreen.dart';
import '../trips/createAtrip.dart';
import 'account_setting.dart';


var Snapshot;
var FirstName;
var LastName;
var Email;
var ImgUrl;

class user_menu extends StatefulWidget {
  const user_menu({Key? key}) : super(key: key);

  @override
  State<user_menu> createState() => _user_menuState();
}

class _user_menuState extends State<user_menu> {

  var uid = FirebaseAuth.instance.currentUser!.uid;

  void initState() {
    _getdata();
  }

  FirebaseAuth instance = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.orange.shade100.withOpacity(.8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 40,
          ),
          ImgUrl != null ? Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex:5,
                  child: Container(
                    padding: EdgeInsets.all(8),

                    child:  CircleAvatar(
                      backgroundColor: HexColor('#FFFFFF'),
                      radius: 45.0,
                      child: ClipOval(
                        child: Image.network(
                          "$ImgUrl",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                color: HexColor("#131A5C"),
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
                ),
                SizedBox(width: 7),
                Expanded(
                  flex:7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Row(
                      children: [
                        Text("$FirstName "),
                        Text("$LastName"),
                      ],
                    ), Text("$Email")],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(right: 15),
                    child: CircleAvatar(
                      backgroundColor: HexColor("#F9F9F9"),
                      radius: 20.0,
                      child: ClipOval(
                        child: Icon(Icons.notifications_none_rounded,
                            color: HexColor("#374151")),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ): CircularProgressIndicator(color: HexColor("#131A5C"),),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 50,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: InkWell(
              onTap: () async {
                if(ImgUrl != null){
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => account_setting()),
                  );
                }
              },
              child: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.perm_identity_rounded,
                        color: HexColor("#374151")),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text("Account setting" ,
                        style: TextStyle(
                          color: HexColor('##374151'),
                          fontSize: 16,
                        )),
                  ),
                  Expanded(
                    child:
                    Icon(Icons.settings, size: 20, color: HexColor("#374151")),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => homeScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child:
                        Icon(Icons.home_outlined, color: HexColor("#374151")),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("Home",
                            style: TextStyle(
                              color: HexColor('#374151'),
                              fontSize: 16,
                            )),
                      ),
                      Expanded(
                        child: Icon(Icons.arrow_forward_ios_sharp,
                            size: 15, color: HexColor("#9CA3AF")),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: ()  {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => createAtrip(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child:
                        Image(image: AssetImage("assets/icons/map-travel.png"), height: 30)
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            "Generate Itinerary",
                            style: TextStyle(
                              color: HexColor('#374151'),
                              fontSize: 16,
                            )),
                      ),
                      Expanded(
                        child: Icon(Icons.arrow_forward_ios_sharp,
                            size: 15, color: HexColor("#9CA3AF")),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () async {
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScrollUpExample(),
                      ),
                    );*/
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Icon(Icons.device_unknown_sharp,
                            color: HexColor("#374151")),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("About us",
                            style: TextStyle(
                              color: HexColor('##374151'),
                              fontSize: 16,
                            )),
                      ),
                      Expanded(
                        child: Icon(Icons.arrow_forward_ios_sharp,
                            size: 15, color: HexColor("#9CA3AF")),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child:
                      Icon(Icons.privacy_tip, color: HexColor("#374151")),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Privacy Policy",
                          style: TextStyle(
                            color: HexColor('##374151'),
                            fontSize: 16,
                          )),
                    ),
                    Expanded(
                      child: Icon(Icons.arrow_forward_ios_sharp,
                          size: 15, color: HexColor("#9CA3AF")),
                    ),
                  ],
                ),


              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            decoration: BoxDecoration(
              color: HexColor("#BC2C2C"),
              borderRadius: BorderRadius.circular(15),
            ),
            width: 90,
            height: 35,
            child: new TextButton(
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () async {
                  instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => signIn()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.logout_sharp,size: 18,)
                  ],
                )),
          ),

        ]),
      ),
    );
  }

  _getdata() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((snapshot) {
      setState(() {
        FirstName = snapshot.data.call()!['first name'];
        LastName = snapshot.data.call()!['second name'];
        Email = snapshot.data.call()!['email'];
        ImgUrl = snapshot.data.call()!['image url'];
        //lang = snapshot.data.call()!['lang'];
      });
    });
  }
}
