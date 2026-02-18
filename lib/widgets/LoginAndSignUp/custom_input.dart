import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget{
  final TextEditingController ctrl;
  final bool isPassField;
  final String hintText;
  final String? Function(String?)? validator;
  final double width;
  const CustomInput({super.key, required this.ctrl, required this.hintText, this.validator, required this.width, this.isPassField = false});

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool show  = false;
  @override
  Widget build(BuildContext context) {
    
   return Container(
                   width: widget.width,
                   decoration: BoxDecoration(
                    //  color: Colors.black54,
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: TextFormField(
                    
                     obscureText: show,
                     controller: widget.ctrl,
                     decoration: InputDecoration(
                      fillColor: Colors.black,
                       hintText: widget.hintText, 
                       
                       suffixIcon: widget.isPassField ? 
                       IconButton(icon: Icon(show ?Icons.visibility: Icons.visibility_off_outlined),
                       onPressed: (){
                        setState(() {
                          show = !show;
                        });
                       }, 
                       ) : null,
                       suffixIconColor: Colors.white54,
                       focusedBorder:OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(
                           color: Colors.lightBlueAccent,
                           width: 2,
                         )
   
                       ) ,
                       focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(
                           color: Colors.lightBlueAccent,
                           width: 2,
                         )
                       ),
                       errorBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(
                           color: const Color.fromARGB(255, 136, 19, 10),
                           width: 2,
                         )
                       ),
                       enabledBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide(
                           color: Colors.grey,
                           width: 2,
                         )
                       )
                       ),
                       style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14
                       ),
                     validator: widget.validator,
                     
                   ),
                 );
  }
}