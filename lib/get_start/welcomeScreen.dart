import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'getStarted.dart';

class welcomeScreen extends StatefulWidget {
  const welcomeScreen({Key? key}) : super(key: key);

  @override
  State<welcomeScreen> createState() => _welcomeScreenState();
}

class _welcomeScreenState extends State<welcomeScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFF0DE),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_WS.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset("assets/Logo.png", height: 106, width: 232),
                  Text(
                    "Build Your Egyptian Adventure",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff252525),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => getStarted()),
                  );
                },
                foregroundColor: HexColor("#ffffff"),
                backgroundColor: HexColor("#935B36"),
                elevation: 0,
                child: Icon(
                  Icons.arrow_downward,
                  size: 30,
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
