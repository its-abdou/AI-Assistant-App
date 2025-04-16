// lib/repositories/auth_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  // Sign up a new user
  Future<User> signup(String fullName, String email, String password) async {
    try {
      final data = {
        'fullName': fullName,
        'email': email,
        'password': password,
      };

      final response = await _apiService.post('auth/signup', data, requiresAuth: false);
      final user = User.fromJson(response);

      // Save token
      if (user.token != null) {
        await _apiService.saveToken(user.token!);
        await _saveUserToPrefs(user);
      }

      return user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Log in user
  Future<User> login(String email, String password) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await _apiService.post('auth/login', data, requiresAuth: false);
      final user = User.fromJson(response);

      // Save token
      if (user.token != null) {
        await _apiService.saveToken(user.token!);
        await _saveUserToPrefs(user);
      }

      return user;
    } catch (e) {
      throw Exception('Failed to log in: $e');
    }
  }

  // Get current user profile
  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get('users/profile');
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put('users/profile', profileData);
      final updatedUser = User.fromJson(response['updatedUser']);
      await _saveUserToPrefs(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Log out user
  Future<void> logout() async {
    await _apiService.deleteToken();

    // Clear user from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _apiService.hasToken();
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();

    // Save user data without the token (token is stored in secure storage)
    final userData = user.toJson();
    userData.remove('token'); // Remove token from the data to store

    await prefs.setString('user', jsonEncode(userData));
  }

  // Get user data from SharedPreferences
  Future<User?> getUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final userData = jsonDecode(userString);
      return User.fromJson(userData);
    }

    return null;
  }
}