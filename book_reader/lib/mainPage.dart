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

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';

import 'package:audioplayers/audioplayers.dart';

// 소켓통신
// import 'package:flutter/foundation.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

class MyHomePageState extends State<MyHomePage> {
  bool canTouch = true;
  bool isCameraInited = false; // 카메라 초기화 플래그
  late CameraController cameraController; // 카메라 컨트롤러
  File? imageFile; // 이미지 파일 저장
  String imageSavedPos = ""; // 이미지 파일 저장 경로

  late Offset touchedPos; // 터치 위치 참조

  FlutterTts tts = FlutterTts(); // tts 컨트롤러
  List<double> ttsRateList = [0.5, 0.6, 0.75, 1, 0.25]; // 말하기 속도
  String readingTxt = "";
  int ttsRateIdx = 0; // 말하기 속도 위치
  bool ttsIsRunninig = false; // 책 읽고 있는지 플래그
  List<String> txtList = [];
  int readingIdx = 0;

  AudioPlayer audioPlayer = AudioPlayer(); // 음원 효과 재생

  String helpTxt =
      "왼쪽 한번 터치는 정지와 재생. 왼쪽 두번 터치는 한문장 이전으로 이동. 오른쪽 한번 터치는 재생 속도 조절, 오른쪽 두번 터치는 한 문장 다음으로 이동, 오른쪽 길게 터치는 페이지 다시 스캔 입니다. 도움말을 다시 들으려면 왼쪽 영역을 길게 눌러주세요.";

  String serverIP = 'http://220.69.208.115:8000/page/';

