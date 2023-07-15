import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:atrip/get_start/welcomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../Home/homeScreen.dart';



class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenFunction(
      splash: 'assets/Logo.png',
      screenFunction: () async {
        String? value;
        final User? user = _firebaseAuth.currentUser;

        if (user != null) {
          return homeScreen();
        }

        return welcomeScreen();
      },
      backgroundColor: HexColor('#ffffff'),
      splashTransition: SplashTransition.scaleTransition,
    );
  }
}
