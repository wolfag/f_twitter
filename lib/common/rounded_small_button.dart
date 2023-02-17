// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';

class RoundedSmallButton extends StatelessWidget {
  const RoundedSmallButton({
    Key? key,
    required this.onTap,
    required this.label,
    this.backgroundColor = Palette.whiteColor,
    this.textColor = Palette.backgroundColor,
  }) : super(key: key);

  final VoidCallback onTap;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        labelPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
      ),
    );
  }
}
