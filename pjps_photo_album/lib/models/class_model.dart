class ClassGroupModel {
  final String id;
  final String name;
  final String yearLevel;
  final String yearLevelName;
  final String academicYear;
  final String academicYearName;
  final String? classTeacher;
  final bool isActive;
  final String? notes;
  final int studentCount;
  final String createdAt;
  final String updatedAt;

  ClassGroupModel({
    required this.id,
    required this.name,
    required this.yearLevel,
    required this.yearLevelName,
    required this.academicYear,
    required this.academicYearName,
    this.classTeacher,
    required this.isActive,
    this.notes,
    required this.studentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassGroupModel.fromJson(Map<String, dynamic> json) {
    return ClassGroupModel(
      id: json['id'],
      name: json['name'],
      yearLevel: json['year_level'].toString(),
      yearLevelName: json['year_level_name'] ?? '',
      academicYear: json['academic_year'].toString(),
      academicYearName: json['academic_year_name'] ?? '',
      classTeacher: json['class_teacher']?.toString(),
      isActive: json['is_active'],
      notes: json['notes'],
      studentCount: json['student_count'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
