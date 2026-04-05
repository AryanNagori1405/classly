import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isFirstTimeLogin = false;
  bool _useLocalStorage = true;

  AuthProvider(this._apiService) {
    _loadUserFromStorage();
  }

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isFirstTimeLogin => _isFirstTimeLogin;

  /// Load user from local storage on app startup
  Future<void> _loadUserFromStorage() async {
    try {
      final isAuth = await StorageService.isAuthenticated();
      if (isAuth) {
        final user = await StorageService.getUser();
        final token = await StorageService.getToken();
        
        if (user != null && token != null) {
          _user = user;
          _token = token;
          debugPrint('User loaded from storage: ${user.name}');
        } else {
          await StorageService.clearAll();
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user data';
      debugPrint('Error loading user from storage: $e');
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_useLocalStorage) {
        // Local storage mode - simulate login
        await Future.delayed(const Duration(seconds: 2));

        _user = User(
          uid: 'STU${DateTime.now().millisecondsSinceEpoch}',
          regId: 'REG${DateTime.now().millisecondsSinceEpoch}',
          name: 'User',
          email: email,
          role: 'student',
          department: 'Computer Science',
          semester: '1',
          profileImage: 'https://via.placeholder.com/100',
          bio: '',
          enrolledCourses: const [],
          joinedCommunities: const [],
          createdAt: DateTime.now(),
          isVerified: true,
        );
        _token = 'local_token_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // API mode
        final response = await _apiService.login(
          email: email,
          password: password,
        );

        _user = User(
          uid: response['user']['uid'] ?? 'STU001',
          regId: response['user']['regId'] ?? 'REG001',
          name: response['user']['name'] ?? 'User',
          email: response['user']['email'] ?? email,
          role: response['user']['role'] ?? 'student',
          department: response['user']['department'] ?? 'CS',
          semester: response['user']['semester'] ?? '1',
          profileImage: response['user']['profileImage'],
          bio: response['user']['bio'],
          createdAt: DateTime.now(),
        );

        _token = response['token'];
      }

      // Save to local storage
      if (_user != null && _token != null) {
        await StorageService.saveUser(_user!);
        await StorageService.saveToken(_token!);
        await StorageService.setAuthenticated(true);
      }

      _isFirstTimeLogin = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// Login using Registration Number and Password
  Future<bool> loginWithCredentials({
    required String registrationNumber,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_useLocalStorage) {
        // Local storage mode - simulate login
        await Future.delayed(const Duration(seconds: 2));

        _user = User(
          uid: 'STU${DateTime.now().millisecondsSinceEpoch}',
          regId: registrationNumber,
          name: 'Student User',
          email: '$registrationNumber@college.edu',
          role: role,
          department: 'Computer Science',
          semester: '4',
          profileImage: 'https://via.placeholder.com/100',
          bio: 'Welcome to Classly!',
          enrolledCourses: const [],
          joinedCommunities: const [],
          coursesCount: 0,
          videosCount: 0,
          rating: 0.0,
          createdAt: DateTime.now(),
          isVerified: true,
        );
        _token = 'local_token_$registrationNumber';
      } else {
        // API mode
        final response = await _apiService.loginWithCredentials(
          registrationNumber: registrationNumber,
          password: password,
          role: role,
        );

        _user = User(
          uid: response['user']['uid'] ?? 'STU001',
          regId: response['user']['regId'] ?? registrationNumber,
          name: response['user']['name'] ?? 'Student',
          email: response['user']['email'] ??
              '$registrationNumber@college.edu',
          role: response['user']['role'] ?? role,
          department: response['user']['department'] ?? 'Unknown',
          semester: response['user']['semester'] ?? '1',
          profileImage: response['user']['profileImage'] ??
              'https://via.placeholder.com/100',
          bio: response['user']['bio'] ?? '',
          enrolledCourses:
              List<String>.from(response['user']['enrolledCourses'] ?? []),
          joinedCommunities:
              List<String>.from(response['user']['joinedCommunities'] ?? []),
          coursesCount: response['user']['coursesCount'] ?? 0,
          videosCount: response['user']['videosCount'] ?? 0,
          rating: (response['user']['rating'] ?? 0).toDouble(),
          createdAt: DateTime.parse(response['user']['createdAt'] ??
              DateTime.now().toIso8601String()),
          isVerified: response['user']['isVerified'] ?? false,
        );

        _token = response['token'];
      }

      // Save to local storage
      if (_user != null && _token != null) {
        await StorageService.saveUser(_user!);
        await StorageService.saveToken(_token!);
        await StorageService.setAuthenticated(true);
      }

      _isFirstTimeLogin = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Login with credentials error: $e');
      return false;
    }
  }

  /// Login using UID and Registration ID
  Future<bool> loginWithUID({
    required String uid,
    required String regId,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_useLocalStorage) {
        await Future.delayed(const Duration(seconds: 2));

        _user = User(
          uid: uid,
          regId: regId,
          name: 'User $uid',
          email: '$uid@college.edu',
          role: role,
          department: 'Computer Science',
          semester: '4',
          profileImage: 'https://via.placeholder.com/100',
          bio: 'Welcome to Classly!',
          enrolledCourses: const [],
          joinedCommunities: const [],
          coursesCount: 0,
          videosCount: 0,
          rating: 0.0,
          createdAt: DateTime.now(),
          isVerified: true,
        );
        _token = 'local_token_$uid';
      } else {
        final response = await _apiService.loginWithUID(
          uid: uid,
          regId: regId,
          role: role,
        );

        _user = User(
          uid: response['user']['uid'] ?? uid,
          regId: response['user']['regId'] ?? regId,
          name: response['user']['name'] ?? 'Student',
          email: response['user']['email'] ?? '$uid@college.edu',
          role: response['user']['role'] ?? role,
          department: response['user']['department'] ?? 'Unknown',
          semester: response['user']['semester'] ?? '1',
          profileImage: response['user']['profileImage'] ??
              'https://via.placeholder.com/100',
          bio: response['user']['bio'] ?? '',
          enrolledCourses:
              List<String>.from(response['user']['enrolledCourses'] ?? []),
          joinedCommunities:
              List<String>.from(response['user']['joinedCommunities'] ?? []),
          coursesCount: response['user']['coursesCount'] ?? 0,
          videosCount: response['user']['videosCount'] ?? 0,
          rating: (response['user']['rating'] ?? 0).toDouble(),
          createdAt: DateTime.parse(response['user']['createdAt'] ??
              DateTime.now().toIso8601String()),
          isVerified: response['user']['isVerified'] ?? false,
        );

        _token = response['token'];
      }

      // Save to local storage
      if (_user != null && _token != null) {
        await StorageService.saveUser(_user!);
        await StorageService.saveToken(_token!);
        await StorageService.setAuthenticated(true);
      }

      _isFirstTimeLogin = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('UID Login error: $e');
      return false;
    }
  }

  /// Signup with all required fields
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String uid = '',
    String regId = '',
    String department = 'Unknown',
    String semester = '1',
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final finalUid =
          uid.isEmpty ? 'STU${DateTime.now().millisecondsSinceEpoch}' : uid;
      final finalRegId =
          regId.isEmpty ? 'REG${DateTime.now().millisecondsSinceEpoch}' : regId;

      if (_useLocalStorage) {
        await Future.delayed(const Duration(seconds: 2));

        _user = User(
          uid: finalUid,
          regId: finalRegId,
          name: name,
          email: email,
          role: role,
          department: department,
          semester: semester,
          profileImage: 'https://via.placeholder.com/100',
          bio: '',
          enrolledCourses: const [],
          joinedCommunities: const [],
          coursesCount: 0,
          videosCount: 0,
          rating: 0.0,
          createdAt: DateTime.now(),
          isVerified: false,
        );
        _token = 'local_token_$finalUid';
      } else {
        final response = await _apiService.register(
          name: name,
          email: email,
          password: password,
          role: role,
          uid: finalUid,
          regId: finalRegId,
          department: department,
          semester: semester,
        );

        _user = User(
          uid: response['user']['uid'] ?? finalUid,
          regId: response['user']['regId'] ?? finalRegId,
          name: response['user']['name'] ?? name,
          email: response['user']['email'] ?? email,
          role: response['user']['role'] ?? role,
          department: response['user']['department'] ?? department,
          semester: response['user']['semester'] ?? semester,
          profileImage: response['user']['profileImage'] ??
              'https://via.placeholder.com/100',
          bio: response['user']['bio'] ?? '',
          coursesCount: response['user']['coursesCount'] ?? 0,
          videosCount: response['user']['videosCount'] ?? 0,
          rating: (response['user']['rating'] ?? 0).toDouble(),
          createdAt: DateTime.now(),
          isVerified: response['user']['isVerified'] ?? false,
        );

        _token = response['token'];
      }

      // Save to local storage
      if (_user != null && _token != null) {
        await StorageService.saveUser(_user!);
        await StorageService.saveToken(_token!);
        await StorageService.setAuthenticated(true);
      }

      _isFirstTimeLogin = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Signup error: $e');
      return false;
    }
  }

  /// Logout and clear user data
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear local storage
      await StorageService.clearAll();

      // Clear in-memory data
      _user = null;
      _token = null;
      _error = null;
      _isFirstTimeLogin = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to logout';
      debugPrint('Logout error: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Toggle between local storage and API mode
  void setUseLocalStorage(bool value) {
    _useLocalStorage = value;
    notifyListeners();
  }
}