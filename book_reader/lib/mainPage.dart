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

class MyHomePageState extends State<MyHomePage> {
  bool isCameraInited = false; // 카메라 초기화 플래그
  late CameraController cameraController; // 카메라 컨트롤러
  File? imageFile; // 이미지 파일 저장
  String imageSavedPos = ""; // 이미지 파일 저장 경로

  late Offset touchedPos; // 터치 위치 참조

  FlutterTts tts = FlutterTts(); // tts 컨트롤러
  List<double> ttsRateList = [0.5, 0.6, 0.75, 0.9, 0.3]; // 말하기 속도
  String readingTxt = "";
  int ttsRateIdx = 0; // 말하기 속도 위치
  bool ttsIsRunninig = false; // 책 읽고 있는지 플래그

  AudioPlayer audioPlayer = AudioPlayer(); // 음원 효과 재생

  String helpTxt =
      "왼쪽 한번 터치는 정지와 재생. 왼쪽 두번 터치는 한문장 이전으로 이동. 오른쪽 한번 터치는 재생 속도 조절, 오른쪽 두번 터치는 한 문장 다음으로 이동, 오른쪽 길게 터치는 페이지 다시 스캔 입니다. 도움말을 다시 들으려면 왼쪽 영역을 길게 눌러주세요.";

  List<String> txtList = [];
  int readingIdx = 0;

