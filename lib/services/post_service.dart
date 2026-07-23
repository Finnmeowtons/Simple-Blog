import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_model.dart';

class PostService {
  final supabase = Supabase.instance.client;

  Future<List<Post>> getPosts() async {
    final response = await supabase.from('posts').select();
    return response.map((e) => Post.fromJson(e)).toList();
  }

  Future<void> createPost({required String title, required String content}) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    final response = await supabase
        .from('posts')
        .insert({
      'user_id': user.id,
      'title': title,
      'content': content,
    })
        .select()
        .single();
    print(response);
  }

  Future<void> updatePost({required int id, required String title, required String content}) async {
    await supabase.from('posts').update({'title': title, 'content': content}).eq('id', id);
  }

  Future<void> deletePost({required int id}) async {
    await supabase.from('posts').delete().eq("id", id);
  }
}
