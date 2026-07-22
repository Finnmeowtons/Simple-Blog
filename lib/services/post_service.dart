import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_model.dart';

class PostService {

  final supabase = Supabase.instance.client;

  Future<List<Post>?> getPosts() async {return null;}

  Future<void> createPost() async {}

  Future<void> updatePost() async {}

  Future<void> deletePost() async {}
}