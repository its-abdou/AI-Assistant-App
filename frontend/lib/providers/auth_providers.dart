// lib/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/api_service.dart';

// Environment configuration - replace with your backend URL
final apiUrlProvider = Provider((ref) => 'http://192.168.26.94:3000/api/v1');

// API Service provider
final apiServiceProvider = Provider((ref) {
  final apiUrl = ref.watch(apiUrlProvider);
  return ApiService(baseUrl: apiUrl);
});

// Auth Repository provider
final authRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthRepository(apiService);
});

// Authentication state notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Check if token exists
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        // Get user from shared preferences first for quick loading
        User? cachedUser = await _authRepository.getUserFromPrefs();

        if (cachedUser != null) {
          state = AsyncValue.data(cachedUser);
        }

        // Then try to get fresh data from API
        try {
          final user = await _authRepository.getUserProfile();
          state = AsyncValue.data(user);
        } catch (e) {
          // If API call fails but we have cached user, keep using that
          if (cachedUser == null) {
            state = AsyncValue.error(e, StackTrace.current);
          }
        }
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signup(String fullName, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signup(fullName, email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final updatedUser = await _authRepository.updateProfile(profileData);
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      // Keep old state on error
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshUserProfile() async {
    if (state.value != null) {
      try {
        final user = await _authRepository.getUserProfile();
        state = AsyncValue.data(user);
      } catch (e) {
        // Keep old state on error
      }
    }
  }
}

// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

// Loading state convenience provider
final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AsyncLoading;
});
