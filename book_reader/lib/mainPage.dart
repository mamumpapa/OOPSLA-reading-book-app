import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'main.dart';

class MyHomePageState extends State<MyHomePage> {
  late CameraController _cameraController;
  late CameraDescription back_camera;
  late Future<void> _initializeControllerFuture;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    // 카메라 컨트롤러 생성
    readyToCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // 카메라 초기화
  void readyToCamera() async {
    // 사용 가능한 카메라 목록 받아옴(후면, 전면)
    final cameras = await availableCameras();
    // 카메라 없을 경우
    if (0 == cameras.length) {
      print("not found any cameras");
      return;
    }

    for (var camera in cameras) {
      // 후면 카메라 탐색
      if (camera.lensDirection == CameraLensDirection.back) {
        back_camera = camera;
        break;
      }
    }

    // 카메라 컨트롤러 초기화
    _cameraController = CameraController(back_camera, ResolutionPreset.max);
    _cameraController.initialize().then((value) {
      // 카메라 준비가 끝나면 카메라 미리보기를 보여주기 위해 앱 화면을 다시 그립니다.
      setState(() => _cameraInitialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: _cameraInitialized ?
          Container(child:CameraPreview(_cameraController,), width: double.infinity, height: double.infinity, color: Colors.blue)
          : Center(
                  child:Column(
                    children: [
                      CircularProgressIndicator(backgroundColor: Colors.black,),
                  ]))),
    );
  }
}
