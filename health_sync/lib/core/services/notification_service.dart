import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;

  // ১. ইনিশিয়ালাইজেশন
  Future<void> initialize() async {
    // পারমিশন চাওয়া
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // টোকেন নেওয়া
    final fcmToken = await _firebaseMessaging.getToken();

    if (fcmToken != null) {
      log("🔥 FCM Token: $fcmToken");
      await _saveTokenToDatabase(fcmToken);
    }

    // টোকেন রিফ্রেশ হলে আপডেট করা (অ্যাপ আনইনস্টল/ক্লিয়ার ডাটা হলে টোকেন বদলায়)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _saveTokenToDatabase(newToken);
    });

    // ফোরগ্রাউন্ডে নোটিফিকেশন হ্যান্ডেল করা (অপশনাল)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');
      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // ২. ডাটাবেসে সেভ করা
  Future<void> _saveTokenToDatabase(String token) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('profiles').update({
          'fcm_token': token,
        }).eq('id', user.id);
        log("✅ FCM Token saved to Supabase");
      } catch (e) {
        log("❌ Error saving token: $e");
      }
    }
  }
}