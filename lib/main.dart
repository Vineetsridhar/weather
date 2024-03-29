import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'Credentials.dart';
import 'TempScreen.dart';
import 'Hourly.dart';
import 'TimePicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List places;
  bool isEmpty = false;
  bool isLoading = true;
  String data;

  _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    places = prefs.getStringList('places');

    if (places == null) {
      setState(() {
        isEmpty = true;
        isLoading = false;
      });
    } else {
      setState(() {
        data = places[0];
        isLoading = false;
      });
    }
  }

  @override
  initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(fontFamily: 'Raleway'),
      home: isLoading
          ? TempScreen()
          : (isEmpty ? HomeScreen() : MyHomePage(data)),
          debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  static Color mainColor = Colors.white;
  static Color backgroundColor = Color.fromRGBO(0x30, 0x30, 0x30, 1.0);
  static Color darkBackgroundColor = Color.fromRGBO(0x21, 0x21, 0x21, 1.0);
  static Color accentColor = Colors.lightBlue;

  final String data;

  static bool unit = true;

  MyHomePage(this.data);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var weather;
  List daysList;
  bool gotData = false;
  bool theme;
  List data;

  bool unit = true;
  String url;

  @override
  void initState() {
    super.initState();
    this.setData();
    this.getTheme();
    this.getWeatherData();
  }

  setData() {
    data = widget.data.split("/");
    url =
        "https://api.darksky.net/forecast/${Credentials.key}/${data[1]},${data[2]}";
    print(data);
  }

  _onBackPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = (prefs.getBool('theme') ?? false);
    setState(() {
      switch (theme) {
        case true:
          MyHomePage.backgroundColor = Color.fromRGBO(0x5c, 0xdb, 0x95, 1.0);
          MyHomePage.darkBackgroundColor =
              Color.fromRGBO(0x1b, 0xb6, 0x5F, 1.0);
          MyHomePage.accentColor = Color.fromRGBO(0x05, 0x38, 0x6b, 1);
          break;
        case false:
          MyHomePage.backgroundColor = Color.fromRGBO(0x30, 0x30, 0x30, 1.0);
          MyHomePage.darkBackgroundColor =
              Color.fromRGBO(0x21, 0x21, 0x21, 1.0);
          MyHomePage.accentColor = Colors.lightBlue;
          break;
      }
    });
  }

  getWeatherData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      unit = prefs.getBool('units') ?? true;
      MyHomePage.unit = unit;
      url += (unit ? "" : "?units=si");
    });
    var res = await http
        .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});

    setState(() {
      weather = jsonDecode(res.body) as Map<String, dynamic>;
      daysList = weather["daily"]["data"];
      gotData = true;
    });
  }

  Widget builder(BuildContext context, int index) {
    //index += 1;
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    DateTime day = DateTime.fromMillisecondsSinceEpoch(
            (daysList[index]["time"] + int.parse(data[3])) * 1000)
        .toUtc();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Hourly(
                          data[0],
                          "${daysList[index]["time"]}",
                          "${data[1]}",
                          "${data[2]}",
                          int.parse(data[3]))),
                );
              },
              child: Container(
                  width: _width / 4,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          //"${day.hour}:${day.minute}",
                          getDay(day.weekday),
                          style: TextStyle(
                              fontSize: _width * 0.035,
                              color: MyHomePage.mainColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                        child: Text(
                          "${day.month}/${day.day}",
                          style: TextStyle(
                              fontSize: _width * 0.035,
                              color: MyHomePage.mainColor),
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
                              fontSize: _width * 0.045,
                              color: MyHomePage.mainColor),
                        ),
                      ),
                    ],
                  )),
            ),
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

    return (gotData ? buildHome(height, width, iconFontSize) : TempScreen());
  }

  Color getColor(data) {
    return Colors.white;
  }

  Widget buildHome(double height, double width, double iconFontSize) {
    return WillPopScope(
      onWillPop: () {
        _onBackPressed();
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: MyHomePage.darkBackgroundColor,
            title: Text("${data[0].substring(0, data[0].indexOf(","))}"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _onBackPressed,
            ),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimePicker(widget.data)),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Settings(widget.data)),
                      );
                    }),
              ),
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
                                  color: MyHomePage.mainColor,
                                  fontSize: iconFontSize),
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
                                  color: MyHomePage.mainColor,
                                  fontSize: iconFontSize),
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
                                  color: MyHomePage.mainColor,
                                  fontSize: iconFontSize),
                            ),
                            Text(
                              "${(weather["currently"]["precipProbability"] * 100).round()}%",
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
              Image.asset("assets/dark/${weather["currently"]["icon"]}.png",
                  scale: (-0.04 * height + 43),
                  color: getColor(weather["currently"]["icon"])),
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
          )),
    );
  }
}
