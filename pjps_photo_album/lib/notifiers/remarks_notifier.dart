import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/remark_model.dart';
import '../services/remarks_service.dart';

class RemarksState {
  final bool isLoading;
  final RemarkBookModel? currentRemarkBook;
  final String? error;

  RemarksState({
    this.isLoading = false,
    this.currentRemarkBook,
    this.error,
  });

  RemarksState copyWith({
    bool? isLoading,
    RemarkBookModel? currentRemarkBook,
    String? error,
  }) {
    return RemarksState(
      isLoading: isLoading ?? this.isLoading,
      currentRemarkBook: currentRemarkBook ?? this.currentRemarkBook,
      error: error ?? this.error,
    );
  }
}

class RemarksNotifier extends StateNotifier<RemarksState> {
  final RemarksService _remarksService;

  RemarksNotifier(this._remarksService) : super(RemarksState());

  Future<void> loadRemarkBook(String contentType, String objectId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final remarkBook =
          await _remarksService.getRemarkBook(contentType, objectId);
      state = state.copyWith(isLoading: false, currentRemarkBook: remarkBook);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addRemark({
    required String contentType,
    required String objectId,
    required String title,
    required String content,
    String remarkType = 'GENERAL',
    String visibility = 'INTERNAL',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _remarksService.addRemark(
        contentType: contentType,
        objectId: objectId,
        title: title,
        content: content,
        remarkType: remarkType,
        visibility: visibility,
      );

      // Refresh the remark book
      await loadRemarkBook(contentType, objectId);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
