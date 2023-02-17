// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:f_twitter/common/error_page.dart';
import 'package:f_twitter/constants/constants.dart';
import 'package:f_twitter/features/user_profile/controller/user_profile_controller.dart';
import 'package:f_twitter/features/user_profile/widgets/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:f_twitter/models/user_model.dart';

class UserProfileView extends ConsumerWidget {
  const UserProfileView({
    required this.user,
    super.key,
  });

  final UserModel user;

  static route(UserModel user) {
    return MaterialPageRoute(
      builder: (context) => UserProfileView(
        user: user,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = user;

    return Scaffold(
      body: ref.watch(getLatestUserProfileProvider).when(
            data: (data) {
              if (data.events.contains(
                'databases.*.collections.${AppwriteConstants.usersCollection}.documents.${copyOfUser.uid}.update',
              )) {
                copyOfUser = UserModel.fromMap(data.payload);
              }
              return UserProfile(user: copyOfUser);
            },
            error: (error, st) => ErrorText(error: error.toString()),
            loading: () => UserProfile(user: copyOfUser),
          ),
    );
  }
}
