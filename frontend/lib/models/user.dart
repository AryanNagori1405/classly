class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// lib/models/course.dart
class Course {
  final int id;
  final String title;
  final String description;
  final int createdBy;
  final bool enableVideos;
  final bool enableQuizzes;
  final bool enableCommunities;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.enableVideos,
    required this.enableQuizzes,
    required this.enableCommunities,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdBy: json['created_by'],
      enableVideos: json['enable_videos'],
      enableQuizzes: json['enable_quizzes'],
      enableCommunities: json['enable_communities'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// lib/models/video.dart
class Video {
  final int id;
  final int teacherId;
  final int courseId;
  final String title;
  final String description;
  final String fileUrl;
  final String? thumbnailUrl;
  final int? duration;
  final int viewsCount;
  final int upvotes;
  final int downloadsCount;
  final bool isPublic;
  final DateTime createdAt;

  Video({
    required this.id,
    required this.teacherId,
    required this.courseId,
    required this.title,
    required this.description,
    required this.fileUrl,
    this.thumbnailUrl,
    this.duration,
    required this.viewsCount,
    required this.upvotes,
    required this.downloadsCount,
    required this.isPublic,
    required this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      teacherId: json['teacher_id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      fileUrl: json['file_url'],
      thumbnailUrl: json['thumbnail_url'],
      duration: json['duration'],
      viewsCount: json['views_count'] ?? 0,
      upvotes: json['upvotes'] ?? 0,
      downloadsCount: json['downloads_count'] ?? 0,
      isPublic: json['is_public'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}