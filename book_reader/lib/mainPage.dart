import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'main.dart';
import 'pixelSizeFunc.dart';

class MyHomePageState extends State<MyHomePage> {
  late CameraController _cameraController;  // 카메라 컨트롤러
  late CameraDescription back_camera; // 카메라 객체
  bool _cameraInitialized = false;  // 카메라 초기화 플래그
  // late Future<void> _initializeControllerFuture;
  int lastTouchDownMiliSecond = 0;  // 터치 다운 시간
  int lastTouchUpMiliSecond = 0;  // 터치 업 시간
  int touchOption = 0;  // 터치0/더블터치1/트리플터치2
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
    // 후면 카메라 탐색
    for (var camera in cameras) {
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
          // 카메라 초기화가 완료안됐을 경우 로딩
          child: _cameraInitialized
              ? GestureDetector(
                  child: Container(
                      child: Stack(children: [
                        // 카메라
                        SizedBox(
                          child: CameraPreview(
                            _cameraController,
                          ),
                          width: double.infinity,
                          height: double.infinity,
                        ),

                        // ROI 박스(상단)
                        Positioned(
                            child: Divider(
                              color: Colors.red,
                              thickness: 2,
                            ),
                            height: 1,
                            width: changePercentSizeToPixel(context, 90, true),
                            top: changePercentSizeToPixel(context, 10, false),
                            left: changePercentSizeToPixel(context, 5, true)),

                        // ROI 박스(하단)
                        Positioned(
                            child: Divider(
                              color: Colors.red,
                              thickness: 2,
                            ),
                            height: 1,
                            width: changePercentSizeToPixel(context, 90, true),
                            bottom:
                                changePercentSizeToPixel(context, 10, false),
                            left: changePercentSizeToPixel(context, 5, true)),

                        // ROI 박스(좌측)
                        Positioned(
                            child: VerticalDivider(
                              color: Colors.red,
                              thickness: 2,
                            ),
                            width: 1,
                            height:
                                changePercentSizeToPixel(context, 80, false),
                            top: changePercentSizeToPixel(context, 10, false),
                            left: changePercentSizeToPixel(context, 5, true)),

                        // ROI 박스(우측)
                        Positioned(
                            child: VerticalDivider(
                              color: Colors.red,
                              thickness: 2,
                            ),
                            width: 1,
                            height:
                                changePercentSizeToPixel(context, 80, false),
                            top: changePercentSizeToPixel(context, 10, false),
                            right: changePercentSizeToPixel(context, 5, true)),
                      ]),
                      color: Colors.blue),

                  // 배경 터치
                  onTapDown: (TapDownDetails details) {
                    // int touchDownMiliSecond = DateTime.now().millisecondsSinceEpoch;
                    // if (touchDownMiliSecond - lastTouchDownMiliSecond >500){
                    //   touchOption = 0;}
                    // else{
                    //   touchOption = 1;
                    // }
                    //
                    // switch (touchOption){
                    //   case 0:
                        print("다운 ${details.localPosition}");
                    //     break;
                    //   case 1:
                    //     print("더블 다운${details.localPosition}");
                    //     break;
                    //   default:
                    //     break;
                    // }

                    // lastTouchDownMiliSecond = touchDownMiliSecond;

                  },

                  onTapUp: (TapUpDetails details) {
                    // print("업 ${details.localPosition}");
                  },

            onDoubleTapDown: (TapDownDetails detawils){print("더블다운");},



                )
              : Center(
                  child: Column(children: [
                  CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ),
                ]))),
    );
  }
}
