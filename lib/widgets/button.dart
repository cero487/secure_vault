import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final double radius;
  final String text;
  const Button({super.key, required this.height, required this.width, required this.color, required this.radius, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius)
      ),
      child: Center(child: Text(text,style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),)),
    );
  }
}