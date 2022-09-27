// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/services.dart';
//import 'package:mqtt_client/mqtt_client.dart';
//import 'mqtt.dart' as mqtt;

void main() {
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
  late IOWebSocketChannel channel;
  late bool connected;
  bool manual_control = false;

  final _textController = TextEditingController();
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

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      channel.sink.add(cmd);
    }
  }

  void _pushMusic() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: const Text("new page")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10.0),
              child: SizedBox(
                width: 400.0,
                height: 100.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: Color.fromARGB(255, 105, 104, 104)),
                  child: Text('BUTTON 1'),
                  onPressed: () {},
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: SizedBox(
                width: 400.0,
                height: 100.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: Color.fromARGB(255, 105, 104, 104)),
                  child: Text('BUTTON 3'),
                  onPressed: () {},
                ),
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 150.0,
                      height: 100.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Color.fromARGB(255, 105, 104, 104)),
                        child: Text('BUTTON 4'),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 150,
                      height: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Color.fromARGB(255, 105, 104, 104)),
                        child: Text('BUTTON 5'),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ])
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
        leading: IconButton(
          icon: const Icon(Icons.list),
          onPressed: () {},
          tooltip: 'Saved Suggestions',
        ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
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
                  label: Text("GET VOLTAGE DATA",
                      style: GoogleFonts.getFont('Kanit')),
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
                  width: 200,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.pan_tool),
                    label: manual_control
                        ? Text("Manual control",
                            style: GoogleFonts.getFont('Kanit'))
                        : Text("Protection mode",
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
                      controller: _textController,
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
                              _textController.clear();
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
                      userVoltage = _textController.text;
                      String voltage_msg = "s" + userVoltage;
                      sendcmd(voltage_msg);
                      print("voltage_msg: " + voltage_msg);
                    });
                  },
                  color: Color.fromARGB(255, 248, 244, 244),
                  child: Text('Set',
                      style: GoogleFonts.kanit(
                          textStyle: TextStyle(
                              color: Color.fromARGB(255, 61, 60, 60)))),
                )
              ],
            ),
          ]),
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
