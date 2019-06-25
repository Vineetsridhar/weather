import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool theme;
  List places;

  initState(){
    super.initState();
    this.getTheme();
  }

  getTheme() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = (prefs.getBool('theme') ?? true);
    places = prefs.getStringList("places");

    setState(() {
      switch (theme) {
        case true:
          MyHomePage.backgroundColor = Color.fromRGBO(0x5c, 0xdb, 0x95, 1.0);
          MyHomePage.darkBackgroundColor = Color.fromRGBO(0x1b, 0xb6, 0x5f, 1.0);
          MyHomePage.accentColor = Color.fromRGBO(0x05, 0x38, 0x6b, 1);
          break;
        case false:
          MyHomePage.backgroundColor = Color.fromRGBO(0x82, 0x82, 0x82, 1.0);
          MyHomePage.darkBackgroundColor = Color.fromRGBO(0x41, 0x41, 0x41, 1.0);
          MyHomePage.accentColor = Colors.lightBlue;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyHomePage.darkBackgroundColor,
          title: Text("Weather"),
          //leading: Container(),
        ),
        body:Text("Add Places"),
        //TODO add new places functionality
        backgroundColor: MyHomePage.backgroundColor);
        
  }
}
