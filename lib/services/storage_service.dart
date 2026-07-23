import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;

  Future<List<String>> uploadImages({required String userId, required int postId, required List<PlatformFile> images}) async {
    List<String> imagePaths = [];

    for (final image in images) {
      final path = "$userId/post_$postId/${image.name}";
      await supabase.storage.from('blog_images').uploadBinary(path, image.bytes!);
      imagePaths.add(path);
    }
    return imagePaths;
  }
}
