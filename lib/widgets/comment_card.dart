import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment_model.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommentCard({super.key, required this.comment, this.onEdit, this.onDelete});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _hovering = false;

  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    if (widget.comment.images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!_pageController.hasClients) return;

        _currentPage++;

        if (_currentPage >= widget.comment.images.length) {
          _currentPage = 0;
        }

        _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;
    final isOwner = currentUser?.id == widget.comment.userId;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(padding: const EdgeInsets.all(12), child: Text(widget.comment.content)),
                  ),

                  if (widget.comment.images.isNotEmpty) ...[
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: widget.comment.images.length,
                            itemBuilder: (context, index) {
                              final image = widget.comment.images[index];

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(StorageService().getImageUrl(image.imagePath), fit: BoxFit.fitHeight, width: double.infinity),
                              );
                            },
                          ),

                          if (widget.comment.images.length > 1)
                            Positioned(
                              bottom: 10,
                              child: Row(
                                children: List.generate(
                                  widget.comment.images.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: _currentPage == index ? 18 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(color: _currentPage == index ? Colors.white : Colors.white54, borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (isOwner)
              Visibility(
                visible: _hovering,
                maintainAnimation: true,
                maintainState: true,
                maintainSize: true,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (value) {
                    switch (value) {
                      case "edit":
                        widget.onEdit?.call();
                        break;
                      case "delete":
                        widget.onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: "edit",
                      child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")]),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text("Delete"),
                        ],
                      ),
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
