// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:f_twitter/constants/assets_constants.dart';
import 'package:f_twitter/core/enums/notification_type.dart';
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';

import 'package:f_twitter/models/models.dart';
import 'package:flutter_svg/svg.dart';

class NotificationTitle extends StatelessWidget {
  const NotificationTitle({
    Key? key,
    required this.notification,
  }) : super(key: key);

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(notification.text),
      leading: notification.notificationType == NotificationType.follow
          ? const Icon(
              Icons.person,
              color: Palette.blueColor,
            )
          : notification.notificationType == NotificationType.like
              ? SvgPicture.asset(
                  AssetsConstants.likeFilledIcon,
                  color: Palette.redColor,
                  height: 20,
                )
              : notification.notificationType == NotificationType.retweet
                  ? SvgPicture.asset(
                      AssetsConstants.retweetIcon,
                      color: Palette.whiteColor,
                      height: 20,
                    )
                  : null,
    );
  }
}
