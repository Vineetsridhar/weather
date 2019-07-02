import 'dart:async';

import 'package:flutter/material.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';

class NewPlace extends StatefulWidget {
  @override
  _NewPlaceState createState() => _NewPlaceState();
}

class _NewPlaceState extends State<NewPlace> {
  List<String> places;
  String url;
  var results;
  bool searching = false;
  String query = "";
  final _searchQuery = new TextEditingController();
  Timer _debounce;
  int num;

  @override
  initState() {
    super.initState();
  }

  _onBackPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  _onChange(String input) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      _updateValues(input);
    });
  }

  _updateValues(input) async {
    setState(() {
      searching = true;
      query = input;
      num = 0;
    });
    print(query);
    if (query.isNotEmpty) {
      url =
          "https://api.opencagedata.com/geocode/v1/json?q=$input&key=${Credentials.geokey}";
      print(url);
      var res = await http
          .get(Uri.encodeFull(url), headers: {'Accept': 'application/json'});
      setState(() {
        places = List<String>();
        results = jsonDecode(res.body) as Map<String, dynamic>;
        if (results["total_results"] > 0) {
          results["results"].forEach((item) {
            if (item["components"]["city"] != null) {
              String formattedText =
                  "${item["components"]["city"]}, ${item["components"]["state"]}/${item["geometry"]["lat"]}/${item["geometry"]["lng"]}/${item["annotations"]["timezone"]["offset_sec"]}";
              places.add(formattedText);
              num++;
            }
          });
        }
      });
    }
    setState(() {
      searching = false;
    });
  }

  addToData(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> places = prefs.getStringList("places") ?? List<String>();
    bool found = false;
    for (String place in places) {
      if (place.split("/")[0] == data.split("/")[0]) {
        found = true;
        break;
      }
    }

    if (!found) {
      places.add(data);
      prefs.setStringList('places', places);
    }
  }

  builder(context, index) {
    return (ListTile(
      title: Text(
        places[index]
            .split("/")[0]
            .substring(0, places[index].split("/")[0].indexOf(",")),
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
          places[index].split("/")[0].substring(
                places[index].split("/")[0].indexOf(",") + 2,
              ),
          style: TextStyle(color: Colors.white)),
      onTap: () {
        print(places[index]);
        addToData(places[index]);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(places[index])),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyHomePage.darkBackgroundColor,
          title: Text("New Place"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _onBackPressed();
            },
          ),
        ),
        backgroundColor: MyHomePage.backgroundColor,
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: TextField(
                controller: _searchQuery,
                decoration: InputDecoration(
                  labelText: "Type a city / ZIP",
                  fillColor: MyHomePage.mainColor,
                ),
                style: TextStyle(color: MyHomePage.mainColor),
                onChanged: (input) => _onChange(input),
              ),
            ),
            (!searching
                ? (query.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: num < 5 ? num : 5,
                          itemBuilder: (context, index) =>
                              builder(context, index),
                        ),
                      )
                    : Text(""))
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator()))
          ],
        ),
      ),
    );
  }
}
