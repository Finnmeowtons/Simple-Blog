import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/widgets/post_card.dart';

import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/post_detail_provider.dart';
import '../widgets/post_form.dart';
import 'comment_screen.dart';

class PostScreen extends StatefulWidget {
  final int postId;
  const PostScreen({super.key, required this.postId});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool _showComments = false;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PostDetailProvider>().getPost(widget.postId);
    });
  }
  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;

    return Consumer<PostDetailProvider>(
      builder: (context, provider, child) {
        if (provider.loading || provider.post == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            body: Center(child: Text(provider.error!)),
          );
        }

        final post = provider.post;
        final isOwner = currentUser?.id == post!.userId;


      return Scaffold(
        appBar: AppBar(
          title: Text("Forum"),
          centerTitle: true,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: PostCard(
              post: provider.post!,
              isOwner: isOwner,
              onComment: () {
                setState(() {
                  _showComments = true;
                });
              },
              onEdit: () {
              
                showPostFormDialog(provider.post);
              },
              showCommentButton: true,
              showOwnerMenu: isOwner,
              isSinglePost: true,
                        ),
            ),



              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                right: _showComments ? 16 : -470,
                top: 16,
                bottom: 16,
                child: Material(
                  elevation: 12,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 450,
                    child: CommentScreen(
                      post: post,
                      onClose: () {
                        setState(() {
                          _showComments = false;
                        });},
                    ),
                  ),
                ),
              )
          ]
        ),
      );}
    );
  }
  Future<void> showPostFormDialog(Post? post) async {
    return showDialog(
      context: context,
      builder: (context) {
        return PostForm(post: post);
      },
    );
  }
}