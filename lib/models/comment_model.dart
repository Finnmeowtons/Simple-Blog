import 'comment_image_model.dart';

class Comment {
  final int id;
  final String userId;
  final int postId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<CommentImage> images;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.images,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      images: (json['comment_images'] as List<dynamic>?)
          ?.map((e) => CommentImage.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'postId': postId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}