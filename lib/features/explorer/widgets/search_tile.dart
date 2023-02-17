// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:f_twitter/features/user_profile/view/user_profile_view.dart';
import 'package:f_twitter/theme/palette.dart';
import 'package:flutter/material.dart';

import 'package:f_twitter/models/user_model.dart';

class SearchTile extends StatelessWidget {
  const SearchTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context, UserProfileView.route(user));
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profilePic),
        radius: 30,
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${user.name}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            user.bio,
            style: const TextStyle(
              color: Palette.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
