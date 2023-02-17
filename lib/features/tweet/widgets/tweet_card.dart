// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:any_link_preview/any_link_preview.dart';
import 'package:f_twitter/common/error_page.dart';
import 'package:f_twitter/common/loading_page.dart';
import 'package:f_twitter/constants/assets_constants.dart';
import 'package:f_twitter/core/enums/tweet_type_enum.dart';
import 'package:f_twitter/features/auth/controller/auth_controller.dart';
import 'package:f_twitter/features/tweet/controller/tweet_controller.dart';
import 'package:f_twitter/features/tweet/view/twitter_reply_view.dart';
import 'package:f_twitter/features/tweet/widgets/carousel_image.dart';
import 'package:f_twitter/features/tweet/widgets/hashtag_text.dart';
import 'package:f_twitter/features/tweet/widgets/tweet_icon_button.dart';
import 'package:f_twitter/features/user_profile/view/user_profile_view.dart';
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';

import 'package:f_twitter/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;

class TweetCard extends ConsumerWidget {
  const TweetCard({
    Key? key,
    required this.tweet,
  }) : super(key: key);
  final TweetModel tweet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const SizedBox()
        : ref.watch(userDetailsProvider(tweet.uid)).when(
            data: (user) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    TwitterReplyScreen.route(tweet),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: (() {
                              Navigator.push(
                                context,
                                UserProfileView.route(user),
                              );
                            }),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 35,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tweet.retweetedBy.isNotEmpty)
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      AssetsConstants.retweetIcon,
                                      color: Palette.greyColor,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${tweet.retweetedBy} retweeted',
                                      style: const TextStyle(
                                        color: Palette.greyColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: user.isTwitterBlue ? 1 : 5),
                                    child: Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                      ),
                                    ),
                                  ),
                                  if (user.isTwitterBlue)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: SvgPicture.asset(
                                          AssetsConstants.verifiedIcon),
                                    ),
                                  Text(
                                    '@${user.name} - ${timeago.format(
                                      tweet.tweetedAt,
                                      locale: 'en_short',
                                    )}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Palette.greyColor,
                                    ),
                                  )
                                ],
                              ),
                              if (tweet.repliedTo.isNotEmpty)
                                ref
                                    .watch(
                                        getTweetByIdProvider(tweet.repliedTo))
                                    .when(
                                  data: (data) {
                                    final replyingToUser = ref
                                        .watch(userDetailsProvider(data.uid))
                                        .value;

                                    return RichText(
                                      text: TextSpan(
                                        text: 'Replying to ',
                                        style: const TextStyle(
                                          color: Palette.greyColor,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                '@${replyingToUser?.name ?? ''}',
                                            style: const TextStyle(
                                              color: Palette.blueColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  error: (error, stackTrace) {
                                    return ErrorText(error: error.toString());
                                  },
                                  loading: () {
                                    return const SizedBox();
                                  },
                                ),
                              HashtagText(text: tweet.text),
                              if (tweet.tweetType == TweetType.image)
                                CarouselImage(
                                  imageLinks: tweet.imageLinks,
                                ),
                              if (tweet.link.isNotEmpty) ...[
                                const SizedBox(
                                  height: 4,
                                ),
                                AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: 'https://${tweet.link}',
                                )
                              ],
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 10, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TweetIconButton(
                                      pathName: AssetsConstants.viewsIcon,
                                      text: (tweet.commentIds.length +
                                              tweet.reshareCount +
                                              tweet.likes.length)
                                          .toString(),
                                      onTap: (() {}),
                                    ),
                                    TweetIconButton(
                                      pathName: AssetsConstants.commentIcon,
                                      text:
                                          (tweet.commentIds.length).toString(),
                                      onTap: (() {}),
                                    ),
                                    TweetIconButton(
                                      pathName: AssetsConstants.retweetIcon,
                                      text: (tweet.reshareCount).toString(),
                                      onTap: (() {
                                        ref
                                            .watch(tweetControllerProvider
                                                .notifier)
                                            .reshareTweet(
                                              tweet,
                                              currentUser,
                                              context,
                                            );
                                      }),
                                    ),
                                    LikeButton(
                                      size: 25,
                                      onTap: (isLiked) async {
                                        ref
                                            .watch(tweetControllerProvider
                                                .notifier)
                                            .likeTweet(tweet, currentUser);
                                        return !isLiked;
                                      },
                                      isLiked:
                                          tweet.likes.contains(currentUser.uid),
                                      likeBuilder: (isLiked) {
                                        return isLiked
                                            ? SvgPicture.asset(
                                                AssetsConstants.likeFilledIcon,
                                                color: Palette.redColor,
                                              )
                                            : SvgPicture.asset(
                                                AssetsConstants
                                                    .likeOutlinedIcon,
                                                color: Palette.greyColor,
                                              );
                                      },
                                      likeCount: tweet.likes.length,
                                      countBuilder: (likeCount, isLiked, text) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              color: isLiked
                                                  ? Palette.redColor
                                                  : Palette.whiteColor,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.share_outlined,
                                        size: 25,
                                        color: Palette.greyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 1),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Divider(color: Palette.greyColor),
                  ],
                ),
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
