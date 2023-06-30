import 'package:cameratest/cameraTestPage.dart';
import 'package:cameratest/otherCameraTest.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(onPressed:   (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const CameraTestPage()));
            },
            child:  Container(
              height: 50,
              width: 100,
              color: Colors.red,
              child: const Row(
                children: [
                  Text('Camera test 1')
                ],
              ),
            ),),
            MaterialButton(onPressed:   (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> DistanceTrackingPage()));
            },
            child:  Container(
              height: 50,
              width: 100,
              color: Colors.blue,
              child: const Row(
                children: [
                  Text('Camera test 2')
                ],
              ),
            ),),
          ],
        ),
      ),
    );
  }
}
