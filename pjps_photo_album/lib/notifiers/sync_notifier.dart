import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncState {
  final bool isSyncing;

  SyncState({this.isSyncing = false});

  SyncState copyWith({bool? isSyncing}) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(SyncState());

  Future<void> startSync() async {
    state = state.copyWith(isSyncing: true);

    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(isSyncing: false);
  }
}
