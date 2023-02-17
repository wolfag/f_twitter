// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:f_twitter/features/tweet/view/hashtag_view.dart';
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HashtagText extends StatelessWidget {
  const HashtagText({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> textSpans = text.split(' ').map(
      (e) {
        if (e.startsWith('#')) {
          return TextSpan(
            text: '$e ',
            style: const TextStyle(
              color: Palette.blueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  HashtagView.route(e),
                );
              },
          );
        }
        if (e.startsWith('www.') ||
            e.startsWith('http://') ||
            e.startsWith('https://')) {
          return TextSpan(
            text: '$e ',
            style: const TextStyle(
              color: Palette.blueColor,
              fontSize: 18,
            ),
          );
        }

        return TextSpan(
          text: '$e ',
          style: const TextStyle(
            fontSize: 18,
          ),
        );
      },
    ).toList();

    return RichText(
      text: TextSpan(children: textSpans),
    );
  }
}
