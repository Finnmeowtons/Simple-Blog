class PostImage {
  final int id;
  final String imagePath;

  PostImage({
    required this.id,
    required this.imagePath,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      id: json['id'],
      imagePath: json['image_path'],
    );
  }
}