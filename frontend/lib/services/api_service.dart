import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Login failed: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Login with Registration Number and Password
  Future<Map<String, dynamic>> loginWithCredentials({
    required String registrationNumber,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login-credentials'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'registrationNumber': registrationNumber,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Login failed: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Login with UID and Registration ID
  Future<Map<String, dynamic>> loginWithUID({
    required String uid,
    required String regId,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login-uid'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': uid,
          'regId': regId,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'UID verification failed: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Register with email and password
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String uid,
    required String regId,
    required String department,
    required String semester,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'uid': uid,
          'regId': regId,
          'department': department,
          'semester': semester,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw 'Registration failed: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Logout
  Future<void> logout({required String token}) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      throw 'Logout failed: $e';
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to fetch profile: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to update profile: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Get all videos/lectures
  Future<Map<String, dynamic>> getVideos({
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to fetch videos: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Upload a new lecture/video
  Future<Map<String, dynamic>> uploadLecture({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/videos/upload'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to upload lecture: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Get all communities
  Future<Map<String, dynamic>> getCommunities({
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/communities?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to fetch communities: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Join a community
  Future<Map<String, dynamic>> joinCommunity({
    required String token,
    required String communityId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/communities/$communityId/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to join community: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Get all doubts
  Future<Map<String, dynamic>> getDoubts({
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doubts?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to fetch doubts: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Create a new doubt
  Future<Map<String, dynamic>> createDoubt({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/doubts/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to create doubt: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  /// Reply to a doubt
  Future<Map<String, dynamic>> replyToDoubt({
    required String token,
    required String doubtId,
    required String reply,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/doubts/$doubtId/reply'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reply': reply}),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to reply to doubt: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }
}