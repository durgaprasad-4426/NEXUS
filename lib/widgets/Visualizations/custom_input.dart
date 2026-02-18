import 'package:flutter/material.dart';

class CustomOperationInput extends StatelessWidget{
 final TextEditingController valueCtrl;
 final String hintText;
 final Color enableBorderColor;
 final Color focusedBorderColor;

  const CustomOperationInput({super.key, required this.valueCtrl, required this.hintText, required this.enableBorderColor, required this.focusedBorderColor});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: valueCtrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
         hintStyle: TextStyle(color: Colors.grey[300]),
        enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 2, color: enableBorderColor),
        borderRadius: BorderRadius.circular(12)
        ),
        focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 2, color: focusedBorderColor),
        borderRadius: BorderRadius.circular(12)
        ),
        hintText: hintText
      ),
      style: TextStyle(color: Colors.white),
          );
  }
}