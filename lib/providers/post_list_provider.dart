import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/post_image_model.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/storage_service.dart';

class PostListProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();

  bool _loading = false;
  String? _error;

  final List<Post> _posts = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Post> get posts => List.unmodifiable(_posts);

  Future<void> getPosts() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final fetchedPosts = await _postService.getPosts();


      _posts
        ..clear()
        ..addAll(fetchedPosts);
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<Post?> createPost({
    required String title,
    required String content,
    required List<PlatformFile> images,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final post = await _postService.createPost(
        title: title,
        content: content,
      );

      if (images.isNotEmpty) {
        final paths = await _storageService.uploadImages(
          post: post,
          images: images,
        );

        await _postService.savePostImages(
          postId: post.id,
          imagePaths: paths,
        );
      }

      final created = await _postService.getPost(id: post.id);

      _posts.insert(0, created);

      return created;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost(Post post) async {
    try {
      await _storageService.deleteImages(post.images);
      await _postService.deletePostImages(post.images);
      await _postService.deletePost(id: post.id);

      _posts.removeWhere((e) => e.id == post.id);

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void replacePost(Post updated) {
    final index = _posts.indexWhere((e) => e.id == updated.id);

    if (index == -1) return;

    _posts[index] = updated;

    notifyListeners();
  }

  void addPost(Post post) {
    _posts.insert(0, post);

    notifyListeners();
  }

  void removePost(int id) {
    _posts.removeWhere((e) => e.id == id);

    notifyListeners();
  }
}