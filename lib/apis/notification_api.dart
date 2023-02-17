// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:f_twitter/constants/appwrite_constants.dart';

import 'package:f_twitter/core/core.dart';
import 'package:f_twitter/core/providers.dart';
import 'package:f_twitter/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final notificationAPIProvider = Provider((ref) {
  return NotificationAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class INotificationAPI {
  FutureEitherVoid createNotification(NotificationModel notification);
  Future<List<Document>> getNotifications(String uid);
  Stream<RealtimeMessage> getLatestNotification();
}

class NotificationAPI implements INotificationAPI {
  final Databases _db;
  final Realtime _realtime;
  NotificationAPI({
    required Databases db,
    required Realtime realtime,
  })  : _db = db,
        _realtime = realtime;

  @override
  FutureEitherVoid createNotification(NotificationModel notification) async {
    try {
      await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notificationsCollection,
        documentId: ID.unique(),
        data: notification.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getNotifications(String uid) async {
    final docs = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notificationsCollection,
        queries: [
          Query.equal('uid', uid),
        ]);

    return docs.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestNotification() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.notificationsCollection}.documents'
    ]).stream;
  }
}
