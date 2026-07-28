class Profile {
  final String id;
  final String email;

  const Profile({
    required this.id,
    required this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }

  Profile copyWith({
    String? id,
    String? email,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }
}