enum UserRole { student, instructor, admin }

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? profileImage,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
