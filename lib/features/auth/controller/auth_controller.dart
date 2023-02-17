// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:appwrite/models.dart' as model;
import 'package:f_twitter/apis/auth_api.dart';
import 'package:f_twitter/apis/user_api.dart';
import 'package:f_twitter/core/utils.dart';
import 'package:f_twitter/features/auth/view/login_view.dart';
import 'package:f_twitter/features/auth/view/signup_view.dart';
import 'package:f_twitter/features/home/view/home_view.dart';
import 'package:f_twitter/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final currentUserAccountProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

final userDetailsProvider = FutureProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

final currentUserDetailsProvider = FutureProvider((ref) {
  final currentUserId = ref.watch(currentUserAccountProvider).value!.$id;
  final userDetails = ref.watch(userDetailsProvider(currentUserId));
  return userDetails.value;
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  AuthController({
    required AuthAPI authAPI,
    required UserAPI userAPI,
  })  : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(
      email: email,
      password: password,
    );

    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        UserModel userModel = UserModel(
          email: email,
          name: getNameFromEmail(email),
          followers: const [],
          following: const [],
          profilePic: '',
          bannerPic: '',
          uid: r.$id,
          bio: '',
          isTwitterBlue: false,
        );
        final userRes = await _userAPI.saveUserData(userModel);
        userRes.fold(
          (l) => showSnackBar(context, l.message),
          (r) {
            showSnackBar(context, 'Account created! Please login.');
            Navigator.push(context, LoginView.route());
          },
        );
      },
    );
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.login(
      email: email,
      password: password,
    );

    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        Navigator.push(
          context,
          HomeView.route(),
        );
      },
    );
  }

  Future<model.Account?> currentUser() => _authAPI.currentUserAccount();

  Future<UserModel> getUserData(String uid) async {
    final document = await _userAPI.getUserData(uid);
    return UserModel.fromMap(document.data);
  }

  void logout(BuildContext context) async {
    _authAPI.logout().then(
          (value) => value.fold(
            (l) => null,
            (r) {
              Navigator.pushAndRemoveUntil(
                context,
                SignUpView.route(),
                (route) => false,
              );
            },
          ),
        );
  }
}
