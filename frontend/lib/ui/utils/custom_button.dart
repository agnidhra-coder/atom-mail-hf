import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final double fontSize;
  final EdgeInsets padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.black,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.fontSize = 16.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, color: textColor),
      ),
    );
  }
}