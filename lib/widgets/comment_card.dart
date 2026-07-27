import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment_model.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;
    final isOwner = currentUser?.id == widget.comment.userId;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              child: Icon(Icons.person),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(widget.comment.content),
                    ),
                  ),

                  if (widget.comment.images.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.comment.images.length,
                        itemBuilder: (context, index) {
                          final image = widget.comment.images[index];

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                StorageService().getImageUrl(image.imagePath),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            if (isOwner)
              Visibility(
                visible: isOwner && _hovering,
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
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              size: 18, color: Colors.red),
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