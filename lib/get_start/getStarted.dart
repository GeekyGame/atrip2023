import 'package:atrip/get_start/signIn.dart';
import 'package:atrip/get_start/signUp.dart';
import 'package:flutter/material.dart';

class getStarted extends StatefulWidget {
  const getStarted({Key? key}) : super(key: key);

  @override
  State<getStarted> createState() => _getStarted();
}

class _getStarted extends State<getStarted> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_GS.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(),
            Container(),
            Column(
              children: [
                Text(
                  "Welcome to aTrip",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff252525),
                  ),
                ),
                Text(
                  "Your ultimate travel companion\nfor personalized adventures!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff252525),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff935B36),
                    onPrimary: Colors.white,
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  child: Text('Get Started!'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const signUp()),
                    );
                  },
                ),
                TextButton(
                  // <-- TextButton
                  style: ElevatedButton.styleFrom(
                    onPrimary: Color(0xff935B36),
                    textStyle: TextStyle(
                      fontSize: 20,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: Text('I already have an account'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const signIn()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
