class Post {
  final int id;
  final String content;
  final DateTime createdAt;
  final int likeCount;

  Post({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likeCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      likeCount: json['like_count'],
    );
  }
}
