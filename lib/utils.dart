import 'package:flutter/material.dart';
import 'package:flutter_common_package/flutter_common_package.dart';

Widget button({
  String? text,
  Widget? child,
  Function()? onPressed,
  IconData? icon,
  Color? color,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      primary: color,
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: child ?? Row(
        children: [
          if (icon != null)
            ...[
              Icon(
                icon,
              ),
              16.width
            ],
          Text(
            text ?? '',
          ),
        ],
      ),
    ),
  );
}