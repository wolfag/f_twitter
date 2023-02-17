import 'package:f_twitter/common/common.dart';
import 'package:f_twitter/common/loading_page.dart';
import 'package:f_twitter/constants/constants.dart';
import 'package:f_twitter/features/auth/controller/auth_controller.dart';
import 'package:f_twitter/features/notifications/controller/notification_controller.dart';
import 'package:f_twitter/features/notifications/widgets/notification_title.dart';
import 'package:f_twitter/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: currentUser == null
          ? const Loader()
          : ref.watch(getNotificationsProvider(currentUser.uid)).when(
              data: (notifications) {
                return ref.watch(getLatestNotificationProvider).when(
                      data: (data) {
                        final latestNoti =
                            NotificationModel.fromMap(data.payload);

                        if (data.events.contains(
                            'databases.*.collections.${AppwriteConstants.notificationsCollection}.documents.*.create')) {
                          if (latestNoti.uid == currentUser.uid) {
                            notifications.insert(
                                0, NotificationModel.fromMap(data.payload));
                          }
                        }
                        return ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return NotificationTitle(
                                notification: notification);
                          },
                        );
                      },
                      error: (error, st) => ErrorText(error: error.toString()),
                      loading: () {
                        return ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return NotificationTitle(
                                notification: notification);
                          },
                        );
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
