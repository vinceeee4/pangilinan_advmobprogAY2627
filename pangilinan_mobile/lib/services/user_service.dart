import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import '../models/user.dart';

class UserService {
  static const String _userKey = 'authenticated_user';

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
    if (user.id == 0) throw Exception('The account did not include a user ID.');
    await saveUser(user);
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

  Future<bool> isLoggedIn() async => (await getUser()) != null;
  Future<void> logout() async =>
      (await SharedPreferences.getInstance()).remove(_userKey);
}
