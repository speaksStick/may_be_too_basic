import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp
    (
      title: "May be too basic for you!",
      color: Color.fromRGBO(22, 158, 140, 0),
      home: ScafoldStatefulWidget()
    );
     
  }
}

class ScafoldStatefulWidget extends StatefulWidget {
  const ScafoldStatefulWidget({super.key});

  @override
  State<ScafoldStatefulWidget> createState() => _ScafoldStatefulWidgetState();
}

class _ScafoldStatefulWidgetState extends State<ScafoldStatefulWidget> {
  int myCount = 0;
  int myColourRed = 0;
  int myColourGreen = 0;
  int myColourBlue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
    appBar: AppBar
    (
      title: Center( child: new Text("Shri Ganeshaya namaha")),
    ),
    body: Center(child: new Text("You pressed this color $myColourRed $myColourGreen $myColourBlue & count $myCount"),),
    backgroundColor: Color.fromARGB(255, myColourRed, myColourGreen, myColourBlue)
    ,floatingActionButton: FloatingActionButton(onPressed: () => setState(() {
      myCount++;
      myColourRed = Random().nextInt(255);
      myColourGreen = Random().nextInt(255);
      myColourBlue = Random().nextInt(255);

    }),
    tooltip: "Increment counter",
    child: Icon(Icons.add),
    ));
  }
}

