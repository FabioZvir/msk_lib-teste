import 'package:flutter/material.dart';
import 'package:msk_widgets/msk_widgets.dart';

class LineWidget extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? padding;

  const LineWidget({this.padding, this.height = 0.5});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Container(
        height: height,
        width: double.maxFinite,
        color: isDarkMode(context) ? Colors.white : Colors.grey,
      ),
    );
  }
}
