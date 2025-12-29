// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // طلب صلاحية الإشعارات (iOS & Web)
  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  // جلب التوكن وحفظه للمسعف
  Future<void> saveTokenToFirestore() async {
    String? token = await _messaging.getToken();
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcm_token': token,
    });

    print('FCM Token saved: $token');
    }
}