  @override
  void initState() {
    super.initState();
    // 리스트 설정

    // tts 설정
    tts.setLanguage('kr');
    tts.setSpeechRate(ttsRateList[ttsRateIdx]);
    ttsSpeakHelp(tts);

    getCamera(); // 카메라 초기화

    // 효과음 설정
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

    cameraController = CameraController(backCamera, ResolutionPreset.max);
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
                        // 카메라
                        Center(
                          child: Container(
                            child: CameraPreview(cameraController),
                          ),
                        ),

                        // ROI 박스(상단)
                        Positioned(
                            child: Divider(
                              color: Colors.red,
                              thickness: 2,
                            ),
                            height: 1,
                            width: changePercentSizeToPixel(context, 70, true),
                            top: changePercentSizeToPixel(context, 10, false),
                            left: changePercentSizeToPixel(context, 15, true)),

                        // ROI 박스(하단)
                        Positioned(
                            child: Divider(
                              color: Colors.red,
                              thickness: 2,
                            ),
                            height: 1,
                            width: changePercentSizeToPixel(context, 70, true),
                            bottom:
                                changePercentSizeToPixel(context, 10, false),
                            left: changePercentSizeToPixel(context, 15, true)),

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
                            left: changePercentSizeToPixel(context, 15, true)),

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
                            right: changePercentSizeToPixel(context, 15, true)),

                        // 왼쪽 안내
                        Positioned(
                            child: Opacity(
                                opacity: 0.4,
                                child: Container(
                                    child: Text(
                                      "탭: 정지/재생\n더블탭: 한문장 이전으로\n길게: 도움말",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                    color: Colors.black)),
                            bottom:
                                changePercentSizeToPixel(context, 15, false),
                            left: changePercentSizeToPixel(context, 16, true)),

                        // 오른쪽 안내
                        Positioned(
                            child: Opacity(
                                opacity: 0.4,
                                child: Container(
                                    child: Text(
                                      "탭: 재생 속도\n더블탭: 한문장 이후로\n길게: 페이지 스캔",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.right,
                                    ),
                                    color: Colors.black)),
                            bottom:
                                changePercentSizeToPixel(context, 15, false),
                            right: changePercentSizeToPixel(context, 16, true)),

                        // 속도 표시
                        Positioned(
                            child: Column(
                          children: [
                            Center(
                              child: Opacity(
                                  opacity: 0.4,
                                  child: Container(
                                    child: Text(
                                      "속도: x ${ttsRateList[ttsRateIdx] * 2}",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    color: Colors.black,
                                    margin: EdgeInsets.only(
                                        top: changePercentSizeToPixel(
                                            context, 15, false)),
                                  )),
                            ),
                          ],
                        )),

                        // 읽고 있는 문장
                        Center(
                            child: Container(
                          child: Stack(
                            children: [
                              Center(
                                child: Opacity(
                                  opacity: 0.4,
                                  child: Container(
                                    child: Text(
                                      ttsIsRunninig
                                          ? readingTxt +
                                              "\n(${readingIdx + 1}/${txtList.length})"
                                          : "",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    color: Colors.black,
                                    // width: changePercentSizeToPixel(context, 60, true),
                                  ),
                                ),
                              )
                            ],
                          ),
                          width: changePercentSizeToPixel(context, 60, true),
                        ))
                      ]),
                      color: Colors.black),

                  // 배경 터치
                  onTapDown: (TapDownDetails details) {
                    touchedPos = details.localPosition;
                  },
                  // 한번 터치
                  onTap: () async {
                    if(canTouch){
                      double x = touchedPos.dx;
                      // 왼쪽 영역
                      if (x < changePercentSizeToPixel(context, 40, true)) {
                        print("터치_읽기 상태: $ttsIsRunninig");

                        // 정지
                        if (ttsIsRunninig) {
                          tts.stop();
                          ttsStop(tts);
                        }
                        // 재생
                        else {
                          readPage();
                        }
                      }

                      // 오른쪽 영역
                      if (x > changePercentSizeToPixel(context, 60, true)) {
                        setState(() {
                          if (ttsRateIdx < 4)
                            ttsRateIdx++;
                          else
                            ttsRateIdx = 0;
                        });

                        tts.setSpeechRate(ttsRateList[ttsRateIdx]);
                        if (ttsIsRunninig) {
                          ttsStop(tts);
                          ttsSpeak(tts, readingTxt);
                        }
                      }
                    }

                  },

                  onDoubleTapDown: (TapDownDetails details) {
                    touchedPos = details.localPosition;
                  },

                  // 더블 터치
                  onDoubleTap: () {
                    if(canTouch){
                      double x = touchedPos.dx;
                      // 왼쪽 영역
                      if (x < changePercentSizeToPixel(context, 40, true)) {
                        setState(() {
                          if (readingIdx > 0) readingIdx--;
                          readingTxt = txtList[readingIdx];
                        });
                      }
                      // 오른쪽 영역
                      if (x > changePercentSizeToPixel(context, 60, true)) {
                        setState(() {
                          if (readingIdx < txtList.length - 1) readingIdx++;
                          readingTxt = txtList[readingIdx];
                        });
                      }
                      ttsStop(tts);
                      ttsSpeak(tts, readingTxt);
                    }
                  },

                  // 꾹 누르기
                  onLongPress: () async {
                    if(canTouch){
                      double x = touchedPos.dx;
                      // 왼쪽 영역
                      if (x < changePercentSizeToPixel(context, 40, true)) {
                        ttsSpeakHelp(tts);
                      }
                      // 오른쪽 영역
                      if (x > changePercentSizeToPixel(context, 60, true)) {

                        canTouch = false;
                        ttsStop(tts);
                        await audioPlayer.setSource(AssetSource('notice.mp3'));
                        // await audioPlayer.play(AssetSource('notice.mp3'));
                        await audioPlayer.setVolume(2);
                        await audioPlayer.resume();
                        audioPlayer.onPlayerComplete.listen((event) {
                          setState(() {
                            readingTxt = "페이지 인식중입니다.";
                            ttsSpeak(tts, readingTxt);
                          });
                          tts.setCompletionHandler(() {
                            ttsStop(tts);
                            scanPage(context).then((value){
                              if(value < 10){
                                ttsSpeak(tts, '페이지가 인식되지 않았습니다. 카메라를 조정한 후 다시 인식 시켜주세요.');
                                tts.setCompletionHandler(() {
                                  ttsStop(tts);
                                });
                              }
                              else{
                                readPage();
                              }
                              canTouch = true;
                            });
                          });
                        });




                      }
                    }

                  },
                )),
                color: Colors.black,
              )
            : Container(
                color: Colors.black,
              ));
  }

  // tts speak 메소드
  Future ttsSpeak(FlutterTts tts, String txt) async {
    var result = await tts.speak(txt);
    if (result == 1) setState(() => ttsIsRunninig = true);
  }

  // tts stop 메소드
  Future ttsStop(FlutterTts tts) async {
    var result = await tts.stop();
    setState(() => ttsIsRunninig = false);
  }

  // 재생 메소드
  void readPage(){
    if (readingIdx < txtList.length) {
      setState(() {
        readingTxt = txtList[readingIdx];
      });
      ttsSpeak(tts, readingTxt);
      tts.setCompletionHandler(() {
        // 한 문장 다 읽으면 다음문장 읽기
        if (readingIdx < txtList.length - 1) {
          setState(() {
            readingIdx += 1;
            readingTxt = txtList[readingIdx];
          });
          print("인덱스: $readingIdx, ${txtList.length}");
          Future.delayed(Duration(milliseconds: 500),
                  () => ttsSpeak(tts, readingTxt));
        } else {
          ttsStop(tts);
          print("안쪽정지, 상태$ttsIsRunninig");
          readingIdx = 0;
        }
      });
    } else {
      ttsStop(tts);
      print("바깥쪽정지, 상태$ttsIsRunninig");
      readingIdx = 0;
    }
  }

  // 도움말 읽는 메소드
  Future ttsSpeakHelp(FlutterTts tts) async {
    setState(() {
      readingTxt = helpTxt;
    });
    var result = await tts.speak(readingTxt);
    if (result == 1) setState(() => ttsIsRunninig = true);
    // 다 읽으면 상태 전환
    tts.setCompletionHandler(() {
      setState(() {
        ttsIsRunninig = false;
      });
    });
  }

  // 책 스캔
  Future<int> scanPage(BuildContext context) async {


    final path = join((await getTemporaryDirectory()).path);
    await cameraController.takePicture().then((value) {
      imageFile = File(value.path);
      imageSavedPos = imageFile!.path;
    });

    String fullTxt="";
    await scanImage(imageFile).then((value) {
      fullTxt = value;
      readingTxt = value;
      splitPage(readingTxt);
      // readingTxt = '';
      readingIdx = 0;
      ttsStop(tts);
      // 문장 뒤에 점 추가
      for (int i = 0; i < txtList.length; i++) {
        txtList[i] = txtList[i].trim() + ".";
      }
    });
    return fullTxt.length;
  }

  // post 메소드
  Future<String> scanImage(var imgFile) async {
    FormData formData = FormData.fromMap(
        {'image': await MultipartFile.fromFile(imgFile!.path)});

    var dio = new Dio();
    var response = await dio.post(serverIP, data: formData);

    return response.data;
  }

  // 책 전체 페이지를 리스트로 분할
  void splitPage(String txt) {
    txtList = txt.split('.');
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
