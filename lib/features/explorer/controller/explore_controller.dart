// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:f_twitter/apis/user_api.dart';
import 'package:f_twitter/models/user_model.dart';

final exploreControllerProvider =
    StateNotifierProvider<ExploreController, bool>((ref) {
  return ExploreController(
    userAPI: ref.watch(userAPIProvider),
  );
});

final searchUserProvider = FutureProvider.family((ref, String name) {
  final controller = ref.watch(exploreControllerProvider.notifier);

  return controller.searchUser(name);
});

class ExploreController extends StateNotifier<bool> {
  ExploreController({
    required UserAPI userAPI,
  })  : _userAPI = userAPI,
        super(false);

  final UserAPI _userAPI;

  Future<List<UserModel>> searchUser(String name) async {
    final data = await _userAPI.searchUserByName(name);

    return data.map((e) => UserModel.fromMap(e.data)).toList();
  }
}
