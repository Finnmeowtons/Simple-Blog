import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_image_model.dart';
import '../models/post_model.dart';

class PostService {
  final supabase = Supabase.instance.client;

  Future<List<Post>> getPosts() async {
    final response = await supabase.from('posts').select('''
      *,
      post_images (
        id,
        image_path
      )
    ''');
    return response.map((e) => Post.fromJson(e)).toList();
  }

  Future<Post> createPost({required String title, required String content}) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    final response = await supabase.from('posts').insert({'user_id': user.id, 'title': title, 'content': content}).select().single();

    return Post.fromJson(response);
  }

  Future<void> savePostImages({required int postId, required List<String> imagePaths}) async {
    final data = imagePaths.map((path) {
      return {'post_id': postId, 'image_path': path};
    }).toList();

    await supabase.from('post_images').insert(data);
  }

  Future<void> updatePost({required int id, required String title, required String content}) async {
    await supabase.from('posts').update({'title': title, 'content': content}).eq('id', id);
  }

  Future<void> deletePost({required int id}) async {
    await supabase.from('posts').delete().eq("id", id);
  }

  Future<void> deletePostImages(List<PostImage> images) async {
    final ids = images.map((e) => e.id).toList();

    await supabase.from('post_images').delete().inFilter('id', ids);
  }
}
