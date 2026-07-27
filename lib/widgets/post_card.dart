import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../services/storage_service.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isOwner;
  final VoidCallback onComment;
  final VoidCallback onEdit;

  const PostCard({super.key, required this.post, required this.isOwner, required this.onComment, required this.onEdit});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _hovering = false;

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            elevation: 1,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),

                  const SizedBox(height: 10),

                  Text(widget.post.content, style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),

                  if (widget.post.images.isNotEmpty) ...[
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 280,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: widget.post.images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final image = widget.post.images[index];

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(StorageService().getImageUrl(image.imagePath), fit: BoxFit.fitHeight, height: 200,),
                              );
                            },
                          ),

                          if (widget.post.images.length > 1)...[

                            Positioned(
                              left: 8,
                              top: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: const Icon(Icons.chevron_left),
                                color: Colors.black,
                                onPressed: _currentPage == 0
                                    ? null
                                    : () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                              ),
                            ),

                            Positioned(
                              right: 8,
                              top: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: const Icon(Icons.chevron_right),
                                color: Colors.black,
                                onPressed: _currentPage ==
                                    widget.post.images.length - 1
                                    ? null
                                    : () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  widget.post.images.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentPage == index ? 18 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: _currentPage == index ? Colors.black : Colors.black54),
                                  ),
                                ),
                              ),
                            ),]
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      FilledButton.icon(onPressed: widget.onComment, icon: const Icon(Icons.comment_outlined), label: const Text("Comments")),

                      const Spacer(),

                      if (widget.isOwner)
                        Visibility(
                          visible: widget.isOwner && _hovering,
                          maintainAnimation: true,
                          maintainState: true,
                          maintainSize: true,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              switch (value) {
                                case "edit":
                                  widget.onEdit();
                                  break;

                                case "delete":
                                  final success = await context.read<PostProvider>().deletePost(post: widget.post);

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post deleted")));
                                  }
                                  break;
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: "edit",
                                child: ListTile(leading: Icon(Icons.edit), title: Text("Edit")),
                              ),
                              PopupMenuItem(
                                value: "delete",
                                child: ListTile(leading: Icon(Icons.delete), title: Text("Delete")),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
