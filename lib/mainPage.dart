import 'package:cameratest/cameraTestPage.dart';
import 'package:flutter/material.dart';

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
        child: IconButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CameraTestPage())),
          icon: const Icon(
            Icons.camera_alt_outlined,
            size: 40,
          ),
        ),
      ),
    );
  }
}
