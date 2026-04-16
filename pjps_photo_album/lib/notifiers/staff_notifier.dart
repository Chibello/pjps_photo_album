import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';
import '../services/api_service.dart';

// =======================
// STATE
// =======================
class StaffState {
  final bool isLoading;
  final List<Map<String, dynamic>> categories;
  final List<StaffListModel> allStaff;
  final StaffDetailModel? currentStaff;
  final String? error;

  StaffState({
    this.isLoading = false,
    this.categories = const [],
    this.allStaff = const [],
    this.currentStaff,
    this.error,
  });

  StaffState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? categories,
    List<StaffListModel>? allStaff,
    StaffDetailModel? currentStaff,
    String? error,
  }) {
    return StaffState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      allStaff: allStaff ?? this.allStaff,
      currentStaff: currentStaff ?? this.currentStaff,
      error: error ?? this.error,
    );
  }
}

// =======================
// NOTIFIER
// =======================
class StaffNotifier extends StateNotifier<StaffState> {
  final StaffService _staffService;

  StaffNotifier(this._staffService) : super(StaffState());

  /// ✅ Load all staff
  Future<void> loadAllStaff() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final staffList = await _staffService.getStaff(); // ✅ correct method

      state = state.copyWith(
        isLoading: false,
        allStaff: staffList, // ✅ already model
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ✅ Load categories
  Future<void> loadStaffCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _staffService.getStaffCategories();

      state = state.copyWith(
        isLoading: false,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ✅ Load by category
  Future<void> loadStaff({String? categoryId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final staffList = await _staffService.getStaff(categoryId: categoryId);

      state = state.copyWith(
        isLoading: false,
        allStaff: staffList,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ✅ Load details
  Future<void> loadStaffDetails(String staffId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final staffDetail = await _staffService.getStaffDetails(staffId);

      state = state.copyWith(
        isLoading: false,
        currentStaff: staffDetail,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ✅ Search
  Future<void> searchStaff(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final staffList = await _staffService.searchStaff(query);

      state = state.copyWith(
        isLoading: false,
        allStaff: staffList,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // =======================
// CREATE / UPDATE STAFF
// =======================

  Future<bool> createStaff(StaffDetailModel staff) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _staffService.createStaff(staff.toJson());
      // Optionally reload the list after creation
      await loadAllStaff();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// ✅ Update existing staff
  Future<bool> updateStaff(String staffId, StaffDetailModel staff) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _staffService.updateStaff(staffId, staff.toJson());
      // Optionally reload details or list after update
      await loadStaffDetails(staffId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

// =======================
// PROVIDERS
// =======================

// ✅ ApiService provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(); // adjust if your ApiService needs params
});

// ✅ Staff provider
final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return StaffNotifier(StaffService(apiService));
});
