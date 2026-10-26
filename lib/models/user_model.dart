class UserModel {
  final String phoneNumber;
  final String fullName;
  final int? age;
  final String gender;
  final String bloodGroup;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String address;
  final bool profileCompleted;

  UserModel({
    required this.phoneNumber,
    this.fullName = '',
    this.age,
    this.gender = '',
    this.bloodGroup = 'O+',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.address = '',
    this.profileCompleted = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phoneNumber: json['phone_number'] ?? '',
      fullName: json['full_name'] ?? '',
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      gender: json['gender'] ?? '',
      bloodGroup: json['blood_group'] ?? 'O+',
      emergencyContactName: json['emergency_contact_name'] ?? '',
      emergencyContactPhone: json['emergency_contact_phone'] ?? '',
      address: json['address'] ?? '',
      profileCompleted: json['profile_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'blood_group': bloodGroup,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'address': address,
      'profile_completed': profileCompleted,
    };
  }
}
