import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  final Image image;
  final VoidCallback onDelete;
  const ImageTile({super.key, required this.image, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    debugPrint("Image");
    debugPrint("Image $image");

      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 90,
              height: 90,
              child: image,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
  }
}
