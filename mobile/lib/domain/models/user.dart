/// Backend karşılığı: users.py → UserPublic
class User {
  final String id;
  final String email;
  final String? fullName;
  final bool isActive;
  final bool isDeleted;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.isActive = true,
    this.isDeleted = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_active': isActive,
      'is_deleted': isDeleted,
    };
  }
}
