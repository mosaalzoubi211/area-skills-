import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initNotifications(String userEmail) async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ المستخدم وافق على استقبال الإشعارات');
      
      String? token = await _messaging.getToken();
      print('📱 FCM Token: $token');

      if (token != null) {
        await saveTokenToDatabase(userEmail, token);
      }
    
      _messaging.onTokenRefresh.listen((newToken) {
        saveTokenToDatabase(userEmail, newToken);
      });

    } else {
      print('❌ المستخدم رفض صلاحية الإشعارات');
    }
  }

  Future<void> saveTokenToDatabase(String email, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .set({'fcmToken': token}, SetOptions(merge: true));
    } catch (e) {
      print('خطأ في حفظ الـ Token: $e');
    }
  }
}