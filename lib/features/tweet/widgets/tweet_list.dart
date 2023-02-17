import 'package:f_twitter/common/error_page.dart';
import 'package:f_twitter/common/loading_page.dart';
import 'package:f_twitter/constants/appwrite_constants.dart';
import 'package:f_twitter/features/tweet/controller/tweet_controller.dart';
import 'package:f_twitter/features/tweet/widgets/tweet_card.dart';
import 'package:f_twitter/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getTweetsProvider).when(
      data: (tweets) {
        return ref.watch(getLatestTweetProvider).when(
              data: (data) {
                if (data.events.contains(
                    'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.create')) {
                  tweets.insert(0, TweetModel.fromMap(data.payload));
                } else if (data.events.contains(
                    'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.update')) {
                  final tweet = TweetModel.fromMap(data.payload);
                  tweets[tweets
                      .indexWhere((element) => element.id == tweet.id)] = tweet;
                }
                return ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = tweets[index];
                    return TweetCard(
                      tweet: tweet,
                    );
                  },
                );
              },
              error: (error, st) => ErrorText(error: error.toString()),
              loading: () {
                return ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = tweets[index];
                    return TweetCard(
                      tweet: tweet,
                    );
                  },
                );
              },
            );
      },
      error: (error, st) {
        return ErrorText(error: error.toString());
      },
      loading: () {
        return const Loader();
      },
    );
  }
}
