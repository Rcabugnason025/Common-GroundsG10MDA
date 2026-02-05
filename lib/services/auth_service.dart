import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user_data.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString(_currentUserKey);
    if (currentUserEmail != null) {
      final usersJson = prefs.getString(_usersKey);
      if (usersJson != null) {
        final users = jsonDecode(usersJson) as Map<String, dynamic>;
        if (users.containsKey(currentUserEmail)) {
          final userData = users[currentUserEmail];
          _updateStaticUserData(userData);
        }
      }
    }
  }

  Future<bool> get isLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String bio = "Student | Developer",
    String course = "BS Computer Science",
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    Map<String, dynamic> users = {};

    if (usersJson != null) {
      users = jsonDecode(usersJson) as Map<String, dynamic>;
    }

    if (users.containsKey(email)) {
      return false; // User already exists
    }

    final newUser = {
      'name': name,
      'email': email,
      'password': password,
      'bio': bio,
      'course': course,
    };

    users[email] = newUser;
    await prefs.setString(_usersKey, jsonEncode(users));

    // Auto login after sign up
    await prefs.setString(_currentUserKey, email);
    _updateStaticUserData(newUser);

    return true;
  }

  Future<bool> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null) return false;

    final users = jsonDecode(usersJson) as Map<String, dynamic>;

    if (!users.containsKey(email)) return false;

    final user = users[email];
    if (user['password'] == password) {
      await prefs.setString(_currentUserKey, email);
      _updateStaticUserData(user);
      return true;
    }

    return false;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    // Reset UserData to defaults or clear it
    UserData.name = "";
    UserData.email = "";
    UserData.bio = "";
    UserData.course = "";
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? course,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString(_currentUserKey);

    if (currentUserEmail == null) return;

    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return;

    Map<String, dynamic> users = jsonDecode(usersJson) as Map<String, dynamic>;

    if (users.containsKey(currentUserEmail)) {
      if (name != null) users[currentUserEmail]['name'] = name;
      if (bio != null) users[currentUserEmail]['bio'] = bio;
      if (course != null) users[currentUserEmail]['course'] = course;

      await prefs.setString(_usersKey, jsonEncode(users));
      _updateStaticUserData(users[currentUserEmail]);
    }
  }

  void _updateStaticUserData(Map<String, dynamic> user) {
    UserData.name = user['name'] ?? "";
    UserData.email = user['email'] ?? "";
    UserData.bio = user['bio'] ?? "";
    UserData.course = user['course'] ?? "";
  }
}
