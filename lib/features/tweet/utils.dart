import 'package:f_twitter/models/tweet_model.dart';

bool isTweetExist(List<TweetModel> list, TweetModel tweet) {
  for (final t in list) {
    if (t.id == tweet.id) {
      return true;
    }
  }

  return false;
}
