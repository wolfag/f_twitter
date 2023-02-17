// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:f_twitter/common/error_page.dart';
import 'package:f_twitter/common/loading_page.dart';
import 'package:f_twitter/constants/appwrite_constants.dart';
import 'package:f_twitter/features/tweet/controller/tweet_controller.dart';
import 'package:f_twitter/features/tweet/utils.dart';
import 'package:f_twitter/features/tweet/widgets/tweet_card.dart';
import 'package:flutter/material.dart';

import 'package:f_twitter/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TwitterReplyScreen extends ConsumerWidget {
  const TwitterReplyScreen({
    Key? key,
    required this.tweet,
  }) : super(key: key);

  final TweetModel tweet;

  static route(TweetModel tweet) {
    return MaterialPageRoute(
      builder: (context) {
        return TwitterReplyScreen(
          tweet: tweet,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tweet'),
        ),
        body: Column(
          children: [
            TweetCard(tweet: tweet),
            ref.watch(getRepliesToTweetProvider(tweet)).when(
              data: (tweets) {
                return ref.watch(getLatestTweetProvider).when(
                      data: (data) {
                        final latestTweet = TweetModel.fromMap(data.payload);
                        final isLatestTweetExist =
                            isTweetExist(tweets, latestTweet);

                        if (latestTweet.repliedTo == tweet.id &&
                            !isLatestTweetExist) {
                          if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.create')) {
                            tweets.insert(0, TweetModel.fromMap(data.payload));
                          } else if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetsCollection}.documents.*.update')) {
                            final tweet = TweetModel.fromMap(data.payload);
                            tweets[tweets.indexWhere(
                                (element) => element.id == tweet.id)] = tweet;
                          }
                        }
                        return Expanded(
                          child: ListView.builder(
                            itemCount: tweets.length,
                            itemBuilder: (context, index) {
                              final tweet = tweets[index];
                              return TweetCard(
                                tweet: tweet,
                              );
                            },
                          ),
                        );
                      },
                      error: (error, st) => ErrorText(error: error.toString()),
                      loading: () {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: tweets.length,
                            itemBuilder: (context, index) {
                              final tweet = tweets[index];
                              return TweetCard(
                                tweet: tweet,
                              );
                            },
                          ),
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
            ),
          ],
        ),
        bottomNavigationBar: TextField(
          onSubmitted: (value) {
            ref.read(tweetControllerProvider.notifier).shareTweet(
                  context: context,
                  text: value,
                  images: [],
                  repliedTo: tweet.id,
                  repliedToUserId: tweet.uid,
                );
          },
          decoration: const InputDecoration(
            hintText: 'Tweet your reply',
          ),
        ),
      ),
    );
  }
}
