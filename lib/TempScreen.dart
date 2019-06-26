import 'package:flutter/material.dart';
import 'main.dart';

class TempScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return tempScreen();
  }

  Widget tempScreen() {
    return (Scaffold(
      backgroundColor: MyHomePage.backgroundColor,
      body: Center(
        child: Text(
          "Loading...",
          style: TextStyle(
              color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
        ),
      ),
    ));
  }

}