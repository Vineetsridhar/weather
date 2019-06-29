import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/TempScreen.dart';
import 'main.dart';
import 'Credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Hourly extends StatefulWidget {
  String time, lat, long, name;
  int offset;
  Hourly(this.name, this.time, this.lat, this.long, this.offset);
  @override
  _HourlyState createState() => _HourlyState();
}

class _HourlyState extends State<Hourly> {
  DateTime current;
  String url;
  var results;
  List hours;
  bool isLoaded = false;
  double height, width;

  @override
  void initState() {
    super.initState();
    this.getWeatherData();
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  getWeatherData() async {
    url =
        "https://api.darksky.net/forecast/${Credentials.key}/${widget.lat},${widget.long},${widget.time}";
    url += (MyHomePage.unit ? "" : "?units=si");

    var res = await http
        .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});

    setState(() {
      hours = jsonDecode(res.body)["hourly"]["data"];
      isLoaded = true;
      print(url);
    });
  }

  String getFormattedTime(current) {
    String suffix = " A.M.";
    String hour;
    if (current.hour > 12) {
      hour = "${current.hour - 12}";
      suffix = " P.M.";
    } else if (current.hour == 0) {
      hour = "12";
    } else {
      hour = "${current.hour}";
    }
    return "$hour:00$suffix";
  }

  Widget builder(context, i) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    DateTime current = DateTime.fromMillisecondsSinceEpoch(
            (hours[i]["time"] + widget.offset) * 1000)
        .toUtc();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: height / 10,
        //decoration: BoxDecoration(color: Colors.blue),
        child: Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(20),
                child: Image.asset(
                  "assets/dark/${hours[i]["icon"]}.png",
                  scale: 30,
                  color: MyHomePage.accentColor,
                )),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      getFormattedTime(current),
                      style: TextStyle(
                          color: MyHomePage.accentColor,
                          fontSize: height * 0.0222,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      hours[i]["summary"],
                      style: TextStyle(
                        color: MyHomePage.accentColor,
                        fontSize: (hours[i]["summary"].split(" ").length > 3
                            ? height * 0.018
                            : height * 0.02222),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expanded(
            //   flex: 1,
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal:8.0),
            //     child: Text(
            //       "${(hours[i]["precipProbability"]*100).round()}% Rain",
            //       style: TextStyle(
            //         color: MyHomePage.accentColor,
            //         fontSize: height * 0.01666,
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "${hours[i]["temperature"].round()}",
                      style: TextStyle(
                        color: MyHomePage.accentColor,
                        fontSize: height * 0.02778,
                      ),
                    ),
                    Text(
                      MyHomePage.unit ? "°F" : "°C",
                      style: TextStyle(
                        color: MyHomePage.accentColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget mainPage() => WillPopScope(
      onWillPop: () {
        _onBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyHomePage.darkBackgroundColor,
          title: Text(widget.name),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _onBackPressed();
            },
          ),
        ),
        backgroundColor: MyHomePage.backgroundColor,
        body: ListView.builder(
          itemCount: 24,
          itemBuilder: (context, index) => builder(context, index),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return isLoaded ? mainPage() : TempScreen();
  }
}
