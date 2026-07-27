import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../services/storage_service.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isOwner;
  final String email;
  final VoidCallback onComment;
  final VoidCallback onEdit;
  const PostCard({super.key, required this.post, required this.isOwner, required this.email, required this.onComment, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    debugPrint("PostCard${post.id} build ");
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    print("Comment Pressed");
                    onComment();
                  },
                  icon: Icon(Icons.comment),
                ),

                if (isOwner)
                  Row(
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
                          onEdit();
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
