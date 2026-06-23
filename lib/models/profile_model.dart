class ProfileModel {
  final String id;
  final String role;
  final String fullName;
  final String? avatarUrl;
  final String? phone;
  final String? surfLevel;
  final String? bio;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.role,
    required this.fullName,
    this.avatarUrl,
    this.phone,
    this.surfLevel,
    this.bio,
    required this.createdAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      role: map['role'],
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'],
      phone: map['phone'],
      surfLevel: map['surf_level'],
      bio: map['bio'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'surf_level': surfLevel,
      'bio': bio,
    };
  }
}
