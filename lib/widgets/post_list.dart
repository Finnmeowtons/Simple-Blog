import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/widgets/post_card.dart';

import '../models/post_model.dart';
import '../providers/post_detail_provider.dart';
import '../providers/post_list_provider.dart';

class PostList extends StatelessWidget {
  final String? currentUserId;

  const PostList({
    super.key,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PostListProvider>(
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
          itemCount: provider.posts.length,
          itemBuilder: (context, index) {
            final post = provider.posts[index];

            return PostCard(
              post: post,
              isOwner: currentUserId == post.userId,
              onComment: () {},
              onEdit: () {},

            );
          },
        );
      },
    );
  }
}