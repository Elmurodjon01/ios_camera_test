import 'dart:math';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class CameraTestPage extends StatefulWidget {
  const CameraTestPage({super.key});

  @override
  _CameraTestPageState createState() => _CameraTestPageState();
}

class _CameraTestPageState extends State<CameraTestPage> {
  late ARKitController arkitController;
  late ARKitPlane plane;
  late ARKitNode node;
  late Vector3 lastPosition;
  late String anchorID;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Camera test page')),
      body: Container(
        child: ARKitSceneView(
          showFeaturePoints: true,
          planeDetection: ARPlaneDetection.horizontal,
          onARKitViewCreated: onARKitViewCreated,
          enableTapRecognizer: true,
        ),
      ));

  void onARViewCreated(ARKitController arKitController) {
    this.arkitController = arKitController;
    this.arkitController.onAddNodeForAnchor = addAnchor;
    this.arkitController.onUpdateNodeForAnchor =
        updateAnchor as AnchorEventHandler?;
    this.arkitController.onARTap = (List<ARKitTestResult> ar) {
      // ignore: unused_local_variable
      var planeTap = ar.firstWhere(
        (tap) => tap.type == ARKitHitTestResultType.existingPlaneUsingExtent,
        orElse: () {
          var kk = null;
          return kk;
        },
      );
      {
        if (planeTap != null) {
          onPlaneTapHandler(planeTap.worldTransform);
        }
      }
      ;
    };
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    final node = ARKitNode(
        geometry: ARKitSphere(radius: 0.1), position: Vector3(0, 0, -0.5));
    this.arkitController.add(node);
  }

  void addAnchor(ARKitAnchor anchor) {
    if (!(anchor is ARKitPlaneAnchor)) {
      return;
    }
    //TODO check the values of addPlane function later
    addPlane(arkitController, anchor);
  }

  void addPlane(ARKitController controller, ARKitPlaneAnchor anchor) {
    anchorID = anchor.identifier;
    plane = ARKitPlane(
      width: anchor.extent.x,
      height: anchor.extent.y,
      materials: [
        ARKitMaterial(
            transparency: 0.5,
            diffuse: ARKitMaterialProperty.color(const Color(0xFFFFFFFF))),
      ],
    );
    node = ARKitNode(
        geometry: plane,
        position: Vector3(anchor.center.x, 0, anchor.center.z),
        rotation: Vector4(1, 0, 0, -pi / 2));
    controller.add(node, parentNodeName: anchor.nodeName);
  }

//TODO here the anchor was ArkitAnchor, not ArkitplaneAnchor, may cause an error
  void updateAnchor(ARKitPlaneAnchor anchor) {
    if (anchor.identifier != anchorID) {
      return;
    }
    final ARKitPlaneAnchor planeAnchor = anchor;
    node.position = Vector3(planeAnchor.center.x, 0, planeAnchor.center.z);
    plane.width.value = planeAnchor.extent.x;
    plane.height.value = planeAnchor.extent.z;
  }

  void onPlaneTapHandler(Matrix4 transform) {
    final position = Vector3(transform.getColumn(3).x, transform.getColumn(3).y,
        transform.getColumn(3).z);
    final material = ARKitMaterial(
        lightingModelName: ARKitLightingModel.constant,
        diffuse: ARKitMaterialProperty.color(const Color(0xFFFFA500)));

    final sphare = ARKitSphere(
      radius: 0.003,
      materials: [material],
    );
    final node = ARKitNode(
      geometry: sphare,
      position: position,
    );
    arkitController.add(node);
    if (lastPosition != null) {
      final line = ARKitLine(fromVector: lastPosition, toVector: position);
      final lineNode = ARKitNode(geometry: line);
      arkitController.add(lineNode);
      final distance = calculateDistanceBetweenPoints(position, lastPosition);
      final point = getMiddleVector(position, lastPosition);
      drawText(distance, point);
    }
  }

  String calculateDistanceBetweenPoints(Vector3 A, Vector3 B) {
    final length = A.distanceTo(B);
    return '${(length * 100).toStringAsFixed(2)} cm';
  }

  Vector3 getMiddleVector(Vector3 A, Vector3 B) {
    return Vector3((A.x + B.x) / 2, (A.y + B.y) / 2, (A.z + B.z) / 2);
  }

  void drawText(String textDistance, Vector3 point) {
    final textGeometry =
        ARKitText(text: textDistance, extrusionDepth: 1, materials: [
      ARKitMaterial(
        diffuse: ARKitMaterialProperty.color(const Color(0xFFff0000)),
      )
    ]);
    const scale = 0.001;
    final vectorScale = Vector3(scale, scale, scale);
    final node = ARKitNode(
      geometry: textGeometry,
      position: point,
      scale: vectorScale,
    );

    arkitController.getNodeBoundingBox(node).then((List<Vector3> value) {
      final minVector = value[0];
      final maxVactor = value[1];

      final dx = (maxVactor.x - minVector.x) / 2 * scale;
      final dy = (maxVactor.y - minVector.y) / 2 * scale;
      final position =
          Vector3(node.position.x - dx, node.position.y - dy, node.position.z);
      node.position = position;
    });
  }
}
