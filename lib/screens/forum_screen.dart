import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/models/post_model.dart';
import 'package:simple_blog/providers/post_provider.dart';
import 'package:simple_blog/screens/comment_screen.dart';
import 'package:simple_blog/services/storage_service.dart';
import 'package:simple_blog/widgets/image_tile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zo_animated_border/widget/zo_dual_border.dart';

import '../models/post_image_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_list.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ValueNotifier<Post?> _selectedPost = ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PostProvider>().getPosts();
    });
    debugPrint("ForumScreen initState");
  }

  @override
  void dispose() {
    _selectedPost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("ForumScreen build");
    final currentUser = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: _appBar(currentUser),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              if (currentUser != null) _createPostForm(),
              SizedBox(height: 16),
              Expanded(
                child: PostList(
                  currentUserId: currentUser?.id,
                  currentUserEmail: currentUser?.email ?? "",

                  onComment: (post) {
                    debugPrint("Comments Pressed");
                    _selectedPost.value = post;
                  },

                  onEdit: (post) {
                    showPostFormDialog(post);
                  },
                ),
              ),
            ],
          ),
          ValueListenableBuilder<Post?>(
            valueListenable: _selectedPost,
            builder: (context, selectedPost, _) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                right: selectedPost == null ? -470 : 16,
                top: 16,
                bottom: 16,
                child: Material(
                  elevation: 12,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 450,
                    child: selectedPost == null
                        ? const SizedBox.shrink()
                        : CommentScreen(
                      post: selectedPost,
                      onClose: () => _selectedPost.value = null,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar(User? user) {
    return AppBar(
      title: const Text("Forum"),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () async {
            user != null ? await context.read<AuthProvider>().logout() : context.push('/auth');
          },
          icon: user != null ? Icon(Icons.logout) : Icon(Icons.login),
        ),
      ],
    );
  }

  Widget _createPostForm() {
    return ZoDualBorder(
      glowOpacity: 0.1,
      firstBorderColor: Colors.black87,
      secondBorderColor: Colors.black87,
      trackBorderColor: Colors.transparent,
      borderWidth: 1,
      animationDuration: const Duration(milliseconds: 6000),
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 300,
        height: 60,
        child: Consumer<PostProvider>(
          builder: (context, provider, child) {
            return InkWell(
              onTap: () {
                showPostFormDialog(null);
              },
              child: Center(
                child: Text('Create Post', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      ),
    );
  }


  Future<void> showPostFormDialog(Post? post) async {
    return showDialog(
      context: context,
      builder: (context) {
        return postForm(post);
      },
    );
  }

  Widget postForm(Post? post) {
    final postFormKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: post?.title ?? "");
    final contentController = TextEditingController(text: post?.content ?? "");
    final ScrollController newImagesScrollController = ScrollController();
    final ScrollController existingImagesScrollController = ScrollController();
    const int maxImages = 5;
    final List<PostImage> existingImages = List.from(post?.images ?? []);
    final List<PlatformFile> newImages = [];

    final isNewPost = post == null;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(isNewPost ? "Create Post" : "Edit Post"),
          actions: [
            SizedBox(
              width: 600,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Consumer<PostProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.loading
                          ? null
                          : () async {
                              if (!postFormKey.currentState!.validate()) {
                                return;
                              }

                              final success = isNewPost
                                  ? await context.read<PostProvider>().createPost(title: titleController.text.trim(), content: contentController.text.trim(), images: newImages)
                                  : await context.read<PostProvider>().updatePost(post: post, title: titleController.text.trim(), content: contentController.text.trim(), remainingImages: existingImages, newImages: newImages);

                              if (success && context.mounted) {
                                print("SUCCESS!");
                                Navigator.pop(context);
                                titleController.clear();
                                contentController.clear();

                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: isNewPost ? const Text("Post created!") : const Text("Post updated!")));

                                setState(() {
                                  existingImages.clear();
                                });
                              }
                            },
                      child: provider.loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Submit"),
                    );
                  },
                ),
              ),
            ),
          ],
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: postFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Title",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: titleController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter a title";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Description",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          maxLines: 5,
                          controller: contentController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter content";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Add Images",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final result = await FilePicker.pickFiles(allowMultiple: true, type: FileType.image, withData: true);

                      if (result == null) return;

                      final totalImages = existingImages.length + newImages.length;
                      final remainingSlots = maxImages - totalImages;

                      if (remainingSlots <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can upload a maximum of 5 images.")));
                        return;
                      }

                      setDialogState(() {
                        for (final file in result.files.take(remainingSlots)) {
                          if (!newImages.any((e) => e.name == file.name)) {
                            newImages.add(file);
                          }
                        }
                      });
                    },
                    child: DottedBorder(
                      options: RectDottedBorderOptions(dashPattern: [8, 2], strokeWidth: 2, padding: EdgeInsets.all(16), color: Colors.black26),
                      child: newImages.isEmpty && existingImages.isEmpty
                          ? SizedBox(
                              height: 100,
                              child: Center(
                                child: ListTile(
                                  title: Text(
                                    'Click to upload',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  subtitle: Text(
                                    'Max Size: 2MB',
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 100,
                              width: 600,
                              child: Center(
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    for (final file in newImages)
                                      ImageTile(
                                        image: Image.memory(file.bytes!, width: 80, height: 80, fit: BoxFit.cover),
                                        onDelete: () => newImages.remove(file),
                                      ),

                                    for (final image in existingImages)
                                      ImageTile(
                                        image: Image.network(StorageService().getImageUrl(image.imagePath), width: 80, height: 80, fit: BoxFit.cover),
                                        onDelete: () => existingImages.remove(image),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
