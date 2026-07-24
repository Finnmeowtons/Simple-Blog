import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/models/post_model.dart';
import 'package:simple_blog/providers/post_provider.dart';
import 'package:simple_blog/services/post_service.dart';
import 'package:simple_blog/services/storage_service.dart';
import 'package:zo_animated_border/widget/zo_dual_border.dart';
import 'package:zo_animated_border/widget/zo_fire_border.dart';

import '../models/post_image_model.dart';
import '../providers/auth_provider.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<PlatformFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PostProvider>().getPosts();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          SizedBox(height: 16),
          _createPostForm(),
          SizedBox(height: 16),
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, provider, child) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                } else if (provider.posts.isEmpty) {
                  return Center(child: const Text("No posts found."));
                }
                return ListView.builder(
                  itemCount: provider.posts.length,
                  itemBuilder: (context, index) {
                    final post = provider.posts[index];
                    final isOwner = currentUser?.id == post.userId;
                    return _buildPost(post, isOwner, currentUser?.email ?? "");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      title: const Text("Forum"),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () async {
            await context.read<AuthProvider>().logout();
          },
          icon: const Icon(Icons.logout),
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
    SizedBox(
      width: 600,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Title"),
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a title";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Content"),
                      maxLines: 5,
                      controller: _contentController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter content";
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: [
                        ElevatedButton(onPressed: () => _pickImages(), child: const Text("Upload Image")),
                        Consumer<PostProvider>(
                          builder: (context, provider, child) {
                            return ElevatedButton(
                              onPressed: provider.loading
                                  ? null
                                  : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                final success = await context.read<PostProvider>().createPost(title: _titleController.text.trim(), content: _contentController.text.trim(), images: _selectedImages);

                                if (success && context.mounted) {
                                  _titleController.clear();
                                  _contentController.clear();

                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post created!")));

                                  setState(() {
                                    _selectedImages.clear();
                                  });
                                }
                              },
                              child: provider.loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Submit"),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final file = _selectedImages[index];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(file.bytes!, width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ),
              if (_selectedImages.isNotEmpty) Text("${_selectedImages.length} image(s) selected"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPost(Post post, bool isOwner, String email) {
    return Center(
      child: SizedBox(
        width: 800,
        child: Column(
          children: [
            Text(email),
            ListTile(
              title: Text(post.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
              subtitle: Text(post.content, style: TextStyle(fontSize: 20)),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.images.length,
                itemBuilder: (context, index) {
                  final image = post.images[index];

                  final imageUrl = StorageService().getImageUrl(image.imagePath);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
            if (isOwner)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async {
                      final success = await context.read<PostProvider>().deletePost(post: post);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post deleted!")));
                      }
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () {
                      showPostFormDialog(post);
                    },
                    icon: Icon(Icons.edit),
                  ),
                ],
              ),
          ],
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
                      final result = await FilePicker.pickFiles(
                        allowMultiple: true,
                        type: FileType.image,
                        withData: true,
                      );

                      if (result == null) return;

                      final totalImages = existingImages.length + newImages.length;
                      final remainingSlots = maxImages - totalImages;

                      if (remainingSlots <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("You can upload a maximum of 5 images."),
                          ),
                        );
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
                                _imageTile(
                                  Image.memory(file.bytes!, width: 80, height: 80, fit: BoxFit.cover),
                                  () {
                                    setDialogState(() {
                                      newImages.remove(file);
                                    });
                                  },
                                ),

                              for (final image in existingImages)
                                _imageTile(
                                  Image.network(StorageService().getImageUrl(image.imagePath), width: 80, height: 80, fit: BoxFit.cover),
                                  () {
                                    setDialogState(() {
                                      existingImages.remove(image);
                                    });
                                  },
                                )

                            ],
                          ),
                        )



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

  Widget _imageTile (Widget image, VoidCallback onDelete) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 90,
            height: 90,
            child: image,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(allowMultiple: true, type: FileType.image, withData: true);

    if (result != null) {
      setState(() {
        _selectedImages = result.files;
      });
    }
  }
}
