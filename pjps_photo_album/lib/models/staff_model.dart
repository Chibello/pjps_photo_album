class StaffListModel {
  final String id;
  final String staffId;
  final String fullName;
  final String position;
  final String? categoryName;
  final String? departmentName;
  final String? profilePhotoThumbnail;
  final bool isActive;

  StaffListModel({
    required this.id,
    required this.staffId,
    required this.fullName,
    required this.position,
    this.categoryName,
    this.departmentName,
    this.profilePhotoThumbnail,
    required this.isActive,
  });

  factory StaffListModel.fromJson(Map<String, dynamic> json) {
    return StaffListModel(
      id: json['id'],
      staffId: json['staff_id'],
      fullName: json['full_name'],
      position: json['position'],
      categoryName: json['category_name'],
      departmentName: json['department_name'],
      profilePhotoThumbnail: json['profile_photo_thumbnail'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'full_name': fullName,
      'position': position,
      'category_name': categoryName,
      'department_name': departmentName,
      'profile_photo_thumbnail': profilePhotoThumbnail,
      'is_active': isActive,
    };
  }
}

class StaffDetailModel {
  final String id;
  final String staffId;
  final String firstName;
  final String lastName;
  final String? otherNames;
  final String fullName;
  final String? dateOfBirth;
  final String? category;
  final String? categoryName;
  final String? department;
  final String? departmentName;
  final String position;
  final String employmentDate;
  final String workEmail;
  final String workPhone;
  final String? officeLocation;
  final String? officeHours;
  final String? bio;
  final String? qualifications;
  final String? responsibilities;
  final String? profilePhotoMedium;
  final String? profilePhotoOriginal;
  final String? adminRole;
  final Map<String, dynamic>? managesDepartment;
  final Map<String, dynamic>? librarySection;
  final String? librarianRank;
  final bool isActive;

  StaffDetailModel({
    required this.id,
    required this.staffId,
    required this.firstName,
    required this.lastName,
    this.otherNames,
    required this.fullName,
    this.dateOfBirth,
    this.category,
    this.categoryName,
    this.department,
    this.departmentName,
    required this.position,
    required this.employmentDate,
    required this.workEmail,
    required this.workPhone,
    this.officeLocation,
    this.officeHours,
    this.bio,
    this.qualifications,
    this.responsibilities,
    this.profilePhotoMedium,
    this.profilePhotoOriginal,
    this.adminRole,
    this.managesDepartment,
    this.librarySection,
    this.librarianRank,
    required this.isActive,
  });

  factory StaffDetailModel.fromJson(Map<String, dynamic> json) {
    return StaffDetailModel(
      id: json['id'],
      staffId: json['staff_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      otherNames: json['other_names'],
      fullName: json['full_name'],
      dateOfBirth: json['date_of_birth'],
      category: json['category'],
      categoryName: json['category_name'],
      department: json['department'],
      departmentName: json['department_name'],
      position: json['position'],
      employmentDate: json['employment_date'],
      workEmail: json['work_email'],
      workPhone: json['work_phone'],
      officeLocation: json['office_location'],
      officeHours: json['office_hours'],
      bio: json['bio'],
      qualifications: json['qualifications'],
      responsibilities: json['responsibilities'],
      profilePhotoMedium: json['profile_photo_medium'],
      profilePhotoOriginal: json['profile_photo_original'],
      adminRole: json['admin_role'],
      managesDepartment: json['manages_department'],
      librarySection: json['library_section'],
      librarianRank: json['librarian_rank'],
      isActive: json['is_active'],
    );
  }

  /// ✅ Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'first_name': firstName,
      'last_name': lastName,
      'other_names': otherNames,
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'category': category,
      'category_name': categoryName,
      'department': department,
      'department_name': departmentName,
      'position': position,
      'employment_date': employmentDate,
      'work_email': workEmail,
      'work_phone': workPhone,
      'office_location': officeLocation,
      'office_hours': officeHours,
      'bio': bio,
      'qualifications': qualifications,
      'responsibilities': responsibilities,
      'profile_photo_medium': profilePhotoMedium,
      'profile_photo_original': profilePhotoOriginal,
      'admin_role': adminRole,
      'manages_department': managesDepartment,
      'library_section': librarySection,
      'librarian_rank': librarianRank,
      'is_active': isActive,
    };
  }

  /// ✅ Convenient getters for your screen
  String? get email => workEmail;
  String? get phoneNumber => workPhone;
  List<String> get roles {
    if (adminRole != null && adminRole!.isNotEmpty) {
      return adminRole!.split(','); // assume comma-separated roles
    }
    return [];
  }
}
