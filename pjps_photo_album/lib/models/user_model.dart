class UserModel {
  final String id;
  final String registrationNumber;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? email;
  final String userType;
  final bool isActive;
  final String dateJoined;

  UserModel({
    required this.id,
    required this.registrationNumber,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.email,
    required this.userType,
    required this.isActive,
    required this.dateJoined,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      registrationNumber: json['registration_number'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'],
      userType: json['user_type'],
      isActive: json['is_active'],
      dateJoined: json['date_joined'],
    );
  }

  bool get isAdmin => userType == 'ADMIN';
  bool get isStaff => userType == 'STAFF';
  bool get isStudent => userType == 'STUDENT';
}
