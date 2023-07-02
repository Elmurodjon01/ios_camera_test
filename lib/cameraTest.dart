import 'dart:math' as math;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:cameratest/savedImage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:collection/collection.dart';

class DistanceTrackingPage extends StatefulWidget {
  @override
  _DistanceTrackingPageState createState() => _DistanceTrackingPageState();
}

class _DistanceTrackingPageState extends State<DistanceTrackingPage> {
  late ARKitController arkitController;
  ARKitPlane? plane;
  ARKitNode? node;
  String? anchorId;
  vector.Vector3? lastPosition;
var snackMessage = const SnackBar(content:  Text('yay'));

@override
void initState(){
  
  super.initState();

  SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      ]);
     WidgetsBinding.instance.addPostFrameCallback((_){

 customAlertDialog();

});


}


@override
dispose(){
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  arkitController.dispose();
  super.dispose();
}



  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;
    return  Scaffold(
        body: Stack(
          children: [
            ARKitSceneView(
            showFeaturePoints: true,
            planeDetection: ARPlaneDetection.vertical,
            //TODO screen must open in vertical by default
            onARKitViewCreated: onARKitViewCreated,
            enableTapRecognizer: true,
          ),
          Positioned(
            top: size.width * 0.01,
            left: size.width * 0.03,
            child: MaterialButton(
              color: const  Color(0xFF018786),
              onPressed: ()=> Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30,),
            ),
          ),
          Positioned(
           top: size.height * 0.63,
           bottom: size.height * 0.1,
           left:size.height * 0.75,
           right: size.height * 0.75,

            child: Container(
              height: size.height * 0.7,
            decoration:  BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(width: 5, color:const  Color(0xFF018786)),

              // color: Colors.red,
            ),
           child:const Center(child: Text('Card read function', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),),
          ),),
     
          ],
        ),
         floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt, color: Color(0xFF018786),),
        onPressed: () async {
          try {
            final image = await arkitController.snapshot();
            // ignore: use_build_context_synchronously
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SnapshotPreview(
                  imageProvider: image,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
      );
  }







 customAlertDialog(){
  return showDialog(context: context, builder: (_){
    return CupertinoAlertDialog(
    title: const Text('카메라 경고'),
    content: const Text('물체를 측정하기 위해 전화기를 똑바로 유지하십시오.'),
    actions: [
      GestureDetector(
        onTap: ()=> Navigator.pop(context),
        child: const CupertinoDialogAction(child:  const Text('OK')))
    ],
  );
  });
}





  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
    this.arkitController.onARTap = (List<ARKitTestResult> ar) {
      final planeTap = ar.firstWhereOrNull(
        (tap) => tap.type == ARKitHitTestResultType.existingPlaneUsingExtent,
      );
      if (planeTap != null) {
        _onPlaneTapHandler(planeTap.worldTransform);
      }
    };
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (!(anchor is ARKitPlaneAnchor)) {
      return;
    }
    _addPlane(arkitController, anchor);
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor.identifier != anchorId) {
      return;
    }
    final planeAnchor = anchor as ARKitPlaneAnchor;
    node!.position =
        vector.Vector3(planeAnchor.center.x, 0, planeAnchor.center.z);
    plane?.width.value = planeAnchor.extent.x;
    plane?.height.value = planeAnchor.extent.z;
  }

  void _addPlane(ARKitController controller, ARKitPlaneAnchor anchor) {
    anchorId = anchor.identifier;
    plane = ARKitPlane(
      width: anchor.extent.x,
      height: anchor.extent.z,
      materials: [
        ARKitMaterial(
          transparency: 0.5,
          diffuse: ARKitMaterialProperty.color(Colors.white),
        )
      ],
    );

    node = ARKitNode(
      geometry: plane,
      position: vector.Vector3(anchor.center.x, 0, anchor.center.z),
      rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
    );
    controller.add(node!, parentNodeName: anchor.nodeName);
  }

  void _onPlaneTapHandler(Matrix4 transform) {
    final position = vector.Vector3(
      transform.getColumn(3).x,
      transform.getColumn(3).y,
      transform.getColumn(3).z,
    );
    final material = ARKitMaterial(
      lightingModelName: ARKitLightingModel.constant,
      // diffuse: ARKitMaterialProperty.color(const Color.fromRGBO(255, 153, 83, 1)),
      diffuse: ARKitMaterialProperty.color(const Color(0xFFE91E63)),
    );
    final sphere = ARKitSphere(
      radius: 0.003,
      materials: [material],
    );
    final node = ARKitNode(
      geometry: sphere,
      position: position,
    );
    arkitController.add(node);
    if (lastPosition != null) {
      final line = ARKitLine(
        fromVector: lastPosition!,
        toVector: position,
      );
      final lineNode = ARKitNode(geometry: line);
      arkitController.add(lineNode);

      final distance = _calculateDistanceBetweenPoints(position, lastPosition!);
      final point = _getMiddleVector(position, lastPosition!);
      _drawText(distance, point);
    }
    lastPosition = position;
  }

  String _calculateDistanceBetweenPoints(vector.Vector3 A, vector.Vector3 B) {
    final length = A.distanceTo(B);
    return '${(length * 100).toStringAsFixed(2)} 센티미터';
  }

  vector.Vector3 _getMiddleVector(vector.Vector3 A, vector.Vector3 B) {
    return vector.Vector3((A.x + B.x) / 2, (A.y + B.y) / 2, (A.z + B.z) / 2);
  }

  void _drawText(String text, vector.Vector3 point) {
    final textGeometry = ARKitText(
      text: text,
      extrusionDepth: 1,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(Colors.red),
        )
      ],
    );
    const scale = 0.001;
    final vectorScale = vector.Vector3(scale, scale, scale);
    final node = ARKitNode(
      geometry: textGeometry,
      position: point,
      scale: vectorScale,
    );
    arkitController
        .getNodeBoundingBox(node)
        .then((List<vector.Vector3> result) {
      final minVector = result[0];
      final maxVector = result[1];
      final dx = (maxVector.x - minVector.x) / 2 * scale;
      final dy = (maxVector.y - minVector.y) / 2 * scale;
      final position = vector.Vector3(
        node.position.x - dx,
        node.position.y - dy,
        node.position.z,
      );
      node.position = position;
    });
    arkitController.add(node);
  }
}



