import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/models/post_model.dart';
import 'package:simple_blog/providers/post_provider.dart';
import 'package:simple_blog/services/post_service.dart';
import 'package:simple_blog/services/storage_service.dart';

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
          _createPostForm(),
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

  PreferredSizeWidget _appBar(){
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

  Widget _buildPost(Post post, bool isOwner, String email) {
    return Center(
      child: SizedBox(
        width: 300,
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(email),
              ListTile(title: Text(post.title), subtitle: Text(post.content)),
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
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
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
                        showUpdateDialog(post);
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showUpdateDialog(Post post) async {
    final updateFormKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);

    final List<PostImage> existingImages = List.from(post.images);
    final List<PlatformFile> newImages = [];

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Update Post"),
              content: SizedBox(
                width: 600,
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                          key: updateFormKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(labelText: "Title"),
                                controller: titleController,
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
                                controller: contentController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter content";
                                  }
                                  return null;
                                },
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      // await FilePicker.clearTemporaryFiles();
                                      final result = await FilePicker.pickFiles(
                                        allowMultiple: true,
                                        type: FileType.image,
                                        withData: true,
                                      );

                                      if (result != null) {
                                        setDialogState(() {
                                          for (final file in result.files) {
                                            if (!newImages.any((e) => e.name == file.name)) {
                                              newImages.add(file);
                                            }
                                          }
                                        });
                                      }
                                    },
                                    child: const Text("Add Images"),
                                  ),
                                  Consumer<PostProvider>(
                                    builder: (context, provider, child) {
                                      return ElevatedButton(
                                        onPressed: provider.loading ? null : () async {
                                          if (!updateFormKey.currentState!.validate()) {
                                            return;
                                          }

                                          final success = await context.read<PostProvider>().updatePost(
                                            post: post,
                                            title: titleController.text.trim(),
                                            content: contentController.text.trim(),
                                            remainingImages: existingImages,
                                            newImages: newImages,
                                          );


                                          if (success && context.mounted) {
                                            print("SUCCESS!");
                                            Navigator.pop(context);
                                            titleController.clear();
                                            contentController.clear();

                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post updated!")));

                                            setState(() {
                                              existingImages.clear();
                                            });
                                          }
                                        },
                                        child: provider.loading
                                            ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                            : const Text("Submit"),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16,),
                        if (existingImages.isNotEmpty)
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: existingImages.length,
                              itemBuilder: (context, index) {
                                final image = existingImages[index];

                                return Stack(
                                  children: [
                                    Image.network(
                                      StorageService().getImageUrl(image.imagePath),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          setDialogState(() {
                                            existingImages.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: newImages.length,
                            itemBuilder: (context, index) {
                              final file = newImages[index];

                              return Stack(
                                children: [
                                  Image.memory(
                                    file.bytes!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setDialogState(() {
                                          newImages.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // if (existingImages.isNotEmpty)
                        //   Text("${existingImages.length} image(s) selected"),
                      ],
                    ),
                  ),
                ),
              )
            );
          },
        );
      },
    );
  }

  Widget _createPostForm() {

    return
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
                        ElevatedButton(
                          onPressed: () => _pickImages(),
                          child: const Text("Upload Image"),
                        ),
                        Consumer<PostProvider>(
                          builder: (context, provider, child) {
                            return ElevatedButton(
                              onPressed: provider.loading ? null : () async {
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
                                child: provider.loading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const Text("Submit"),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16,),
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
                        child: Image.memory(
                          file.bytes!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_selectedImages.isNotEmpty)
                Text("${_selectedImages.length} image(s) selected"),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedImages = result.files;
      });
    }
  }
}
