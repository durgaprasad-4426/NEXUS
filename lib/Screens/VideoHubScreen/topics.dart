import 'package:flutter/material.dart';

Widget topicCont(Color c1, Color c2, String txt, double screenWidth, double screenHeight) {
  return Container(
    width: (screenWidth<600 ? screenWidth * 0.35 : screenWidth*0.15),
    height: (screenHeight<650 ? screenHeight * 0.1 : screenHeight*0.05),
    decoration: BoxDecoration(
      color: c2,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: c1, width: 1.5),
    ),
    child: Center(
      child: Text(
        txt,
        style: TextStyle(fontSize: 20, color: c1),
      ),
    ),
  );
}
