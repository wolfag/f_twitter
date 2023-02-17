import 'package:f_twitter/features/explorer/view/explore_view.dart';
import 'package:f_twitter/features/notifications/view/notification_view.dart';
import 'package:f_twitter/features/tweet/widgets/tweet_list.dart';
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'constants.dart';

class UIConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.twitterLogo,
        color: Palette.blueColor,
        height: 30,
      ),
      centerTitle: true,
    );
  }

  static List<Widget> bottomTabBarPages = [
    TweetList(),
    ExploreView(),
    NotificationView(),
  ];
}
