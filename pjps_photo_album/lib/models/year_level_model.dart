class YearLevelModel {
  final String id;
  final String name;
  final int displayOrder;
  final bool isActive;
  final int studentCount; // Direct student count for this year

  YearLevelModel({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.isActive,
    required this.studentCount,
  });

  factory YearLevelModel.fromJson(Map<String, dynamic> json) {
    return YearLevelModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      displayOrder: (json['display_order'] is int)
          ? json['display_order']
          : int.tryParse(json['display_order']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      studentCount: (json['student_count'] is int)
          ? json['student_count']
          : int.tryParse(json['student_count']?.toString() ?? '0') ?? 0,
    );
  }
}
