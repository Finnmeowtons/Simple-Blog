import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zo_animated_border/widget/zo_dual_border.dart';

import '../providers/auth_provider.dart';
import '../providers/post_list_provider.dart';
import '../widgets/post_form.dart';
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
      context.read<PostListProvider>().getPosts();
    });
  }

  @override
  void dispose() {
    _selectedPost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: _appBar(currentUser),
      body: Stack(
        children: [
          Column(
            children: [

              if (currentUser != null)
              Column(
                children: [
                  SizedBox(height: 16),
                  _createPostForm(),
                  SizedBox(height: 16),
                ],
              ),
              Expanded(
                child: PostList(
                  currentUserId: currentUser?.id,
                ),
              )
            ],
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
        child: InkWell(
          onTap: () {
            showPostFormDialog(null);
          },
          child: Center(
            child: Text('Create Post', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
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
