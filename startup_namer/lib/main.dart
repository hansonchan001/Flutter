// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/services.dart';
import 'package:window_size/window_size.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:startup_namer/dbHelper/mongodb.dart';
//import 'package:mongo_dart/mongo_dart.dart' hide State show Db, DbCollection;
//import 'package:graphql_flutter/graphql_flutter.dart';
//import 'package:mqtt_client/mqtt_client.dart';
//import 'mqtt.dart' as mqtt;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Monitor',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 252, 251, 249),
          foregroundColor: Color.fromARGB(255, 7, 7, 7),
        ),
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  late bool ledstatus;
  //late bool connection_status = false;
  late IOWebSocketChannel channel;
  late bool connected;
  bool manual_control = false;

  var month, day, time;

  final _setVoltage = TextEditingController();
  final _month = TextEditingController();
  final _day = TextEditingController();
  final _time = TextEditingController();
  String userVoltage = '';
  String batteryVoltage = '';

  @override
  void initState() {
    ledstatus = false;
    connected = false;

    Future.delayed(Duration.zero, () async {
      channelconnect();
    });

    super.initState();
  }

  channelconnect() {
    try {
      //channel = IOWebSocketChannel.connect("ws://192.168.0.1:81");
      channel = IOWebSocketChannel.connect("ws://10.104.80.68:81");
      channel.stream.listen(
        (message) {
          print(message);
          //print(message.toString().substring(0, 7));
          setState(() {
            if (message == "connected") {
              connected = true;
            } else if (message == "poweron:success") {
              ledstatus = true;
            } else if (message == "poweroff:success") {
              ledstatus = false;
            } else if (message.toString().substring(0, 7) == "Voltage") {
              batteryVoltage = message.toString().substring(8, 13);
            }
          });
        },
        onDone: () {
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  espRestart() {
    sendcmd("restart");
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      channel.sink.add(cmd);
    }
  }

  void _dataEnterPage() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Input date")),
        body: ListView(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  style: TextStyle(
                    color: Color.fromARGB(255, 85, 84, 84),
                  ),
                  controller: _month,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 224, 228, 231),
                      hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Color.fromARGB(255, 141, 139, 139)),
                      hintText: 'Month',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.teal,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _month.clear();
                        },
                        icon: const Icon(Icons.clear),
                        color: Color.fromARGB(255, 141, 139, 139),
                      )),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  style: TextStyle(
                    color: Color.fromARGB(255, 85, 84, 84),
                  ),
                  controller: _day,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 224, 228, 231),
                      hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Color.fromARGB(255, 141, 139, 139)),
                      hintText: 'Day',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.teal,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _day.clear();
                        },
                        icon: const Icon(Icons.clear),
                        color: Color.fromARGB(255, 141, 139, 139),
                      )),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  style: TextStyle(
                    color: Color.fromARGB(255, 85, 84, 84),
                  ),
                  controller: _time,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 224, 228, 231),
                      hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Color.fromARGB(255, 141, 139, 139)),
                      hintText: 'Time (in hhmm)',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.teal,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _time.clear();
                        },
                        icon: const Icon(Icons.clear),
                        color: Color.fromARGB(255, 141, 139, 139),
                      )),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                //update the voltage
                _viewData();
                //setState(() {});
              },
              color: Color.fromARGB(255, 248, 244, 244),
              child: Text('Get',
                  style: GoogleFonts.kanit(
                      textStyle:
                          TextStyle(color: Color.fromARGB(255, 61, 60, 60)))),
            )
          ],
        ),
      );
    }));
  }

  Future<void> _viewData() async {
    month = int.parse(_month.text);
    day = int.parse(_day.text);
    time = _time.text;

    List<voltageData> columnData = <voltageData>[];
    columnData = await MongoDatabase.query(month, day, time);
    //print('column length: ' + MongoDatabase.columnData.length.toString());

    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Battery record")),
        body: ListView(
          children: <Widget>[
            Container(
              height: 550,
              child: SfCartesianChart(
                title: ChartTitle(text: 'Past battery voltage variation'),
                legend: Legend(isVisible: true),
                primaryXAxis: CategoryAxis(
                    title: AxisTitle(
                        text: 'Time (in HHMM)',
                        textStyle: TextStyle(color: Colors.deepOrange))),
                primaryYAxis: NumericAxis(
                    title: AxisTitle(
                        text: 'Voltage (V)',
                        textStyle: TextStyle(color: Colors.deepOrange))),
                series: <ChartSeries>[
                  ScatterSeries<voltageData, String>(
                    dataSource: columnData,
                    xValueMapper: (voltageData data, _) => data.time,
                    yValueMapper: (voltageData data, _) => data.volt,
                  )
                ],
              ),
            )
          ],
        ),
        floatingActionButton: IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {},
          tooltip: 'Saved Suggestions',
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 29, 26),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 29, 29, 26),
        foregroundColor: Color.fromARGB(255, 246, 250, 246),
        title: Text('Battery monitor', style: GoogleFonts.getFont('Kanit')),
        centerTitle: true,
        elevation: 3,
      ),
      body: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          child: SizedBox(
            width: 400,
            height: 100,
            child: ElevatedButton.icon(
              icon: ledstatus
                  ? Icon(
                      Icons.flashlight_off,
                      size: 40,
                    )
                  : Icon(
                      Icons.flashlight_on,
                      size: 40,
                    ),
              label: ledstatus
                  ? Text("TURN OFF", style: GoogleFonts.getFont('Kanit'))
                  : Text("TURN ON", style: GoogleFonts.getFont('Kanit')),
              //child: ledstatus? Text('Turn OFF'):Text("Turn on");
              style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 25),
                  onPrimary: Color.fromARGB(255, 15, 14, 14),
                  primary: Color.fromARGB(255, 255, 255, 255)),
              onPressed: () {
                manual_control = true;
                if (ledstatus) {
                  sendcmd("poweroff");
                  ledstatus = false;
                } else {
                  sendcmd("poweron");
                  ledstatus = true;
                }
                setState(() {});
              },
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: SizedBox(
            width: 400.0,
            height: 100.0,
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.flash_on,
                size: 40,
              ),
              label:
                  Text("GET VOLTAGE DATA", style: GoogleFonts.getFont('Kanit')),
              style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 25),
                  onPrimary: Color.fromARGB(255, 15, 15, 15),
                  primary: Color.fromARGB(255, 255, 255, 255)),
              onPressed: () {
                sendcmd("getvoltage");
                print("pressed get voltage");
              },
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: 240,
              height: 50,
              child: ElevatedButton.icon(
                icon: manual_control
                    ? Icon(Icons.cancel_outlined)
                    : Icon(Icons.health_and_safety_outlined),
                label: manual_control
                    ? Text("Quit manual control",
                        style: GoogleFonts.getFont('Kanit'))
                    : Text("In Protection mode",
                        style: GoogleFonts.getFont('Kanit')),
                style: manual_control
                    ? ElevatedButton.styleFrom(
                        textStyle: TextStyle(fontSize: 18),
                        onPrimary: Color.fromARGB(255, 250, 248, 248),
                        primary: Color.fromARGB(255, 243, 4, 4))
                    : ElevatedButton.styleFrom(
                        textStyle: TextStyle(fontSize: 18),
                        onPrimary: Color.fromARGB(255, 245, 243, 243),
                        primary: Color.fromARGB(255, 17, 197, 47)),
                onPressed: () {
                  if (manual_control) {
                    manual_control = false;
                    print(manual_control);
                    sendcmd("protection mode");
                  }
                  setState(() {});
                },
              ),
            )),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    'Current Battery Voltage: ',
                    style: GoogleFonts.kanit(
                      textStyle: TextStyle(
                          color: Color.fromARGB(255, 244, 245, 247),
                          letterSpacing: .5,
                          fontSize: 18),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(batteryVoltage,
                      style: GoogleFonts.kanit(
                          textStyle: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 247, 246, 244),
                      ))),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text('V',
                      style: GoogleFonts.kanit(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 247, 246, 244),
                        ),
                      )),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    'Under Voltage Protection: ',
                    style: GoogleFonts.kanit(
                      textStyle: TextStyle(
                          color: Color.fromARGB(255, 244, 245, 247),
                          letterSpacing: .5,
                          fontSize: 18),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(userVoltage,
                      style: GoogleFonts.kanit(
                          textStyle: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 247, 246, 244),
                      ))),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text('V',
                      style: GoogleFonts.kanit(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 247, 246, 244),
                        ),
                      )),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    'Network connection: ',
                    style: GoogleFonts.kanit(
                      textStyle: TextStyle(
                          color: Color.fromARGB(255, 244, 245, 247),
                          letterSpacing: .5,
                          fontSize: 18),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: connected
                      ? Text('Connected',
                          style: GoogleFonts.kanit(
                              textStyle: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 247, 246, 244),
                          )))
                      : Text('Disconnected',
                          style: GoogleFonts.kanit(
                              textStyle: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 247, 246, 244),
                          ))),
                ),
              ],
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  style: TextStyle(
                    color: Color.fromARGB(255, 85, 84, 84),
                  ),
                  controller: _setVoltage,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 224, 228, 231),
                      hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Color.fromARGB(255, 141, 139, 139)),
                      hintText: 'Set protection voltage.',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.teal,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.security,
                        color: Color.fromARGB(255, 233, 188, 43),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _setVoltage.clear();
                        },
                        icon: const Icon(Icons.clear),
                        color: Color.fromARGB(255, 141, 139, 139),
                      )),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                //update the voltage
                setState(() {
                  userVoltage = _setVoltage.text;
                  String voltage_msg = "s" + userVoltage;
                  sendcmd(voltage_msg);
                  print("voltage_msg: " + voltage_msg);
                });
              },
              color: Color.fromARGB(255, 248, 244, 244),
              child: Text('Set',
                  style: GoogleFonts.kanit(
                      textStyle:
                          TextStyle(color: Color.fromARGB(255, 61, 60, 60)))),
            )
          ],
        ),
      ]),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Utilities'),
            ),
            ListTile(
              title: const Text('View past voltage'),
              onTap: () {
                //Navigator.pop(context);
                //_viewData();
                _dataEnterPage();
              },
            ),
            ListTile(
              title: const Text('Restart ESP'),
              onTap: () {
                espRestart();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: channelconnect,
          label: Text('Reconnect ',
              style: GoogleFonts.kanit(
                textStyle: TextStyle(
                    color: Color.fromARGB(255, 82, 88, 100),
                    letterSpacing: .5,
                    fontSize: 18),
              )),
          icon: const Icon(Icons.refresh,
              color: Color.fromARGB(255, 82, 88, 100)),
          backgroundColor: Color.fromARGB(255, 241, 236, 236)),
    );
  }
}
