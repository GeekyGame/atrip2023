import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

showLoading(context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          title: Text("Please Wait"),
          content: Container(
              height: 50, child: Center(child: CircularProgressIndicator(color: Colors.deepOrange,))),
        );
      });
}


