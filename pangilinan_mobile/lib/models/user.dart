class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String accessToken;
  final String refreshToken;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] is int
        ? json['id'] as int
        : int.tryParse('${json['id']}') ?? 0,
    username: json['username']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    firstName: json['firstName']?.toString() ?? '',
    lastName: json['lastName']?.toString() ?? '',
    gender: json['gender']?.toString() ?? '',
    image: json['image']?.toString() ?? '',
    accessToken: (json['accessToken'] ?? json['token'])?.toString() ?? '',
    refreshToken: json['refreshToken']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'gender': gender,
    'image': image,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}
