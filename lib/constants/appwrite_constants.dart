class AppwriteConstants {
  static const String databaseId = '63d7ef75570db4ad463f';
  static const String projectId = '63d7ef487618ddf8ad17';
  static const String endPoint = 'http://192.168.1.6:80/v1';
  static const String usersCollection = '63d7ef86b89ef877a039';
  static const String tweetsCollection = '63da18bd506021997c51';
  static const String notificationsCollection = '63ed9a639217c6a87b2f';
  static const String imagesBucket = '63da270941b5e16a4ff5';
  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
}
