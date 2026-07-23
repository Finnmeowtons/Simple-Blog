import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/models/post_model.dart';
import 'package:simple_blog/providers/post_provider.dart';
import 'package:simple_blog/services/post_service.dart';

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
                final currentUser = context.watch<AuthProvider>().user;
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
              if (isOwner)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final success = await context.read<PostProvider>().deletePost(id: post.id);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post deleted!")));
                        }
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(title: const Text("Update Post"));
                          },
                        );
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

  Widget _createPostForm() {

    return SizedBox(
      width: 600,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
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
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                    
                            final success = await context.read<PostProvider>().createPost(title: _titleController.text.trim(), content: _contentController.text.trim());
                    
                            if (success && context.mounted) {
                              _titleController.clear();
                              _contentController.clear();
                    
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post created!")));
                            }
                          },
                          child: provider.loading ? const CircularProgressIndicator() : const Text("Submit"),
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  children: _selectedImages.map((file) {
                    return ListTile(
                      leading: const Icon(Icons.image),
                      title: Text(file.name),
                    );
                  }).toList(),
                ),
              ],
            ),
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
