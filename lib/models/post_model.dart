import 'package:simple_blog/models/post_image_model.dart';

class Post {
  final int id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PostImage> images;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.images,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      images: (json['post_images'] as List<dynamic>?)
          ?.map((e) => PostImage.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}