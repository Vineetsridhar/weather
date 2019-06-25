import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'Credentials.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Raleway'),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  static Color accentColor = Color.fromRGBO(0x05, 0x38, 0x6b, 1);
  static Color mainColor = Colors.white;
  static Color darkBackgroundColor = Color.fromRGBO(0x1b, 0xb6, 0x5F, 1.0);
  static Color backgroundColor = Color.fromRGBO(0x5c, 0xdb, 0x95, 1.0);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var weather;
  List daysList;
  bool gotData = false;
  bool theme;

  

  static bool unit;
  String url =
      "https://api.darksky.net/forecast/${Credentials.key}/40.527512,-74.310310";

  @override
  void initState() {
    super.initState();
    this.getTheme();
    this.getWeatherData();
  }

  _onBackPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  getTheme() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = (prefs.getBool('theme') ?? true);
    setState(() {
     switch(theme){
        case true:
          MyHomePage.backgroundColor = Color.fromRGBO(0x5c, 0xdb, 0x95, 1.0);
          MyHomePage.darkBackgroundColor = Color.fromRGBO(0x1b, 0xb6, 0x5F, 1.0);
          MyHomePage.accentColor = Color.fromRGBO(0x05, 0x38, 0x6b, 1);
          break;
        case false:
          MyHomePage.backgroundColor= Color.fromRGBO(0x82, 0x82, 0x82, 1.0);
          MyHomePage.darkBackgroundColor = Color.fromRGBO(0x41, 0x41, 0x41, 1.0);
          MyHomePage.accentColor = Colors.lightBlue;
          break;
      } 
    });
  }

  getWeatherData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      unit = prefs.getBool('units') ?? true;
      url += (unit ? "" : "?units=si");
    });
    var res = await http
        .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});

    setState(() {
      Map<String, dynamic> weather =
          jsonDecode(res.body) as Map<String, dynamic>;
      this.weather = weather;
      daysList = weather["daily"]["data"];
      gotData = true;
    });
  }

  Widget builder(BuildContext context, int index) {
    index += 1;
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    DateTime day =
        DateTime.fromMillisecondsSinceEpoch(daysList[index]["time"] * 1000);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
                width: _width / 4,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        getDay(day.weekday),
                        style: TextStyle(
                            fontSize: _width * 0.035, color: MyHomePage.mainColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: Text(
                        "${day.month}/${day.day}",
                        style: TextStyle(
                            fontSize: _width * 0.035, color: MyHomePage.mainColor),
                      ),
                    ),
                    Container(
                      height: _height * 0.1,
                      child: Image.asset(
                          "assets/dark/${daysList[index]["icon"]}.png",
                          scale: 30),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "${daysList[index]["temperatureLow"].round()}° ${daysList[index]["temperatureHigh"].round()}°",
                        style: TextStyle(
                            fontSize: _width * 0.045, color: MyHomePage.mainColor),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  String getDay(int day) {
    switch (day) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "Error!";
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double iconFontSize = width * 0.03;

    return (gotData ? buildHome(height, width, iconFontSize) : tempScreen());
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

  Widget buildHome(double height, double width, double iconFontSize) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyHomePage.darkBackgroundColor,
          title: Text("Woodbridge"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _onBackPressed,
          ),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Settings()),
                      );
                    }))
          ],
        ),
        backgroundColor: MyHomePage.backgroundColor,
        body: Column(
          children: <Widget>[
            SizedBox(
              height: height * 0.01,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/humidity.png', scale: 10),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Humidity:",
                            style: TextStyle(
                                color: MyHomePage.mainColor, fontSize: iconFontSize),
                          ),
                          Text(
                            "${(weather["currently"]["humidity"] * 100).round()}%",
                            style: TextStyle(color: MyHomePage.mainColor),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/wind-icon.png', scale: 10),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Wind Speed:",
                            style: TextStyle(
                                color: MyHomePage.mainColor, fontSize: iconFontSize),
                          ),
                          Text(
                            "${weather["currently"]["windSpeed"].round()} " +
                                (unit ? "mph" : "m/s"),
                            style: TextStyle(color: MyHomePage.mainColor),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('assets/umbrella.png', scale: 10),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Precipitation:",
                            style: TextStyle(
                                color: MyHomePage.mainColor, fontSize: iconFontSize),
                          ),
                          Text(
                            "${weather["currently"]["precipProbability"].round()}%",
                            style: TextStyle(color: MyHomePage.mainColor),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            //SizedBox(height:height*0.07),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${weather["currently"]["temperature"].round()}",
                  style: TextStyle(
                      color: MyHomePage.accentColor,
                      fontSize: height * 0.125,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  unit ? "°F" : "°C",
                  style: TextStyle(
                      color: MyHomePage.accentColor,
                      fontSize: height * 0.0375,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              weather["currently"]["summary"],
              style: TextStyle(fontSize: 30, color: MyHomePage.mainColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Image.asset(
              "assets/dark/${weather["currently"]["icon"]}.png",
              scale: (-0.04 * height + 43),
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.02),
                child: Text("5-Day Forecast",
                    style: TextStyle(
                      fontSize: width * 0.12,
                      color: MyHomePage.mainColor,
                    ))),

            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: SizedBox(
                        height: height * 0.22,
                        child: ListView.builder(
                          itemCount: 5,
                          itemBuilder: (BuildContext ctxt, int index) =>
                              builder(ctxt, index),
                          scrollDirection: Axis.horizontal,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
