import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/post_image_model.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/storage_service.dart';

class PostDetailProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();

  bool _loading = true;
  String? _error;

  Post? _post;

  bool get loading => _loading;
  String? get error => _error;
  Post? get post => _post;

  Future<void> getPost(int id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _post = await _postService.getPost(id: id);
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<Post?> updatePost({
    required String title,
    required String content,
    required List<PostImage> remainingImages,
    required List<PlatformFile> newImages,
  }) async {
    if (_post == null) return null;

    _loading = true;
    notifyListeners();

    try {
      await _postService.updatePost(
        id: _post!.id,
        title: title,
        content: content,
      );

      final removed = _post!.images.where(
            (image) => !remainingImages.any(
              (e) => e.id == image.id,
        ),
      );

      if (removed.isNotEmpty) {
        await _storageService.deleteImages(
          removed.toList(),
        );

        await _postService.deletePostImages(
          removed.toList(),
        );
      }

      if (newImages.isNotEmpty) {
        final paths = await _storageService.uploadImages(
          post: _post!,
          images: newImages,
        );

        await _postService.savePostImages(
          postId: _post!.id,
          imagePaths: paths,
        );
      }

      _post = await _postService.getPost(id: _post!.id);

      return _post;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost() async {
    if (_post == null) return false;

    try {
      await _storageService.deleteImages(_post!.images);

      await _postService.deletePostImages(_post!.images);

      await _postService.deletePost(
        id: _post!.id,
      );

      _post = null;

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}