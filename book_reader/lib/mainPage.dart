import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'pixelSizeFunc.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:text_to_speech/text_to_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MyHomePageState extends State<MyHomePage> {
  bool isCameraInited = false; // 카메라 초기화 플래그
  late CameraController cameraController; // 카메라 컨트롤러
  File? imageFile;
  String imageSavedPos = "";

  late Offset touchedPos; // 터치 위치 참조

  TextToSpeech tts = TextToSpeech();
  double ttsRate = 1.5;
  bool ttsIsRunninig = true;

  String helpTxt =
      "안녕하세요. 왼쪽 한번 터치는 정지와 재생. 왼쪽 두번 터치는 한문장 이전으로 이동. 오른쪽 한번 터치는 재생 속도 조절, 오른쪽 두번 터치는 한 문장 다음으로 이동 입니다. 도움말을 다시 들으려면 왼쪽 영역을 길게 눌러주세요.";
  List<String> txtList = [];
  int readingIdx = 0;

  @override
  void initState() {
    super.initState();
    // tts 설정
    tts.setLanguage('kr');
    tts.setRate(ttsRate);
    tts.speak(helpTxt);

    getCamera(); // 카메라 초기화

    txtList.add("첫 번째 문장입니다");
    txtList.add("2번이요");
    txtList.add("3번째 문장, 웁슬라가 최고야");
    txtList.add(
        "네번째 문장입니다, 이 문장은 조금 길게 테스트 해봐도 괜찮을 것 같다고 생각이 드는 바입니다. 한 마디만 더 쓸게요");
    txtList.add("드디어 마지막이다. 5번째 문장");
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getCamera() async {
    // 카메라 목록 받아옴
    final cameras = await availableCameras();
    // 후면 카메라 선택
    late CameraDescription backCamera;
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        backCamera = camera;
        break;
      }
    }

    cameraController = CameraController(backCamera, ResolutionPreset.high);
    cameraController.initialize().then((value) {
      setState(() {
        isCameraInited = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isCameraInited
            ? Container(
                child: Center(
                    child: GestureDetector(
                  child: Container(
                      // 스택
                      child: Stack(children: [
                        // 카메라라
                        Container(
                            // child: CameraPreview(cameraController),
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

                        // 왼쪽 안내
                        Positioned(
                            child: Opacity(
                                opacity: 0.4,
                                child: Container(
                                    child: Text(
                                      "탭: 정지/재생\n더블탭: 한분장 이전으로\n길게: 도움말",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                    color: Colors.black)),
                            bottom:
                                changePercentSizeToPixel(context, 15, false),
                            left: changePercentSizeToPixel(context, 7, true)),

                        // 오른쪽 안내
                        Positioned(
                            child: Opacity(
                                opacity: 0.4,
                                child: Container(
                                    child: Text(
                                      "탭: 재생 속도\n더블탭: 한분장 이후로\n길게: 도움말",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.right,
                                    ),
                                    color: Colors.black)),
                            bottom:
                                changePercentSizeToPixel(context, 15, false),
                            right: changePercentSizeToPixel(context, 7, true)),

                        // 속도 표시
                        Positioned(
                          child: Opacity(
                              opacity: 0.4,
                              child: Container(
                                  child: Text(
                                    "속도: x ${ttsRate}",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  color: Colors.black)),
                          left: changePercentSizeToPixel(context, 45, true),
                          top: changePercentSizeToPixel(context, 15, false),
                        )
                      ]),
                      color: Colors.blue),

                  // 배경 터치
                  onTapDown: (TapDownDetails details) {
                    touchedPos = details.localPosition;
                  },
                  // 한번 터치
                  onTap: () async {
                    double x = touchedPos.dx;
                    // 왼쪽 영역
                    if (x < changePercentSizeToPixel(context, 40, true)) {
                      // 정지
                      if (ttsIsRunninig) {
                        ttsIsRunninig = false;
                        tts.stop();
                      }
                      // 재생
                      else {
                        ttsIsRunninig = true;

                        for (int i = readingIdx; i < txtList.length; i++) {
                          // // 첫 문장일 경우
                          // if (i == 0)
                          //   tts.speak(txtList[i]);
                          // // 딜레이 계산하는 경우
                          // else {
                          //   // 딜레이 계산
                          //   // double delayedTime = 0;
                          //   // for(int j = 0; j < i; j++){
                          //   //   delayedTime += (txtList[j].length * 0.1 * (4-ttsRate));
                          //   // }
                          //   if (ttsIsRunninig)
                          //     await Future.delayed(
                          //         Duration(
                          //           seconds: (txtList[i - 1].length *
                          //                   0.1 *
                          //                   (4 - ttsRate))
                          //               .toInt(),
                          //         ),
                          //         () => tts.speak(txtList[i]));
                          // }
                          // readingIdx = i;
                          await Future.delayed(Duration(seconds: 1), (){tts.speak(txtList[i]);});


                          if (i == txtList.length - 1) readingIdx = 0;
                        }
                        ttsIsRunninig = false;
                      }
                    }

                    // final path = join((await getTemporaryDirectory()).path);
                    // await cameraController.takePicture().then((value){
                    //   imageFile = File(value.path);
                    //   imageSavedPos = imageFile!.path;
                    // });
                    //
                    // // 사진을 촬영하면, 새로운 화면으로 넘어갑니다.
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => DisplayPictureScreen(imageSavedPos),
                    //   ),
                    // );

                    // 오른쪽 영역
                    if (x > changePercentSizeToPixel(context, 60, true)) {
                      setState(() {
                        if (ttsRate == 1.5)
                          ttsRate = 2;
                        else if (ttsRate == 2)
                          ttsRate = 2.5;
                        else if (ttsRate == 2.5)
                          ttsRate = 1;
                        else
                          ttsRate = 1.5;
                      });

                      tts.setRate(ttsRate);
                      tts.stop();
                      if (ttsIsRunninig) tts.speak(helpTxt);
                    }
                  },
                  onDoubleTapDown: (TapDownDetails details) {
                    touchedPos = details.localPosition;
                  },

                  // 더블 터치
                  onDoubleTap: () {
                    double x = touchedPos.dx;
                    // 왼쪽 영역
                    if (x < changePercentSizeToPixel(context, 40, true)) {}
                    // 오른쪽 영역
                    if (x > changePercentSizeToPixel(context, 60, true)) {}
                  },

                  // 꾹 누르기
                  onLongPress: () {
                    double x = touchedPos.dx;
                    // 왼쪽 영역
                    if (x < changePercentSizeToPixel(context, 40, true)) {
                      tts.speak(helpTxt);
                      ttsIsRunninig = true;
                    }
                    // 오른쪽 영역
                    if (x > changePercentSizeToPixel(context, 60, true)) {}
                  },
                )),
                color: Colors.black,
              )
            : Container(
                color: Colors.black,
              ));
  }
}

// 사용자가 촬영한 사진을 보여주는 위젯
class DisplayPictureScreen extends StatelessWidget {
  late String imagePath;

  DisplayPictureScreen(String path) {
    imagePath = path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // 이미지는 디바이스에 파일로 저장됩니다. 이미지를 보여주기 위해 주어진
      // 경로로 `Image.file`을 생성하세요.
      body: Image.file(File(imagePath)),
    );
  }
}
