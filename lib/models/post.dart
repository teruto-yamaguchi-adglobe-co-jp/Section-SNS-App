class Post {
  String id;
  String content;
  DateTime createdAt;
  int likesCount; // Number of likes
  bool isLiked; // To track like state locally

  Post({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    this.isLiked = false, // Default to not liked
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: json['likes_count'] as int? ?? 0, // Handle potential null for new posts
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
    };
  }

  Post copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}