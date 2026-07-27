import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:simple_blog/services/post_service.dart';

import '../models/post_image_model.dart';
import '../models/post_model.dart';
import '../services/storage_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();

  bool _loading = false;
  List<Post> _posts = [];
  String? _error;

  bool get loading => _loading;
  List<Post> get posts => _posts;
  String? get error => _error;

  Future<List<Post>> _loadPosts() async {
    return await _postService.getPosts();
  }

  Future<void> getPosts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _loadPosts();
    } catch (e) {
      _error = e.toString();
      print(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({required String title, required String content, required List<PlatformFile> images}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final post = await _postService.createPost(title: title, content: content);

      if (images.isNotEmpty) {
        final imagePaths = await _storageService.uploadImages(images: images, post: post);

        await _postService.savePostImages(postId: post.id, imagePaths: imagePaths);
      }

      _posts = await _loadPosts();
      return true;
    } catch (e) {
      _error = e.toString();
      print(_error);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePost({
    required Post post,
    required String title,
    required String content,
    required List<PostImage> remainingImages,
    required List<PlatformFile> newImages,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _postService.updatePost(
        id: post.id,
        title: title,
        content: content,
      );

      final removedImages = post.images.where(
            (image) => !remainingImages.any(
              (remaining) => remaining.id == image.id,
        ),
      ).toList();

      if (removedImages.isNotEmpty) {
        await _storageService.deleteImages(removedImages);
        await _postService.deletePostImages(removedImages);
      }

      if (newImages.isNotEmpty) {
        final imagePaths = await _storageService.uploadImages(
          post: post,
          images: newImages,
        );

        await _postService.savePostImages(
          postId: post.id,
          imagePaths: imagePaths,
        );
      }

      _posts = await _loadPosts();
      return true;
    } catch (e) {
      _error = e.toString();
      print(_error);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost({required Post post}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _storageService.deleteImages(post.images);

      await _postService.deletePostImages(post.images);

      await _postService.deletePost(id: post.id);

      _posts = await _loadPosts();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
