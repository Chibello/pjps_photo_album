// connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Checks if the device has an active internet connection
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityState {
  final bool isOnline;
  final ConnectivityResult connectionType;

  ConnectivityState({
    this.isOnline = true,
    this.connectionType = ConnectivityResult.wifi,
  });

  ConnectivityState copyWith(
      {bool? isOnline, ConnectivityResult? connectionType}) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      connectionType: connectionType ?? this.connectionType,
    );
  }
}

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier() : super(ConnectivityState()) {
    _initConnectivity();
  }

  final Connectivity _connectivity = Connectivity();

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final isOnline = result != ConnectivityResult.none;
    state = state.copyWith(
      isOnline: isOnline,
      connectionType: result,
    );
  }

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
