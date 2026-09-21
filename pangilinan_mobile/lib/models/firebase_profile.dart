/// Enhancement 2: Extra sign-up fields collected on `signup_screen.dart`
/// that Firebase Auth's email/password user doesn't store natively
/// (Firebase Auth only keeps uid, email, displayName, photoURL, phone).
/// Kept locally per Firebase uid, matching the fields dummyjson.com/users
/// exposes so the two backends can be compared fairly.
class FirebaseProfile {
  final String uid;
  final String fName;
  final String lName;
  final String age;
  final String contactNo;
  final String username;
  final String email;

  const FirebaseProfile({
    required this.uid,
    required this.fName,
    required this.lName,
    required this.age,
    required this.contactNo,
    required this.username,
    required this.email,
  });

  factory FirebaseProfile.fromJson(Map<String, dynamic> json) =>
      FirebaseProfile(
        uid: json['uid']?.toString() ?? '',
        fName: json['fName']?.toString() ?? '',
        lName: json['lName']?.toString() ?? '',
        age: json['age']?.toString() ?? '',
        contactNo: json['contactNo']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'fName': fName,
    'lName': lName,
    'age': age,
    'contactNo': contactNo,
    'username': username,
    'email': email,
  };
}
