class CommentImage {
  final int id;
  final String imagePath;

  CommentImage({
    required this.id,
    required this.imagePath,
  });

  factory CommentImage.fromJson(Map<String, dynamic> json) {
    return CommentImage(
      id: json['id'],
      imagePath: json['image_path'],
    );
  }
}