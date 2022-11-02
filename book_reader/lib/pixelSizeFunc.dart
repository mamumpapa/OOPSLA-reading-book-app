// 백분율 -> 픽셀 크기로 변환해주는 함수
import 'package:flutter/cupertino.dart';

double changePercentSizeToPixel(BuildContext context, double percent, bool isWidth){
  if(percent < 0 || percent > 100)
    return 0;
  // 디바이스 가로세로 크기
  double deviceHeight = MediaQuery.of(context).size.height;
  double deviceWidth = MediaQuery.of(context).size.width;
  // double deviceWidth = deviceHeight * 16 / 9;

  if(isWidth){
    print(percent * deviceWidth / 100);
    return percent * deviceWidth / 100;
  }
  else{
    print(percent * deviceWidth / 100);
    return percent * deviceHeight / 100;
  }
}