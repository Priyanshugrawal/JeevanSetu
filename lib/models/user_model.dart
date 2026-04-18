class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String phone;
  final List<String> skills;
  final String location;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.skills = const [],
    this.location = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'skills': skills,
      'location': location,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'volunteer',
      phone: map['phone'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      location: map['location'] ?? '',
    );
  }
}