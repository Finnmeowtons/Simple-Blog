import 'package:simple_blog/models/post_image_model.dart';
import 'package:simple_blog/models/profile_model.dart';

class Post {
  final int id;
  final String userId;
  final String title;
  final String content;
  final Profile? profile;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PostImage> images;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.profile,
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
      profile: json['profiles'] == null
          ? null
          : Profile.fromJson(json['profiles']),
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
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
      'profile': profile,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}