import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/models/post_model.dart';
import 'package:simple_blog/providers/comment_provider.dart';
import 'package:simple_blog/widgets/comment_card.dart';
import 'package:simple_blog/widgets/image_tile.dart';

import '../models/comment_image_model.dart';
import '../models/comment_model.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

class CommentScreen extends StatefulWidget {
  final Post post;
  final VoidCallback onClose;
  const CommentScreen({super.key, required this.post, required this.onClose});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  Comment? _editingComment;
  final _commentFormKey = GlobalKey<FormState>();

  final _commentController = TextEditingController();
  final List<CommentImage> _existingImages = [];
  final List<PlatformFile> _newImages = [];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<CommentProvider>().getComments(
        postId: widget.post.id,
      );
    });
  }
  @override
  void didUpdateWidget(covariant CommentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post.id != widget.post.id) {
      _commentController.clear();
      _newImages.clear();
      _existingImages.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        context.read<CommentProvider>().getComments(
          postId: widget.post.id,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Comments"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<CommentProvider>(
              builder: (context, provider, child) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }
                if (provider.comments.isEmpty) {
                  return const Center(child: Text("No comments found."));
                } else if (provider.comments.isEmpty && currentUser == null) {
                  return const Center(child: Text("Please login to comment."));
                }
                return ListView.builder(
                  itemCount: provider.comments.length,
                  itemBuilder: (context, index) {
                    final comment = provider.comments[index];

                    return CommentCard(
                      comment: comment,
                      onEdit: () {
                        setState(() {
                          _editingComment = comment;
                          _commentController.text = comment.content;
                          _existingImages
                            ..clear()
                            ..addAll(comment.images);
                          _newImages.clear();
                        });
                      },
                      onDelete: () async {
                        await context.read<CommentProvider>().deleteComment(comment: comment);
                      },
                    );
                  },
                );
              },
            ),
          ),

          if (currentUser != null)
            _commentField(),
        ],
      ),
    );
  }

  Widget _commentField() {
    const int maxImages = 3;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            if (_newImages.isNotEmpty || _existingImages.isNotEmpty)
              SizedBox(
                height: 100,
                width: 600,
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final file in _newImages)
                        ImageTile(
                          image: Image.memory(file.bytes!, width: 80, height: 80, fit: BoxFit.cover),
                          onDelete: () {
                            setState(() {
                              _newImages.remove(file);
                            });
                          },
                        ),

                      for (final image in _existingImages)
                        ImageTile(
                          image: Image.network(StorageService().getImageUrl(image.imagePath), width: 80, height: 80, fit: BoxFit.cover),
                          onDelete: () {
                            setState(() {
                              _existingImages.remove(image);
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            Form(
              key: _commentFormKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a comment";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(hintText: "Write a comment...", border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await FilePicker.pickFiles(allowMultiple: true, type: FileType.image, withData: true);

                      if (result == null) return;

                      final totalImages = _existingImages.length + _newImages.length;
                      final remainingSlots = maxImages - totalImages;

                      if (remainingSlots <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can upload a maximum of 3 images.")));
                        return;
                      }

                      setState(() {
                        for (final file in result.files.take(remainingSlots)) {
                          if (!_newImages.any((e) => e.name == file.name)) {
                            _newImages.add(file);
                          }
                        }
                      });
                    },
                    icon: const Icon(Icons.attach_file),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (!_commentFormKey.currentState!.validate()) return;
                      if (_editingComment != null) {
                        await context.read<CommentProvider>().updateComment(
                          comment: _editingComment!,
                          content: _commentController.text.trim(),
                          remainingImages: _existingImages,
                          newImages: _newImages,);
                      } else {
                        await context.read<CommentProvider>().createComment(postId: widget.post.id, content: _commentController.text.trim(), images: _newImages);
                      }
                      setState(() {
                        _commentController.clear();
                        _newImages.clear();
                        _existingImages.clear();
                      });
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
