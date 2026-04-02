import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio _dio;
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired - redirect to login
        }
        return handler.next(error);
      },
    ));
  }

  // Auth
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      // Save token
      final token = response.data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _dio.get('/api/courses');
      return List<Map<String, dynamic>>.from(response.data['courses']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCourseById(int courseId) async {
    try {
      final response = await _dio.get('/api/courses/$courseId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Videos
  Future<List<Map<String, dynamic>>> getVideos({
    String? search,
    String? sortBy,
  }) async {
    try {
      final response = await _dio.get('/api/videos', queryParameters: {
        if (search != null) 'search': search,
        if (sortBy != null) 'sortBy': sortBy,
      });
      return List<Map<String, dynamic>>.from(response.data['videos']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getVideoById(int videoId) async {
    try {
      final response = await _dio.get('/api/videos/$videoId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> upvoteVideo(int videoId) async {
    try {
      await _dio.post('/api/videos/$videoId/upvote');
    } catch (e) {
      rethrow;
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getTeacherAnalytics() async {
    try {
      final response = await _dio.get('/api/analytics/teacher');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStudentAnalytics() async {
    try {
      final response = await _dio.get('/api/analytics/student');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}