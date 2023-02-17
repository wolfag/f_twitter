// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:f_twitter/common/error_page.dart';
import 'package:f_twitter/common/loading_page.dart';
import 'package:f_twitter/constants/constants.dart';
import 'package:f_twitter/features/auth/controller/auth_controller.dart';
import 'package:f_twitter/features/tweet/controller/tweet_controller.dart';
import 'package:f_twitter/features/tweet/utils.dart';
import 'package:f_twitter/features/tweet/widgets/tweet_card.dart';
import 'package:f_twitter/features/user_profile/controller/user_profile_controller.dart';
import 'package:f_twitter/features/user_profile/view/edit_profile_view.dart';
import 'package:f_twitter/features/user_profile/widgets/follow_count.dart';
import 'package:f_twitter/models/models.dart';
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:f_twitter/models/user_model.dart';
import 'package:flutter_svg/svg.dart';

class UserProfile extends ConsumerWidget {
  const UserProfile({
    required this.user,
    super.key,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    final isEdit = currentUser?.uid == user.uid;

    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: user.bannerPic.isEmpty
                            ? Container(
                                color: Palette.blueColor,
                              )
                            : Image.network(
                                user.bannerPic,
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 45,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(20),
                        child: OutlinedButton(
                          onPressed: () {
                            if (isEdit) {
                              Navigator.push(context, EditProfileView.route());
                            } else {
                              ref
                                  .read(userProfileControllerProvider.notifier)
                                  .followUser(
                                    user: user,
                                    currentUser: currentUser,
                                    context: context,
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  color: Palette.whiteColor,
                                )),
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                          ),
                          child: Text(
                            isEdit
                                ? 'Edit Profile'
                                : currentUser.following.contains(user.uid)
                                    ? 'Unfollow'
                                    : 'Follow',
                            style: const TextStyle(
                              color: Palette.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user.isTwitterBlue)
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: SvgPicture.asset(
                                    AssetsConstants.verifiedIcon),
                              ),
                          ],
                        ),
                        Text(
                          '@${user.name}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Palette.greyColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            FollowCount(
                              count: user.followers.length - 1,
                              text: 'Followers',
                            ),
                            const SizedBox(width: 15),
                            FollowCount(
                              count: user.following.length - 1,
                              text: 'Following',
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Divider(color: Palette.whiteColor),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: ref.watch(getUserTweetProvider(user.uid)).when(
              data: (tweets) {
                return ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: (context, int index) {
                    return TweetCard(tweet: tweets[index]);
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
          );
  }
}
