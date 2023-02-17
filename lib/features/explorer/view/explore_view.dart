import 'package:f_twitter/common/error_page.dart';
import 'package:f_twitter/common/loading_page.dart';
import 'package:f_twitter/features/explorer/controller/explore_controller.dart';
import 'package:f_twitter/features/explorer/widgets/search_tile.dart';
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreView extends ConsumerStatefulWidget {
  const ExploreView({super.key});

  @override
  ConsumerState<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  final searchController = TextEditingController();

  bool isShow = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderSearchBox = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(
        color: Palette.searchBarColor,
      ),
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            height: 50,
            child: TextField(
              controller: searchController,
              onSubmitted: (value) {
                setState(() {
                  isShow = true;
                });
              },
              decoration: InputDecoration(
                fillColor: Palette.searchBarColor,
                filled: true,
                enabledBorder: borderSearchBox,
                focusedBorder: borderSearchBox,
                hintText: 'Search Twitter',
                contentPadding: const EdgeInsets.all(10).copyWith(left: 20),
              ),
            ),
          ),
        ),
        body: isShow
            ? ref.watch(searchUserProvider(searchController.text)).when(
                data: (users) {
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return SearchTile(user: user);
                    },
                  );
                },
                error: (error, st) {
                  return ErrorText(error: error.toString());
                },
                loading: () {
                  return const Loader();
                },
              )
            : const SizedBox(),
      ),
    );
  }
}
