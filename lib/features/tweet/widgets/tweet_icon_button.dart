// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TweetIconButton extends StatelessWidget {
  const TweetIconButton({
    Key? key,
    required this.pathName,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String pathName;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            pathName,
            color: Palette.greyColor,
          ),
          Container(
            margin: const EdgeInsets.all(6),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