  @override
  void initState() {
    super.initState();
    // 리스트 설정
    splitPage(
        "미국의 작가 E .헤밍웨이(1899∼1961)의 중편소설로 1952년에 발표되었다. 이 작품은 헤밍웨이의 걸작 중의 하나이며, 출판 직후 수백만 부가 팔려 출판 사상 미증유의 기적을 낳기도 했다. 이 작품으로 1954년 노벨문학상을 받았다.  이 작품에서 인간은 상어로 상징되는 죽음에 의하여 패배하지만, 용기와 자기극복(自己克服)으로 과감하게 죽음과 대결하는 데 인간의 존엄성이 있다는 헤밍웨이 나름의 실존철학이 담긴 작품이다. 그의 간결하고 힘찬 문체는 이 작품에서 극치를 이루고 있다.줄거리는 다음과 같다.노인의 이름은 산티아고로 쿠바의 작은 어촌에서 멕시코만을 상대로 고기낚시를 하면서 살아가고 있다. 몸은 야위고 얼굴은 태양빛에 그을었으며, 양 손은 상처의 흔적이 나 있다. 그리고 노인의 작은 배의 돛은 포대 천으로 여기저기 기운 것으로 그것을 마스트에 둘둘 감아놓은 모습은 흡사 패배한 낙오자의 깃발로밖에 보이지 않았다.노인이 젊었을 때는 힘이 장사였으며, 가장 솜씨 좋은 여부였다. 그러나 세월과 더불어 힘과 운세가 다했는지 84일 동안 한 마리의 고기도 낚지 못하고 허송세월하고 있다. 그는 기운이 쇠진했으나, 지난날의 영광을 재현하려고 하는지 눈만은 바다와 같은 색깔이었고, 늘 즐거움과 지칠 줄 모르는 기상이 감돌고 있었다.노인의 화려한 경험 때문인지 그의 놀라운 고기잡이 솜씨를 배우고자 한 소년이 붙어 다녔다. 그러나 노인의 시대가 자났음을 안 소년의 부모는 소년을 다른 배에 옮기게 한다. 그래도 소년은 처음으로 고기 낚는 법을 가르쳐 준 노인에게 지극한 신뢰와 애정을 가지고 노인을 보살펴 준다. 소년은 노인에게 있어서 유일한 말동무이며, 친구이고, 생의 반려자였다.아프리카 밀림에서 노니는 사자 꿈을 꾼 다음날 노인은 다시 바다로 나가기로 결심하고 모든 장비를 꾸려 해가 뜨기 전에 바다로 나갔다. 정오가 훨씬 지난 후에야 낚시를 드리우고 있던 노인은 낚시에 큰 고기가 걸렸음을 알았지만, 고기는 돛단배를 끌고 달아나기 시작했다. 드디어 노인과 고기의 사투(死鬪)가 시작되었다.사흘간의 사투 끝에 고기는 물 위로 떠오르고, 배 옆구리에 고기를 매고는 육지를 향해 귀로에 나선다. 그러나 돌아오는 길에 상어의 공격을 받고, 작살과 칼, 그리고 삿대까지 모두 잃어버리고, 고기는 뼈만 앙상하게 남는다. 그러나 상어들의 절대적인 힘에 원망을 하기보다는 그들의 힘과 당당히 겨룬다.뼈만 앙상하게 남은 고기를 가지고 귀항한 노인은 자신의 오두막에서 깊은 잠에 빠지고, 상처뿐인 노인의 모습을 바라보면서 소년은 눈물을 흘린다. 노인은 고기와 벌인 사투를 소년에게 얘기해 주지만, 노인의 고독을 소년이 이해할 수 없었고, 늙은 자신의 모습을 보면서 인간 행위의 헛된 수고만 생각하게 된다.사실 위에서 본 것처럼 <노인과 바다>의 줄거리는 단순하다. 어부인 한 노인이 84일 동안 아무 것도 잡지 못하다가 85일째 되는 날, 먼 바다로 나가 사흘 동안의 싸움 끝에 큰 청새치를 잡는다. 그러나 돌아오는 길이 너무나 멀어 결국 앙상한 물고기 뼈만 가지고 돌아온다는 이야기다.1954년도 노벨문학상은 그 전해인 1953년도 미국의 퓰리처상을 받은 헤밍웨이에게 주어졌다. 헤밍웨이 하면, 단편으로 <킬리만자로의 눈>, 장편으로는 <누구를 위하여 종은 울리나><무기여 잘 있거라> 등을 생각할 수 있지만, 그가 문명(文名)을 천하에 떨치고 퓰리처상을 받게 된 작품은 <노인과 바다>이다.원고의 분량이나 작품이 풍기는 무게감은 단편이라기보다는 중편에 가깝다. 노인과 소년, 그리고 거대한 고기라는 구성원과 바다와 작은 어촌이라는 한정적인 배경과 함께 간결하고 명쾌한 문장이 돋보이며, 초반부의 노인과 소년의 대화 부분을 제외하고는 거의 노인의 독백으로 구성되어 있다.이 소설은 바다 한 가운데에서의 외로움과 절대 고독에 맞서면서 희망을 잃지 않는 노인의 삶을 그린 작품이다. 고래와 상어와의 싸움의 과정에서 노인이 보여 주는 의지의 모습이 감동을 준다. 이 작품은 황폐하고 불모지 같은 현실에서 올바른 삶의 방향에 대해 탐구하였고, 패배를 모르는 한 노인의 삶을 독백체로 표현하였다. 또한, 이 작품은 1954년 노벨문학상을 받는 계기가 되었다.이 작품에서 인간은 상어로 상징되는 죽음에 의하여 패배하지만, 용기와 자기극복(自己克服)으로 과감하게 죽음과 대결하는 데 인간의 존엄성이 있다는 헤밍웨이 나름의 실존철학이 담겨있다. 그의 간결하고 힘찬 문체는 이 작품에서 극치를 이룬다. 1958년 영화화되었다.그런데 <노인과 바다>가 명작으로 남아 있는 이유가 무엇일까? 진실로 ‘인간다움이란 무엇인가? 인간의 위엄과 존엄성은 무엇으로부터 나오는가?’를 생각게 하는 작품이기 때문일 것이다.소년이 돌아간 뒤에 또다시 잠이 들고 아프리카 사지의 꿈을 꾼다. 영원한 젊음, 영원한 체력의 표상, 그러나 고독한 존재인 사자의 꿈을.");
    for (int i = 0; i < txtList.length; i++) {
      txtList[i] = txtList[i].trim() + ".";
    }

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
                        // Center(child: Container(
                        //   child: CameraPreview(cameraController),
                        // ),),

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
                                      "탭: 정지/재생\n더블탭: 한문장 이전으로\n길게: 도움말",
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
                                      "탭: 재생 속도\n더블탭: 한문장 이후로\n길게: 페이지 스캔",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.right,
                                    ),
                                    color: Colors.black)),
                            bottom:
                                changePercentSizeToPixel(context, 15, false),
                            right: changePercentSizeToPixel(context, 7, true)),

                        // 속도 표시
                        Positioned(
                            child: Column(
                          children: [
                            Center(
                              child: Opacity(
                                  opacity: 0.4,
                                  child: Container(
                                    child: Text(
                                      "속도: x ${ttsRateList[ttsRateIdx]}",
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
                      print("터치_읽기 상태: $ttsIsRunninig");

                      // 정지
                      if (ttsIsRunninig) {
                        tts.stop();
                        ttsStop(tts);
                      }
                      // 재생
                      else {
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
                  },

                  onDoubleTapDown: (TapDownDetails details) {
                    touchedPos = details.localPosition;
                  },

                  // 더블 터치
                  onDoubleTap: () {
                    double x = touchedPos.dx;
                    // 왼쪽 영역
                    if (x < changePercentSizeToPixel(context, 40, true)) {
                      setState(() {
                        if (readingIdx > 0) readingIdx--;
                      });
                    }
                    // 오른쪽 영역
                    if (x > changePercentSizeToPixel(context, 60, true)) {
                      setState(() {
                      if (readingIdx < txtList.length - 1) readingIdx++;

                      });
                    }
                    ttsStop(tts);
                    ttsSpeak(tts, readingTxt);
                  },

                  // 꾹 누르기
                  onLongPress: () async {
                    double x = touchedPos.dx;
                    // 왼쪽 영역
                    if (x < changePercentSizeToPixel(context, 40, true)) {
                      ttsSpeakHelp(tts);
                    }
                    // 오른쪽 영역
                    if (x > changePercentSizeToPixel(context, 60, true)) {
                      scanPage();

                      // // 사진 저장
                      // final path = join((await getTemporaryDirectory()).path);
                      // await cameraController.takePicture().then((value) {
                      //   imageFile = File(value.path);
                      //   imageSavedPos = imageFile!.path;
                      // });

                      // var response = await Dio().get(
                      //     article.urlToImage ?? "",
                      //     options: Options(responseType: ResponseType.bytes));
                      // final result = await ImageGallerySaver.saveImage(
                      //     Uint8List.fromList(imageFile!.readAsBytesSync()),
                      //     quality: 60,
                      //     name: "hello");

                      // Navigator.pop(context);
                      // print(result);
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
  scanPage() async {
    ttsStop(tts);
    await audioPlayer.setSource(AssetSource('notice.mp3'));
    // await audioPlayer.play(AssetSource('notice.mp3'));
    await audioPlayer.setVolume(2);
    await audioPlayer.resume();
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        readingTxt = "페이지 인식중입니다.";
      });
      ttsSpeak(tts, readingTxt);
      tts.setCompletionHandler(() {
        ttsStop(tts);
      });
    });
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
