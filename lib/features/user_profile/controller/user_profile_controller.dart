// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:f_twitter/apis/store_api.dart';
import 'package:f_twitter/core/enums/notification_type.dart';
import 'package:f_twitter/core/utils.dart';
import 'package:f_twitter/features/notifications/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:f_twitter/apis/tweet_api.dart';
import 'package:f_twitter/apis/user_api.dart';
import 'package:f_twitter/models/models.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
    tweetAPI: ref.watch(tweetAPIProvider),
    userAPI: ref.watch(userAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    notificationController: ref.watch(notificationControllerProvider),
  );
});

final getUserTweetProvider = FutureProvider.family((ref, String uid) {
  final controller = ref.watch(userProfileControllerProvider.notifier);
  return controller.getUserTweets(uid);
});

final getLatestUserProfileProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return userAPI.getLatestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  UserProfileController(
      {required TweetAPI tweetAPI,
      required UserAPI userAPI,
      required StorageAPI storageAPI,
      required NotificationController notificationController})
      : _tweetAPI = tweetAPI,
        _userAPI = userAPI,
        _storageAPI = storageAPI,
        _notificationController = notificationController,
        super(false);

  final TweetAPI _tweetAPI;
  final UserAPI _userAPI;
  final StorageAPI _storageAPI;
  final NotificationController _notificationController;

  Future<List<TweetModel>> getUserTweets(String uid) async {
    final data = await _tweetAPI.getUserTweets(uid);

    return data.map((e) => TweetModel.fromMap(e.data)).toList();
  }

  void updateUserData({
    required UserModel user,
    required BuildContext context,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    state = true;
    if (bannerFile != null) {
      final bannerUrl = await _storageAPI.uploadImage([bannerFile]);
      user = user.copyWith(bannerPic: bannerUrl[0]);
    }
    if (profileFile != null) {
      final profileUrl = await _storageAPI.uploadImage([profileFile]);
      user = user.copyWith(profilePic: profileUrl[0]);
    }

    final res = await _userAPI.updateUserData(user);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Navigator.pop(context),
    );
  }

  void followUser({
    required UserModel user,
    required UserModel currentUser,
    required BuildContext context,
  }) async {
    bool isFollow = true;
    if (currentUser.following.contains(user.uid)) {
      currentUser.following.remove(user.uid);
      user.followers.remove(currentUser.uid);
      isFollow = false;
    } else {
      currentUser.following.add(user.uid);
      user.followers.add(currentUser.uid);
    }

    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(following: currentUser.following);

    _userAPI.followUser(user).then(
          (value) => value.fold(
            (l) => showSnackBar(context, l.message),
            (r) {
              _userAPI.addToFollowing(currentUser).then(
                    (value) => value.fold(
                      (l) => showSnackBar(context, l.message),
                      (r) {
                        _notificationController.createNotification(
                          text:
                              '${currentUser.name} ${isFollow ? 'followed' : 'unfollowed'} you!',
                          postId: '',
                          notificationType: NotificationType.follow,
                          uid: user.uid,
                        );
                      },
                    ),
                  );
            },
          ),
        );
  }
}
