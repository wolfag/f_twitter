// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';

class FollowCount extends StatelessWidget {
  const FollowCount({
    Key? key,
    required this.count,
    required this.text,
  }) : super(key: key);

  final int count;
  final String text;

  @override
  Widget build(BuildContext context) {
    double fontSize = 18;

    return Row(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: Palette.whiteColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            color: Palette.greyColor,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
