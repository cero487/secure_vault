import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final Color iconcolor;
  final double radius;
  final IconData icon;
  final double size;
  const MyIconButton({super.key, required this.height, required this.width, required this.color, required this.radius, required this.icon, required this.iconcolor, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius)
      ),
      child: Center(child: Icon(icon, color: iconcolor,size: size,)),
    );
  }
}