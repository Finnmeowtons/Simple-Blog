import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post_image_model.dart';
import '../models/post_model.dart';
import '../providers/post_detail_provider.dart';
import '../providers/post_list_provider.dart';
import '../services/storage_service.dart';
import 'image_tile.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  const PostForm({super.key, this.post});

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final postFormKey = GlobalKey<FormState>();

  final titleController = TextEditingController();

  final contentController = TextEditingController();

  final ScrollController newImagesScrollController = ScrollController();

  final ScrollController existingImagesScrollController = ScrollController();

  int maxImages = 5;

  late final ValueNotifier<List<PostImage>> existingImages;
  final ValueNotifier<List<PlatformFile>> newImages =
  ValueNotifier([]);

  bool get isNewPost => widget.post == null;

  @override
  void initState() {
    super.initState();

    titleController.text = widget.post?.title ?? "";
    contentController.text = widget.post?.content ?? "";

    existingImages = ValueNotifier(
      List.from(widget.post?.images ?? []),
    );
  }

  @override
  void dispose() {
    existingImages.dispose();
    newImages.dispose();
    titleController.dispose();
    contentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
          return AlertDialog(
            title: Text(isNewPost ? "Create Post" : "Edit Post"),
            actions: [
              SizedBox(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Consumer<PostListProvider>(
                    builder: (context, provider, child) {
                      return ElevatedButton(
                        onPressed: provider.loading
                            ? null
                            : () async {
                          if (!postFormKey.currentState!.validate()) {
                            return;
                          }

                          if (isNewPost) {
                            existingImages.value = List.from(existingImages.value)
                              ..clear();
                          }
                          bool success = false;

                          if (isNewPost) {
                            final createdPost = await context.read<PostListProvider>().createPost(
                              title: normalizeTitle(titleController.text),
                              content: normalizeText(contentController.text),
                              images: newImages.value,
                            );

                            if (createdPost == null) return;
                            success = true;
                          } else {
                            final updatedPost = await context.read<PostDetailProvider>().updatePost(
                              title: normalizeTitle(titleController.text),
                              content: normalizeText(contentController.text),
                              remainingImages: existingImages.value,
                              newImages: newImages.value,
                            );

                            if (updatedPost != null) {
                              context.read<PostListProvider>().replacePost(updatedPost);
                              success = true;
                            }
                          }

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            titleController.clear();
                            contentController.clear();

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: isNewPost ? const Text("Post created!") : const Text("Post updated!")));

                            existingImages.value = List.from(existingImages.value)
                              ..clear();
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
                    postTextFields(),
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

                        final totalImages = existingImages.value.length + newImages.value.length;
                        final remainingSlots = maxImages - totalImages;

                        if (remainingSlots <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can upload a maximum of 5 images.")));
                          return;
                        }

                        final updated = List<PlatformFile>.from(newImages.value);

                        for (final file in result.files.take(remainingSlots)) {
                          if (!updated.any((e) => e.name == file.name)) {
                            updated.add(file);
                          }
                        }

                        newImages.value = updated;
                      },
                      child: DottedBorder(
                        options: RectDottedBorderOptions(dashPattern: [8, 2], strokeWidth: 2, padding: EdgeInsets.all(16), color: Colors.black26),
                        child:
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            newImages,
                            existingImages,
                          ]),
                          builder: (context, _) {
                            return newImages.value.isEmpty && existingImages.value.isEmpty
                            ? emptyImages()
                            : SizedBox(
                          height: 100,
                          width: 600,
                          child: Center(
                            child:Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    ...newImages.value.map(
                                          (file) => ImageTile(
                                        image: Image.memory(
                                          file.bytes!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                        onDelete: () {
                                          newImages.value = List.from(newImages.value)
                                            ..remove(file);
                                        },
                                      ),
                                    ),

                                    ...existingImages.value.map(
                                          (image) => ImageTile(
                                        image: Image.network(
                                          StorageService().getImageUrl(image.imagePath),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                        onDelete: () {
                                          existingImages.value = List.from(existingImages.value)
                                            ..remove(image);
                                        },
                                      ),
                                    ),
                                  ],
                                )));
                              },
                            )
                          )
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget emptyImages(){
    return SizedBox(
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
    );
  }

  Widget postTextFields() {
    return Form(
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
            maxLength: 70,
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
            maxLength: 1000,
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
    );
  }

  String normalizeTitle(String text) {
    return text
        .replaceAll(RegExp(r'\s*\n+\s*'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String normalizeText(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}

