import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:location/location.dart';
import 'Credentials.dart';
import 'package:http/http.dart' as http;
import 'package:random_color/random_color.dart';
import 'TempScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool theme;
  var results;
  bool isLoaded = false;
  List places;
  SharedPreferences prefs;

  initState() {
    super.initState();
    this.getTheme();
    this.getLocation();
  }

  getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = (prefs.getBool('theme') ?? true);

    setState(() {
      switch (theme) {
        case true:
          MyHomePage.backgroundColor = Color.fromRGBO(0x5c, 0xdb, 0x95, 1.0);
          MyHomePage.darkBackgroundColor =
              Color.fromRGBO(0x1b, 0xb6, 0x5f, 1.0);
          MyHomePage.accentColor = Color.fromRGBO(0x05, 0x38, 0x6b, 1);
          break;
        case false:
          MyHomePage.backgroundColor = Color.fromRGBO(0x82, 0x82, 0x82, 1.0);
          MyHomePage.darkBackgroundColor =
              Color.fromRGBO(0x41, 0x41, 0x41, 1.0);
          MyHomePage.accentColor = Colors.lightBlue;
          break;
      }
    });
  }

  getData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      places = prefs.getStringList('places') ?? List<String>();
    });
  }

  getLocation() async {
    Location location = Location();
    var position;
    String url;
    String place;

    await getData();

    try {
      position = await location.getLocation();
      url =
          "https://api.opencagedata.com/geocode/v1/json?q=${position.latitude}+${position.longitude}&key=${Credentials.geokey}";
      var res = await http
          .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});
      setState(() {
        results = jsonDecode(res.body) as Map<String, dynamic>;
        isLoaded = true;
      });
      bool found = false;
      for (int i = 0; i < places.length; i++) {
        String item = places[i];
        if (item.split("/")[0] == results["results"][0]["components"]["city"]) {
          String temp = places[0];
          places[0] = places[i];
          places[i] = temp;
          found = true;
          break;
        }
      }
      if (!found) {
        setState(() {
          places.add(
              "${results["results"][0]["components"]["city"]}/${position.latitude}/${position.longitude}");
        });
        prefs.setStringList('places', places);
      }
      print(places);
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
    print(results["results"][0]["components"]);
  }



  mainScreen() => Scaffold(
      appBar: AppBar(
        backgroundColor: MyHomePage.darkBackgroundColor,
        title: Text("Weather"),
        //leading: Container(),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) => builder(context, index),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                backgroundColor: MyHomePage.accentColor,
                child: Icon(Icons.add),
              ),
            ),
          )
        ],
      ),
      backgroundColor: MyHomePage.backgroundColor);

  Widget builder(context, index) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    RandomColor _randomColor = RandomColor();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage(places[index])),
          );
        },
        child: Container(
            width: _width,
            height: _height / 10,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: _randomColor.randomColor(
                    colorHue: ColorHue.blue,
                    colorSaturation: ColorSaturation.lowSaturation),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(5, 5))
                ]),
            child: Center(
                child: Text(
              places[index].split("/")[0],
              style: TextStyle(color: Colors.white, fontSize: 20),
            ))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded ? mainScreen() : TempScreen();
  }
}
