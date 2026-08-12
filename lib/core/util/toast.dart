import 'package:flutter/material.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const CustomToast({
    Key? key,
    required this.message,
    this.backgroundColor = Colors.black87,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message,
          style:
              textStyle ?? const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

void showToast(
  BuildContext context,
  String message, {
  Color backgroundColor = Colors.black87,
  TextStyle? textStyle,
  Duration duration = const Duration(seconds: 2),
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  ),
}) {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 60.0,
      left: 24.0,
      right: 24.0,
      child: Center(
        child: CustomToast(
          message: message,
          backgroundColor: backgroundColor,
          textStyle: textStyle,
          padding: padding,
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
