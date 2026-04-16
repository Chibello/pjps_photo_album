class StudentListModel {
  final String id;
  final String registrationNumber;
  final String fullName;
  final String? profilePhotoThumbnail;
  final String? yearLevel; // maps to year_level in API
  final String? yearLevelName; // optional human-readable name
  final bool isActive;
  final bool isGraduated;

  StudentListModel({
    required this.id,
    required this.registrationNumber,
    required this.fullName,
    this.profilePhotoThumbnail,
    this.yearLevel,
    this.yearLevelName,
    required this.isActive,
    required this.isGraduated,
  });

  factory StudentListModel.fromJson(Map<String, dynamic> json) {
    return StudentListModel(
      id: json['id']?.toString() ?? '',
      registrationNumber: json['registration_number']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      profilePhotoThumbnail: json['profile_photo_thumbnail']?.toString(),
      yearLevel: json['year_level']?.toString(),
      yearLevelName: json['year_level_name']?.toString(),
      isActive: (json['is_active'] == true || json['is_active'] == 1),
      isGraduated: (json['is_graduated'] == true || json['is_graduated'] == 1),
    );
  }
}

class StudentDetailModel {
  final String id;
  final String registrationNumber;
  final String firstName;
  final String lastName;
  final String? otherNames;
  final String fullName;
  final String? dateOfBirth;
  final String? diocese;
  final String? dioceseName;
  final String hometown;
  final String? stateOfOrigin;
  final String? stateName;
  final String? yearLevel; // year_level id
  final String? yearLevelName; // optional human-readable
  final String enrollmentDate;
  final String? profilePhotoSmall;
  final String? profilePhotoMedium;
  final String? profilePhotoOriginal;
  final List<Map<String, dynamic>>? additionalPhotos;
  final bool isGraduated;
  final bool isActive;
  final String? personalNotes;
  final String createdAt;
  final String updatedAt;

  StudentDetailModel({
    required this.id,
    required this.registrationNumber,
    required this.firstName,
    required this.lastName,
    this.otherNames,
    required this.fullName,
    this.dateOfBirth,
    this.diocese,
    this.dioceseName,
    required this.hometown,
    this.stateOfOrigin,
    this.stateName,
    this.yearLevel,
    this.yearLevelName,
    required this.enrollmentDate,
    this.profilePhotoSmall,
    this.profilePhotoMedium,
    this.profilePhotoOriginal,
    this.additionalPhotos,
    required this.isGraduated,
    required this.isActive,
    this.personalNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) {
    return StudentDetailModel(
      id: json['id']?.toString() ?? '',
      registrationNumber: json['registration_number']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      otherNames: json['other_names']?.toString(),
      fullName: json['full_name']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString(),
      diocese: json['diocese']?.toString(),
      dioceseName: json['diocese_name']?.toString(),
      hometown: json['hometown']?.toString() ?? '',
      stateOfOrigin: json['state_of_origin']?.toString(),
      stateName: json['state_name']?.toString(),
      yearLevel: json['year_level']?.toString() ??
          json['class_detail']?['year_level']?.toString(),
      yearLevelName: json['year_level_name']?.toString() ??
          json['class_detail']?['year_level_name']?.toString(),
      enrollmentDate: json['enrollment_date']?.toString() ?? '',
      profilePhotoSmall: json['profile_photo_small']?.toString(),
      profilePhotoMedium: json['profile_photo_medium']?.toString(),
      profilePhotoOriginal: json['profile_photo_original']?.toString(),
      additionalPhotos: json['additional_photos'] != null
          ? List<Map<String, dynamic>>.from(json['additional_photos'])
          : null,
      isGraduated: (json['is_graduated'] == true || json['is_graduated'] == 1),
      isActive: (json['is_active'] == true || json['is_active'] == 1),
      personalNotes: json['personal_notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
