// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:f_twitter/core/enums/notification_type.dart';
import 'package:f_twitter/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:f_twitter/apis/notification_api.dart';

final notificationControllerProvider = Provider((ref) {
  return NotificationController(
    notificationAPI: ref.watch(notificationAPIProvider),
  );
});

final getLatestNotificationProvider = StreamProvider((ref) {
  final notificationAPI = ref.watch(notificationAPIProvider);
  return notificationAPI.getLatestNotification();
});

final getNotificationsProvider = FutureProvider.family((ref, String uid) {
  final controller = ref.watch(notificationControllerProvider);

  return controller.getNotifications(uid);
});

class NotificationController extends StateNotifier<bool> {
  final NotificationAPI _notificationAPI;

  NotificationController({
    required NotificationAPI notificationAPI,
  })  : _notificationAPI = notificationAPI,
        super(false);

  void createNotification({
    required String text,
    required String postId,
    required NotificationType notificationType,
    required String uid,
  }) {
    final notification = NotificationModel(
      text: text,
      postId: postId,
      id: '',
      uid: uid,
      notificationType: notificationType,
    );

    _notificationAPI
        .createNotification(notification)
        .then((value) => value.fold((l) => print(l.message), (r) => null));
  }

  Future<List<NotificationModel>> getNotifications(String uid) async {
    final notifications = await _notificationAPI.getNotifications(uid);

    return notifications.map((e) => NotificationModel.fromMap(e.data)).toList();
  }
}
