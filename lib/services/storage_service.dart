import 'package:file_picker/file_picker.dart';
import 'package:simple_blog/models/comment_image_model.dart';
import 'package:simple_blog/models/comment_model.dart';
import 'package:simple_blog/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/post_image_model.dart';

class StorageService {
  final supabase = Supabase.instance.client;

  Future<List<String>> uploadImages({required Post post, required List<PlatformFile> images}) async {
    List<String> imagePaths = [];


    for (final image in images) {
      final uuid = Uuid().v4();


      final path = "${post.userId}/post_${post.id}/$uuid-${image.name}";
      try {
        await supabase.storage
            .from('blog_images')
            .uploadBinary(path, image.bytes!);

        imagePaths.add(path);
      } catch (e) {
        rethrow;
      }
    }

    return imagePaths;
  }

  Future<List<String>> uploadCommentImages({required Comment comment, required List<PlatformFile> images}) async {
    List<String> imagePaths = [];


    for (final image in images) {
      final uuid = Uuid().v4();


      final path = "${comment.userId}/comment_${comment.id}/$uuid-${image.name}";
      try {
        await supabase.storage
            .from('blog_images')
            .uploadBinary(path, image.bytes!);

        imagePaths.add(path);
      } catch (e) {
        rethrow;
      }
    }

    return imagePaths;
  }

  String getImageUrl(String imagePath) {
    return supabase.storage
        .from('blog_images')
        .getPublicUrl(imagePath);
  }

  Future<void> deleteImages(List<PostImage> images) async {
    if (images.isEmpty) return;

    final ids = images.map((e) => e.id).toList();

    await supabase
        .from('post_images')
        .delete()
        .inFilter('id', ids);

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
