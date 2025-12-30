import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

// 🔥 Provider for Notification Service
// This ensures we only have ONE instance active and it disposes properly
final notificationServiceProvider = StateNotifierProvider<NotificationService, bool>((ref) {
  return NotificationService();
});

class NotificationService extends StateNotifier<bool> {
  NotificationService() : super(false);

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;
  
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;

  // ১. ইনিশিয়ালাইজেশন
  Future<void> initialize() async {
    if (state) return; // Already initialized

    try {
      // পারমিশন চাওয়া
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // টোকেন নেওয়া
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        log("🔥 FCM Token found");
        await _saveTokenToDatabase(fcmToken);
      }

      // টোকেন রিফ্রেশ হলে আপডেট করা - Dispose handle করা হচ্ছে
      _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveTokenToDatabase(newToken);
      });

      // ফোরগ্রাউন্ডে নোটিফিকেশন হ্যান্ডেল করা
      _messageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Got a message whilst in the foreground!');
        if (message.notification != null) {
          log('Message also contained a notification: ${message.notification}');
        }
      });

      state = true; // Initialized
      log("🔔 Notification Service Started Successfully");
    } catch (e) {
      log("❌ Notification Init Failed: $e");
    }
  }

  // ২. ডিসপোজ/ রিসেট (লগআউটের সময় কল হবে)
  void disposeSubscriptions() {
    _tokenRefreshSubscription?.cancel();
    _messageSubscription?.cancel();
    state = false;
    log("🔕 Notification Service Stopped & Disposed");
  }

  // ৩. ডাটাবেসে সেভ করা
  Future<void> _saveTokenToDatabase(String token) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('profiles').update({
          'fcm_token': token,
        }).eq('id', user.id);
        log("✅ FCM Token saved to Supabase");
      } catch (e) {
        // Silent error
      }
    }
  }
  
  @override
  void dispose() {
    disposeSubscriptions();
    super.dispose();
  }
}