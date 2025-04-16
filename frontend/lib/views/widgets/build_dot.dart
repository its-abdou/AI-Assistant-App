import 'package:flutter/material.dart';

class BuildDot extends StatelessWidget {
  const BuildDot({super.key , required this.color , required this.size});

 final Color color;
 final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
    ));
  }
}
