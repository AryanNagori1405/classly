class User {
  final int id;
  final String uid;
  final String regId;
  final String name;
  final String email;
  final String role; // 'student' | 'teacher' | 'admin'
  final String department;
  final String semester;
  final String profileImage;
  final String bio;
  final DateTime createdAt;
  final bool isVerified;

  User({
    this.id = 0,
    required this.uid,
    required this.regId,
    required this.name,
    this.email = '',
    required this.role,
    this.department = '',
    this.semester = '',
    this.profileImage = 'https://via.placeholder.com/100',
    this.bio = '',
    DateTime? createdAt,
    this.isVerified = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'regId': regId,
        'name': name,
        'email': email,
        'role': role,
        'department': department,
        'semester': semester,
        'profileImage': profileImage,
        'bio': bio,
        'createdAt': createdAt.toIso8601String(),
        'isVerified': isVerified,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int? ?? 0,
        uid: json['uid'] as String? ?? '',
        regId: json['regId'] ?? json['reg_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'student',
        department: json['department'] as String? ?? '',
        semester: json['semester'] as String? ?? '',
        profileImage: (json['profileImage'] ?? json['profile_image'])
                as String? ??
            'https://via.placeholder.com/100',
        bio: json['bio'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        isVerified: json['isVerified'] ?? json['is_verified'] as bool? ?? false,
      );

  User copyWith({
    String? uid,
    String? regId,
    String? name,
    String? email,
    String? role,
    String? department,
    String? semester,
    String? profileImage,
    String? bio,
    bool? isVerified,
  }) =>
      User(
        id: id,
        uid: uid ?? this.uid,
        regId: regId ?? this.regId,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        department: department ?? this.department,
        semester: semester ?? this.semester,
        profileImage: profileImage ?? this.profileImage,
        bio: bio ?? this.bio,
        createdAt: createdAt,
        isVerified: isVerified ?? this.isVerified,
      );
}
