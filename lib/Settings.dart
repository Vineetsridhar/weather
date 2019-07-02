import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  String data;
  Settings(this.data);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool setting;
  bool theme;

  @override
  initState() {
    super.initState();
    getStateValue();
  }



  getStateValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      setting = (prefs.getBool('units') ?? true);
      theme = (prefs.getBool('theme') ?? false);
    });
  }

  _editUnits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      setting = !setting;
    });

    prefs.setBool('units', setting);
  }
  _editTheme() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theme = !theme;
      switch(theme){
        case true:
          MyHomePage.backgroundColor = Color.fromRGBO(0x5c, 0xdb, 0x95, 1.0);
          MyHomePage.darkBackgroundColor = Color.fromRGBO(0x1b, 0xb6, 0x5F, 1.0);
          MyHomePage.accentColor = Color.fromRGBO(0x05, 0x38, 0x6b, 1);
          break;
        case false:
          MyHomePage.backgroundColor= Color.fromRGBO(0x30, 0x30, 0x30, 1.0);
          MyHomePage.darkBackgroundColor = Color.fromRGBO(0x21, 0x21, 0x21, 1.0);
          MyHomePage.accentColor = Colors.lightBlue;
          break;
      }
    });

    prefs.setBool('theme', theme);
  }


  _onBackPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(color: MyHomePage.mainColor, fontSize: 20);

    return WillPopScope(
      onWillPop: (){_onBackPressed();},
          child: Scaffold(
          appBar: AppBar(
            backgroundColor: MyHomePage.darkBackgroundColor,
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: _onBackPressed),
            title: Text("Options"),
          ),
          backgroundColor: MyHomePage.backgroundColor,
          body: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Units: ",
                    style: TextStyle(fontSize: 50, color: MyHomePage.mainColor),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "Imperial",
                          style: style,
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text("SI", style: style),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Radio(
                          value: true,
                          groupValue: setting,
                          onChanged: (bool) {
                            _editUnits();
                          },
                        ),
                        Radio(
                          value: false,
                          groupValue: setting,
                          onChanged: (bool) {
                            _editUnits();
                          },
                        ),
                      ],
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Theme: ",
                    style: TextStyle(fontSize: 50, color:MyHomePage.mainColor),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "Light",
                          style: style,
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text("Dark", style: style),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Radio(
                          value: true,
                          groupValue: theme,
                          onChanged: (bool) {
                            _editTheme();
                          },
                        ),
                        Radio(
                          value: false,
                          groupValue: theme,
                          onChanged: (bool) {
                            _editTheme();
                          },
                        ),
                      ],
                    )
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Powered by Dark Sky",
                        style: TextStyle(
                            color: MyHomePage.mainColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
