import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// ConnectivityNotifier tracks online/offline status
class ConnectivityNotifier extends StateNotifier<bool> {
  final Connectivity _connectivity = Connectivity();

  ConnectivityNotifier() : super(true) {
    _init();
  }

  /// Expose a boolean getter for convenience
  bool get isOnline => state;

  /// Initialize connectivity listener
  void _init() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      // ✅ Update state whenever connectivity changes
      state = result != ConnectivityResult.none;
    });
  }

  /// Optional: manual override
  void setOnline(bool value) => state = value;
}
