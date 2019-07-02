import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/Hourly.dart';
import 'package:weather/main.dart';

class TimePicker extends StatefulWidget {
  String data;
  TimePicker(this.data);
  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  List data;
  _onBackPressed() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    data = widget.data.split("/");
  }

  DateTime selectedDate = DateTime.now();

  _showCalendar() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1971),
        lastDate: new DateTime.now().add(new Duration(days: 31)));

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  getMonth(int month) {
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
    }
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _onBackPressed();
              },
            ),
            title: Text("Time Machine"),
          ),
          backgroundColor: MyHomePage.backgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${getMonth(selectedDate.month)} ${selectedDate.day}, ${selectedDate.year}",
                      style:
                          TextStyle(color: MyHomePage.mainColor, fontSize: 50),
                    ),
                  ),
                ),
                RaisedButton(
                  color: MyHomePage.darkBackgroundColor,
                  child: Text(
                    "Pick Date",
                    style: TextStyle(color: MyHomePage.mainColor),
                  ),
                  onPressed: () {
                    _showCalendar();
                  },
                ),
                RaisedButton(
                  color: MyHomePage.darkBackgroundColor,
                  child: Text(
                    "Submit",
                    style: TextStyle(color: MyHomePage.mainColor),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Hourly(data[0], "${(selectedDate.millisecondsSinceEpoch/1000).round()}", data[1], data[2], int.parse(data[3]))
                          ),
                    );
                  },
                )
              ],
            ),
          ),
        ));
  }
}
