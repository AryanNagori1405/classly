import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class StorageService {
  static const String _userKey = 'classly_user';
  static const String _tokenKey = 'classly_token';
  static const String _isAuthenticatedKey = 'classly_is_authenticated';

  /// Save user to local storage
  static Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode({
        'uid': user.uid,
        'regId': user.regId,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'department': user.department,
        'semester': user.semester,
        'profileImage': user.profileImage,
        'bio': user.bio,
        'enrolledCourses': user.enrolledCourses,
        'joinedCommunities': user.joinedCommunities,
        'coursesCount': user.coursesCount,
        'videosCount': user.videosCount,
        'rating': user.rating,
        'isVerified': user.isVerified,
        'createdAt': user.createdAt.toIso8601String(),
      });
      return await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  /// Get user from local storage
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) return null;

      final userMap = jsonDecode(userJson);
      return User(
        uid: userMap['uid'],
        regId: userMap['regId'],
        name: userMap['name'],
        email: userMap['email'],
        role: userMap['role'],
        department: userMap['department'],
        semester: userMap['semester'],
        profileImage: userMap['profileImage'],
        bio: userMap['bio'],
        enrolledCourses: List<String>.from(userMap['enrolledCourses'] ?? []),
        joinedCommunities:
            List<String>.from(userMap['joinedCommunities'] ?? []),
        coursesCount: userMap['coursesCount'] ?? 0,
        videosCount: userMap['videosCount'] ?? 0,
        rating: (userMap['rating'] ?? 0).toDouble(),
        isVerified: userMap['isVerified'] ?? false,
        createdAt: DateTime.parse(userMap['createdAt']),
      );
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Save token to local storage
  static Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Error saving token: $e');
      return false;
    }
  }

  /// Get token from local storage
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Set authentication state
  static Future<bool> setAuthenticated(bool isAuthenticated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_isAuthenticatedKey, isAuthenticated);
    } catch (e) {
      print('Error setting authentication: $e');
      return false;
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isAuthenticatedKey) ?? false;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  /// Clear all data (logout)
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_isAuthenticatedKey);
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
}