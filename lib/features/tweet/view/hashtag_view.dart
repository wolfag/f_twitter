// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:f_twitter/common/error_page.dart';
import 'package:f_twitter/common/loading_page.dart';
import 'package:f_twitter/features/tweet/controller/tweet_controller.dart';
import 'package:f_twitter/features/tweet/widgets/tweet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HashtagView extends ConsumerWidget {
  const HashtagView({
    Key? key,
    required this.hashtag,
  }) : super(key: key);
  final String hashtag;

  static route(String hashtag) {
    return MaterialPageRoute(
      builder: (context) => HashtagView(hashtag: hashtag),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hashtag),
      ),
      body: ref.watch(getTweetsByHashtagProvider(hashtag)).when(
            data: (tweets) {
              return ListView.builder(
                itemCount: tweets.length,
                itemBuilder: (context, index) {
                  return TweetCard(tweet: tweets[index]);
                },
              );
            },
            error: (error, st) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
