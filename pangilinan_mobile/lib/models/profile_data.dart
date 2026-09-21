import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'firebase_profile.dart';
import 'login_type.dart';
import 'user.dart';

/// Enhancement 3: A single shape the Profile screen can render, no matter
/// which backend (DummyJSON or Firebase) authenticated the current session.
class ProfileData {
  final LoginType loginType;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final String? age;
  final String? contactNo;

  const ProfileData({
    required this.loginType,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.age,
    this.contactNo,
  });

  factory ProfileData.fromDummyJson(User user) => ProfileData(
    loginType: LoginType.dummyJson,
    displayName: user.username,
    email: user.email,
    photoUrl: user.image.isEmpty ? null : user.image,
    firstName: user.firstName,
    lastName: user.lastName,
  );

  factory ProfileData.fromFirebase(
    firebase_auth.User user,
    FirebaseProfile? extras,
  ) => ProfileData(
    loginType: LoginType.firebase,
    displayName: (user.displayName?.isNotEmpty ?? false)
        ? user.displayName!
        : (extras?.username ?? user.email ?? 'Firebase user'),
    email: user.email ?? extras?.email ?? '',
    photoUrl: user.photoURL,
    firstName: extras?.fName,
    lastName: extras?.lName,
    age: extras?.age,
    contactNo: extras?.contactNo,
  );
}
