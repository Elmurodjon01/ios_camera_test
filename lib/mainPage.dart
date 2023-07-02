

import 'package:cameratest/cameraTest.dart';
import 'package:flutter/material.dart';
//dd
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera test'),
        centerTitle: true,
      ),
      body: Center(
        child: MaterialButton(onPressed:   (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> DistanceTrackingPage()));
        },
        child:  const Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt),
            Text('Test the Camera'),
          ],
        )),),
      ),
    );
  }
}
