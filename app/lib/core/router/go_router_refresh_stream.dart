/// File: lib/core/router/go_router_refresh_stream.dart
/// Purpose: Converts a Stream into a Listenable for GoRouter refresh logic.
/// Author: HealthSync Team
library;

import 'dart:async';
import 'package:flutter/material.dart';

/// a [ChangeNotifier] that notifies listeners when a [Stream] emits a value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
