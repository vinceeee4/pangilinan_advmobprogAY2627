import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../models/firebase_profile.dart';
import '../models/login_type.dart';
import '../models/profile_data.dart';
import '../models/user.dart';

class UserService {
  static const String _userKey = 'authenticated_user';
  static const String _loginTypeKey = 'login_type';
  static const String _firebaseProfilePrefix = 'firebase_profile_';

  // ---------------------------------------------------------------------
  // Lab Activity 4: DummyJSON authentication
  // ---------------------------------------------------------------------

  Future<User> loginUser(String username, String password) async {
    final http.Response response = await http
        .post(
          Uri.parse('$kDummyJsonBaseUrl/auth/login'),
          headers: const <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, String>{
            'username': username,
            'password': password,
            'expiresInMins': '60',
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200)
      throw Exception('Incorrect username or password.');
    final dynamic body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>)
      throw Exception('Invalid sign-in response.');
    final User user = User.fromJson(body);
    if (user.id == 0)
      throw Exception('The account did not include a user ID.');
    await saveUser(user);
    await setLoginType(LoginType.dummyJson);
    return user;
  }

  Future<void> saveUser(User user) async =>
      (await SharedPreferences.getInstance()).setString(
        _userKey,
        jsonEncode(user.toJson()),
      );

  Future<User?> getUser() async {
    final String? value = (await SharedPreferences.getInstance()).getString(
      _userKey,
    );
    if (value == null) return null;
    try {
      final dynamic json = jsonDecode(value);
      return json is Map<String, dynamic> ? User.fromJson(json) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async =>
      (await SharedPreferences.getInstance()).remove(_userKey);

  // ---------------------------------------------------------------------
  // Lab Activity 5, Enhancement 1: Firebase Authentication
  // Your previous code here
  // Just add this code under the previous code
  // ---------------------------------------------------------------------

  final firebase_auth.FirebaseAuth firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  firebase_auth.User? get currentFirebaseUser => firebaseAuth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges =>
      firebaseAuth.authStateChanges();

  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final firebase_auth.UserCredential credential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    await setLoginType(LoginType.firebase);
    // Lab Activity 6: backfill/refresh this user's Firestore "Users" doc on
    // every sign-in, so chat always has an up-to-date directory entry even
    // for accounts created before the chat feature existed.
    final FirebaseProfile? profile = await getFirebaseProfile();
    await upsertFirestoreUser(
      uid: credential.user!.uid,
      email: credential.user!.email ?? email,
      firstName: profile?.fName,
      lastName: profile?.lName,
      username: profile?.username,
    );
    return credential;
  }

  Future<firebase_auth.UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    final firebase_auth.UserCredential credential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    await setLoginType(LoginType.firebase);
    return credential;
  }

  Future<void> signOut() async => firebaseAuth.signOut();

  Future<void> updateUsername({required String username}) async {
    await currentFirebaseUser!.updateDisplayName(username);
    await currentFirebaseUser!.reload();
    // Keep the Firestore directory entry (used by chat) in sync too.
    await upsertFirestoreUser(
      uid: currentFirebaseUser!.uid,
      email: currentFirebaseUser!.email ?? '',
      username: username,
    );
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final firebase_auth.AuthCredential credential = firebase_auth
        .EmailAuthProvider.credential(email: email, password: password);
    final firebase_auth.User user = currentFirebaseUser!;
    final String uid = user.uid;

    await user.reauthenticateWithCredential(credential);
    await user.delete();
    await firebaseAuth.signOut();
    await _clearFirebaseProfile(uid);
    await _firestore.collection('Users').doc(uid).delete();
    (await SharedPreferences.getInstance()).remove(_loginTypeKey);
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    final firebase_auth.AuthCredential credential = firebase_auth
        .EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
    await currentFirebaseUser!.reauthenticateWithCredential(credential);
    await currentFirebaseUser!.updatePassword(newPassword);
  }

  // ---------------------------------------------------------------------
  // Lab Activity 6: Firestore "Users" directory used by the chat feature
  // ---------------------------------------------------------------------

  /// Mirrors the signed-in Firebase user into a Firestore 'Users' document
  /// (doc id = uid), so the chat feature has a queryable, realtime list of
  /// registered users to show in the chat list.
  Future<void> upsertFirestoreUser({
    required String uid,
    required String email,
    String? firstName,
    String? lastName,
    String? username,
  }) async {
    await _firestore.collection('Users').doc(uid).set(<String, dynamic>{
      'uid': uid,
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (username != null) 'username': username,
    }, SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------
  // Enhancement 2 & 3: Session + profile helpers shared by both backends
  // ---------------------------------------------------------------------

  Future<void> setLoginType(LoginType type) async =>
      (await SharedPreferences.getInstance()).setString(
        _loginTypeKey,
        type == LoginType.firebase ? 'firebase' : 'dummyJson',
      );

  Future<LoginType?> getLoginType() async {
    final String? value = (await SharedPreferences.getInstance()).getString(
      _loginTypeKey,
    );
    if (value == 'firebase') return LoginType.firebase;
    if (value == 'dummyJson') return LoginType.dummyJson;
    return null;
  }

  /// Add Logout button -> clears session/token and redirects to login.
  /// Ends whichever session is active and clears the saved login type, so
  /// one Logout button in Settings/Profile works for both backends.
  Future<void> endSession() async {
    final LoginType? type = await getLoginType();
    if (type == LoginType.firebase) {
      await signOut();
    } else {
      await logout();
    }
    (await SharedPreferences.getInstance()).remove(_loginTypeKey);
  }

  /// True when either a DummyJSON session was saved or Firebase still has a
  /// signed-in user - used by the splash screen's persistent-login check.
  Future<bool> isLoggedIn() async {
    final LoginType? type = await getLoginType();
    if (type == LoginType.firebase) return currentFirebaseUser != null;
    if (type == LoginType.dummyJson) return (await getUser()) != null;
    return false;
  }

  Future<void> saveFirebaseProfile(FirebaseProfile profile) async =>
      (await SharedPreferences.getInstance()).setString(
        '$_firebaseProfilePrefix${profile.uid}',
        jsonEncode(profile.toJson()),
      );

  Future<FirebaseProfile?> getFirebaseProfile() async {
    final firebase_auth.User? user = currentFirebaseUser;
    if (user == null) return null;
    final String? value = (await SharedPreferences.getInstance()).getString(
      '$_firebaseProfilePrefix${user.uid}',
    );
    if (value == null) return null;
    try {
      final dynamic json = jsonDecode(value);
      return json is Map<String, dynamic>
          ? FirebaseProfile.fromJson(json)
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearFirebaseProfile(String uid) async =>
      (await SharedPreferences.getInstance()).remove(
        '$_firebaseProfilePrefix$uid',
      );

  /// Enhancement 3: Single entry point the Profile screen calls - returns
  /// the right data shape for whichever backend authenticated this session.
  Future<ProfileData?> getUserData() async {
    final LoginType? type = await getLoginType();
    if (type == LoginType.firebase) {
      final firebase_auth.User? user = currentFirebaseUser;
      if (user == null) return null;
      final FirebaseProfile? extras = await getFirebaseProfile();
      return ProfileData.fromFirebase(user, extras);
    }
    if (type == LoginType.dummyJson) {
      final User? user = await getUser();
      if (user == null) return null;
      return ProfileData.fromDummyJson(user);
    }
    return null;
  }
}
