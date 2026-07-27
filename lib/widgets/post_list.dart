import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/widgets/post_card.dart';

import '../models/post_model.dart';
import '../providers/post_provider.dart';

class PostList extends StatelessWidget {
  final String? currentUserId;
  final ValueChanged<Post> onComment;
  final ValueChanged<Post> onEdit;

  const PostList({
    super.key,
    required this.currentUserId,
    required this.onComment,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        if (provider.posts.isEmpty) {
          return const Center(child: Text("No posts found."));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          // reverse: true,
          itemCount: provider.posts.length,
          itemBuilder: (context, index) {
            final post = provider.posts[index];

            return PostCard(
              post: post,
              isOwner: currentUserId == post.userId,
              onComment: () => onComment(post),
              onEdit: () => onEdit(post),
            );
          },
        );
      },
    );
  }
}