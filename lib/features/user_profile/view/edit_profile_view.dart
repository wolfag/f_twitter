import 'dart:io';

import 'package:f_twitter/common/loading_page.dart';
import 'package:f_twitter/core/utils.dart';
import 'package:f_twitter/features/auth/controller/auth_controller.dart';
import 'package:f_twitter/features/user_profile/controller/user_profile_controller.dart';
import 'package:f_twitter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  static route() {
    return MaterialPageRoute(
      builder: (context) => const EditProfileView(),
    );
  }

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  File? bannerFile;
  File? profileFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final user = ref.read(currentUserDetailsProvider).value;

    nameController = TextEditingController(text: user?.name ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    bioController.dispose();
  }

  void selectBannerImage() async {
    final banner = await pickImage();
    if (banner != null) {
      setState(() {
        bannerFile = banner;
      });
    }
  }

  void selectProfileImage() async {
    final profileImg = await pickImage();
    if (profileImg != null) {
      setState(() {
        profileFile = profileImg;
      });
    }
  }

  void onSave() async {
    final user = ref.watch(currentUserDetailsProvider).value;

    ref.watch(userProfileControllerProvider.notifier).updateUserData(
          user: user!.copyWith(
            name: nameController.text,
            bio: bioController.text,
          ),
          context: context,
          bannerFile: bannerFile,
          profileFile: profileFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(userProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: onSave,
            child: const Text('Save'),
          ),
        ],
      ),
      body: user == null || isLoading
          ? const Loader()
          : Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: bannerFile != null
                              ? Image.file(
                                  bannerFile!,
                                  fit: BoxFit.fitWidth,
                                )
                              : user.bannerPic.isEmpty
                                  ? Container(
                                      color: Palette.blueColor,
                                    )
                                  : Image.network(
                                      user.bannerPic,
                                      fit: BoxFit.fitWidth,
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: GestureDetector(
                          onTap: selectProfileImage,
                          child: profileFile != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(profileFile!),
                                  radius: 40,
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profilePic),
                                  radius: 40,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    hintText: 'Bio',
                    contentPadding: EdgeInsets.all(18),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
    );
  }
}
