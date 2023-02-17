import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:f_twitter/apis/notification_api.dart';
import 'package:f_twitter/apis/store_api.dart';
import 'package:f_twitter/apis/tweet_api.dart';
import 'package:f_twitter/core/enums/notification_type.dart';
import 'package:f_twitter/core/enums/tweet_type_enum.dart';
import 'package:f_twitter/core/utils.dart';
import 'package:f_twitter/features/auth/controller/auth_controller.dart';
import 'package:f_twitter/features/notifications/controller/notification_controller.dart';
import 'package:f_twitter/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tweetControllerProvider = StateNotifierProvider<TweetController, bool>(
  (ref) {
    return TweetController(
      ref: ref,
      tweetAPI: ref.watch(tweetAPIProvider),
      storageAPI: ref.watch(storageAPIProvider),
      notificationController: ref.watch(notificationControllerProvider),
    );
  },
);

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getTweetsByHashtagProvider = FutureProvider.family((ref, String hashtag) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetsByHashtag(hashtag);
});

final getLatestTweetProvider = StreamProvider((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getLatestTweet();
});

final getRepliesToTweetProvider = FutureProvider.family((
  ref,
  TweetModel tweet,
) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);

  return tweetController.getRepliesToTweet(tweet);
});

final getTweetByIdProvider = FutureProvider.family((
  ref,
  String id,
) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);

  return tweetController.getTweetById(id);
});

class TweetController extends StateNotifier<bool> {
  final Ref _ref;
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final NotificationController _notificationController;

  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required NotificationController notificationController,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<TweetModel>> getTweets() async {
    final docs = await _tweetAPI.getTweets();
    return docs.map((e) => TweetModel.fromMap(e.data)).toList();
  }

  Future<List<TweetModel>> getTweetsByHashtag(String hashtag) async {
    final docs = await _tweetAPI.getTweetsByHashtag(hashtag);
    return docs.map((e) => TweetModel.fromMap(e.data)).toList();
  }

  void shareTweet({
    required BuildContext context,
    required String text,
    required List<File> images,
    required String repliedTo,
    required String repliedToUserId,
  }) {
    if (images.isNotEmpty) {
      _shareImageTweet(
          context: context,
          images: images,
          text: text,
          repliedTo: repliedTo,
          repliedToUserId: repliedToUserId);
    } else {
      _shareTextTweet(
          context: context,
          text: text,
          repliedTo: repliedTo,
          repliedToUserId: repliedToUserId);
    }
  }

  void _shareImageTweet({
    required BuildContext context,
    required List<File> images,
    required String text,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;

    final hashtags = getHashtagsFromText(text);
    String link = getLinkFromText(text);
    final user = _ref.watch(currentUserDetailsProvider).value!;
    final imagesLinks = await _storageAPI.uploadImage(images);

    TweetModel tweet = TweetModel(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imagesLinks,
      uid: user.uid,
      tweetType: TweetType.image,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      retweetedBy: '',
      repliedTo: repliedTo,
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        if (repliedToUserId.isNotEmpty) {
          _notificationController.createNotification(
            text: '${user.name} replied to your tweet!',
            postId: r.$id,
            notificationType: NotificationType.reply,
            uid: repliedToUserId,
          );
        }
      },
    );
  }

  void _shareTextTweet({
    required BuildContext context,
    required String text,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;

    final hashtags = getHashtagsFromText(text);
    String link = getLinkFromText(text);
    final user = _ref.watch(currentUserDetailsProvider).value!;

    TweetModel tweet = TweetModel(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: const [],
      uid: user.uid,
      tweetType: TweetType.text,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      retweetedBy: '',
      repliedTo: repliedTo,
    );

    final res = await _tweetAPI.shareTweet(tweet);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        if (repliedToUserId.isNotEmpty) {
          _notificationController.createNotification(
            text: '${user.name} replied to your tweet!',
            postId: r.$id,
            notificationType: NotificationType.reply,
            uid: repliedToUserId,
          );
        }
      },
    );
  }

  void likeTweet(TweetModel tweet, UserModel user) async {
    List<String> likes = tweet.likes;
    bool isLike = true;
    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
      isLike = false;
    } else {
      likes.add(user.uid);
    }

    tweet = tweet.copyWith(likes: likes);

    _tweetAPI.likeTweet(tweet).then(
          (value) => value.fold(
            (l) => null,
            (r) {
              _notificationController.createNotification(
                text: isLike
                    ? '${user.name} like your tweet!'
                    : '${user.name} unlike your tweet!',
                postId: tweet.id,
                notificationType: NotificationType.like,
                uid: tweet.uid,
              );
            },
          ),
        );
  }

  void reshareTweet(
    TweetModel tweet,
    UserModel currentUser,
    BuildContext context,
  ) async {
    tweet = tweet.copyWith(
      retweetedBy: currentUser.name,
      likes: [],
      commentIds: [],
      reshareCount: tweet.reshareCount + 1,
    );

    _tweetAPI.uploadReshareCount(tweet).then(
      (value) {
        value.fold(
          (l) => showSnackBar(context, l.message),
          (r) async {
            tweet = tweet.copyWith(
              id: ID.unique(),
              reshareCount: 0,
              tweetedAt: DateTime.now(),
            );

            final res = await _tweetAPI.shareTweet(tweet);
            res.fold(
              (l) => showSnackBar(context, l.message),
              (r) {
                showSnackBar(context, 'Retweeted!');
                _notificationController.createNotification(
                  text: '${currentUser.name} reshared your tweet!',
                  postId: tweet.id,
                  notificationType: NotificationType.retweet,
                  uid: tweet.uid,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<TweetModel>> getRepliesToTweet(TweetModel tweet) async {
    final documents = await _tweetAPI.getRepliesToTweet(tweet);

    return documents.map((e) => TweetModel.fromMap(e.data)).toList();
  }

  Future<TweetModel> getTweetById(String id) async {
    final document = await _tweetAPI.getTweetById(id);

    return TweetModel.fromMap(document.data);
  }
}
