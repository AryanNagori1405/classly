class Video {
  final int id;
  final String title;
  final String description;
  final String instructor;
  final String videoUrl;
  final String? thumbnail;
  final int duration; // in seconds
  final int views;
  final int upvotes;
  final int downloads;
  final double rating;
  final int courseId;
  final String courseName;
  final DateTime createdAt;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.videoUrl,
    this.thumbnail,
    this.duration = 0,
    this.views = 0,
    this.upvotes = 0,
    this.downloads = 0,
    this.rating = 0.0,
    required this.courseId,
    required this.courseName,
    required this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnail: json['thumbnail'],
      duration: json['duration'] ?? 0,
      views: json['views'] ?? 0,
      upvotes: json['upvotes'] ?? 0,
      downloads: json['downloads'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'video_url': videoUrl,
      'thumbnail': thumbnail,
      'duration': duration,
      'views': views,
      'upvotes': upvotes,
      'downloads': downloads,
      'rating': rating,
      'course_id': courseId,
      'course_name': courseName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}