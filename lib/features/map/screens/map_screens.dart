import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MapScreens extends StatefulWidget {
  const MapScreens({super.key});

  @override
  State<MapScreens> createState() => _MapScreensState();
}

class _MapScreensState extends State<MapScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Map Screen"),),
    );
  }
}
