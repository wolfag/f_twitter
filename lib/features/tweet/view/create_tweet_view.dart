import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:f_twitter/common/common.dart';
import 'package:f_twitter/constants/assets_constants.dart';
import 'package:f_twitter/core/utils.dart';
import 'package:f_twitter/features/auth/controller/auth_controller.dart';
import 'package:f_twitter/features/tweet/controller/tweet_controller.dart';
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class CreateTweetView extends ConsumerStatefulWidget {
  const CreateTweetView({super.key});

  static route() => MaterialPageRoute(
        builder: (context) => const CreateTweetView(),
      );

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTweetViewState();
}

class _CreateTweetViewState extends ConsumerState<CreateTweetView> {
  final tweetTextController = TextEditingController();
  List<File> images = [];

  @override
  void dispose() {
    super.dispose();
    tweetTextController.dispose();
  }

  void onPickImages() async {
    images = await pickImages();
    setState(() {});
  }

  void shareTweet() {
    ref.read(tweetControllerProvider.notifier).shareTweet(
          context: context,
          text: tweetTextController.text,
          images: images,
          repliedTo: '',
          repliedToUserId: '',
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    final tweetLoading = ref.watch(tweetControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            size: 30,
          ),
        ),
        actions: [
          RoundedSmallButton(
            onTap: shareTweet,
            label: 'Tweet',
            backgroundColor: Palette.blueColor,
            textColor: Palette.whiteColor,
          ),
        ],
      ),
      body: currentUser == null || tweetLoading
          ? const Loader()
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(currentUser.profilePic),
                          radius: 30,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: tweetTextController,
                            style: const TextStyle(
                              fontSize: 22,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'What`s happening?',
                              hintStyle: TextStyle(
                                color: Palette.greyColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                    if (images.isNotEmpty)
                      CarouselSlider(
                        items: images.map((file) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Image.file(file),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 400,
                          enableInfiniteScroll: false,
                        ),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Palette.greyColor,
              width: 0.3,
            ),
          ),
        ),
        margin: const EdgeInsets.only(bottom: 15),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(
                left: 15,
                right: 15,
              ),
              child: GestureDetector(
                onTap: onPickImages,
                child: SvgPicture.asset(
                  AssetsConstants.galleryIcon,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(
                left: 15,
                right: 15,
              ),
              child: SvgPicture.asset(
                AssetsConstants.gifIcon,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(
                left: 15,
                right: 15,
              ),
              child: SvgPicture.asset(
                AssetsConstants.emojiIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
