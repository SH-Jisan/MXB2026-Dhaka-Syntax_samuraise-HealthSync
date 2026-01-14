/// File: lib/core/services/notification_service.dart
/// Purpose: Manages Firebase Cloud Messaging (FCM) and notification permissions.
/// Author: HealthSync Team
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

/// Provider for the [NotificationService].
final notificationServiceProvider =
    StateNotifierProvider<NotificationService, bool>((ref) {
      return NotificationService();
    });

/// Service class to handle notification initialization and token management.
class NotificationService extends StateNotifier<bool> {
  NotificationService() : super(false);

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;

  Future<void> initialize() async {
    if (state) return;

    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        log(" FCM Token found");
        await _saveTokenToDatabase(fcmToken);
      }

      _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen((
        newToken,
      ) {
        _saveTokenToDatabase(newToken);
      });

      _messageSubscription = FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
        log('Got a message whilst in the foreground!');
        if (message.notification != null) {
          log('Message also contained a notification: ${message.notification}');
        }
      });

      state = true;
      log(" Notification Service Started Successfully");
    } catch (e) {
      log(" Notification Init Failed: $e");
    }
  }

  void disposeSubscriptions() {
    _tokenRefreshSubscription?.cancel();
    _messageSubscription?.cancel();
    state = false;
    log(" Notification Service Stopped & Disposed");
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', user.id);
        log("FCM Token saved to Supabase");
      } catch (e) {
        log("Error saving token: $e");
      }
    }
  }

  @override
  void dispose() {
    disposeSubscriptions();
    super.dispose();
  }
}
