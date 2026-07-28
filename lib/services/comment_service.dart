import 'package:simple_blog/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/comment_image_model.dart';

class CommentService {
  final supabase = Supabase.instance.client;

  Future<List<Comment>> getComments({
    required int postId,
  }) async {
    final response = await supabase
        .from('comments')
        .select('''
        *,
        profiles (
          id,
          email
        ),
        comment_images (
          id,
          image_path
        )
      ''')
        .eq('post_id', postId)
        .order('created_at');

    return response
        .map<Comment>((e) => Comment.fromJson(e))
        .toList();
  }

  Future<Comment> createComment({required int postId, required String content}) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    final response = await supabase.from('comments').insert({'user_id': user.id, 'post_id': postId, 'content': content}).select().single();
    return Comment.fromJson(response);
  }

  Future<void> saveCommentImages({required int commentId, required List<String> imagePaths}) async {
    final data = imagePaths.map((path) {
      return {'comment_id': commentId, 'image_path': path};
    }).toList();

    await supabase.from('comment_images').insert(data);
  }

  Future<void> updateComment({
    required int id,
    required String content,
  }) async {
    await supabase
        .from('comments')
        .update({
      'content': content,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', id);
  }

  Future<void> deleteComment({required int id}) async {
    await supabase.from('comments').delete().eq("id", id);
  }

  Future<void> deleteCommentImages(List<CommentImage> images) async {
    if (images.isEmpty) return;

    final ids = images.map((e) => e.id).toList();

    await supabase
        .from('comment_images')
        .delete()
        .inFilter('id', ids);
  }
}
