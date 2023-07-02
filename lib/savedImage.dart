import 'package:flutter/material.dart';


class SnapshotPreview extends StatelessWidget {
  const SnapshotPreview({
    Key? key,
    required this.imageProvider,
  }) : super(key: key);

  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: imageProvider),
        ],
      ),
    );
  }
  
}