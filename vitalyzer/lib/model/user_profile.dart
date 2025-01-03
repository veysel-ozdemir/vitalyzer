import 'dart:typed_data';

class UserProfile {
  final int? userId;
  final String firebaseUserUid;
  final String fullName;
  final String email;
  final Uint8List? profilePhoto;
  final int height;
  final double weight;
  final int age;
  final String gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    this.userId,
    required this.firebaseUserUid,
    required this.fullName,
    required this.email,
    this.profilePhoto,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'FirebaseUserUid': firebaseUserUid,
      'FullName': fullName,
      'Email': email,
      'ProfilePhoto': profilePhoto,
      'Height': height,
      'Weight': weight,
      'Age': age,
      'Gender': gender,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['UserId'],
      firebaseUserUid: map['FirebaseUserUid'],
      fullName: map['FullName'],
      email: map['Email'],
      profilePhoto: map['ProfilePhoto'],
      height: map['Height'],
      weight: map['Weight'],
      age: map['Age'],
      gender: map['Gender'],
      createdAt: DateTime.parse(map['CreatedAt']),
      updatedAt: DateTime.parse(map['UpdatedAt']),
    );
  }
}
