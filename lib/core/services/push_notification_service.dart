import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants/app_constants.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  void Function(RemoteMessage)? onForegroundMessage;

  Future<void> init() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      onForegroundMessage?.call(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message);
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<String?> getToken() => _fcm.getToken();

  Future<void> saveToken(String uid) async {
    final token = await _fcm.getToken();
    if (token == null) return;

    await _setToken(uid, token);

    _fcm.onTokenRefresh.listen((newToken) {
      _setToken(uid, newToken);
    });
  }

  Future<void> deleteToken(String uid) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'fcmToken': FieldValue.delete()});
  }

  Future<void> _setToken(String uid, String token) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  void _handleNotificationTap(RemoteMessage message) {}
}

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {}
