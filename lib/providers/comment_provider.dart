import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

import '../models/comment_image_model.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';
import '../services/storage_service.dart';

class CommentProvider extends ChangeNotifier {
  final CommentService _commentService = CommentService();
  final StorageService _storageService = StorageService();

  bool _loading = false;
  List<Comment> _comments = [];
  String? _error;

  bool get loading => _loading;
  List<Comment> get comments => _comments;
  String? get error => _error;

  Future<List<Comment>> _loadComments({required int postId}) async {
    return await _commentService.getComments(postId: postId);
  }

  Future<void> getComments({required int postId}) async {
    _loading = true;
    _error = null;

    _comments = [];
    notifyListeners();

    try {
      _comments = await _loadComments(postId: postId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createComment({required int postId, required String content, required List<PlatformFile> images}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final comment = await _commentService.createComment(postId: postId, content: content);
      if (images.isNotEmpty) {
        final imagePaths = await _storageService.uploadCommentImages(images: images, comment: comment);
        await _commentService.saveCommentImages(commentId: comment.id, imagePaths: imagePaths);
      }

      _comments = await _loadComments(postId: postId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateComment({
    required Comment comment,
    required String content,
    required List<CommentImage> remainingImages,
    required List<PlatformFile> newImages,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _commentService.updateComment(
        id: comment.id,
        content: content,
      );

      final removedImages = comment.images.where(
            (image) => !remainingImages.any(
              (remaining) => remaining.id == image.id,
        ),
      ).toList();

      if (removedImages.isNotEmpty) {
        await _storageService.deleteCommentImages(removedImages);
        await _commentService.deleteCommentImages(removedImages);
      }

      if (newImages.isNotEmpty) {
        final imagePaths = await _storageService.uploadCommentImages(
          comment: comment,
          images: newImages,
        );

        await _commentService.saveCommentImages(
          commentId: comment.id,
          imagePaths: imagePaths,
        );
      }

      _comments = await _loadComments(postId: comment.postId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteComment({
    required Comment comment,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (comment.images.isNotEmpty) {
        await _commentService.deleteCommentImages(comment.images);
        await _storageService.deleteCommentImages(comment.images);
      }

      await _commentService.deleteComment(id: comment.id);

      _comments = await _loadComments(postId: comment.postId);

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
