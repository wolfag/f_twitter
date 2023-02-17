import 'package:f_twitter/constants/assets_constants.dart';
import 'package:f_twitter/constants/ui_constants.dart';
import 'package:f_twitter/features/home/widgets/side_drawer.dart';
import 'package:f_twitter/features/tweet/view/create_tweet_view.dart';
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static route() => MaterialPageRoute(
        builder: (context) => const HomeView(),
      );

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final appBar = UIConstants.appBar();
  int _pageIndex = 0;

  void onPageChange(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  void onCreateTweet() {
    Navigator.push(context, CreateTweetView.route());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _pageIndex == 0 ? appBar : null,
      body: IndexedStack(
        index: _pageIndex,
        children: UIConstants.bottomTabBarPages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCreateTweet,
        child: const Icon(
          Icons.add,
          color: Palette.whiteColor,
          size: 28,
        ),
      ),
      drawer: const SideDrawer(),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _pageIndex,
        onTap: onPageChange,
        backgroundColor: Palette.backgroundColor,
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AssetsConstants.homeOutlinedIcon,
                color: Palette.whiteColor,
              ),
              activeIcon: SvgPicture.asset(
                AssetsConstants.homeFilledIcon,
                color: Palette.whiteColor,
              )),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.searchIcon,
              color: Palette.whiteColor,
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.notifOutlinedIcon,
              color: Palette.whiteColor,
            ),
            activeIcon: SvgPicture.asset(
              AssetsConstants.notifFilledIcon,
              color: Palette.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
