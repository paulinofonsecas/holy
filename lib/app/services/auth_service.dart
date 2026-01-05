import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle Firebase Authentication with persistent anonymous login
class AuthService {
  static const String _userIdKey = 'anonymous_user_id';
  static const String _displayNameKey = 'user_display_name';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  /// Get the current user ID (falls back to local ID if Firebase auth unavailable)
  String? getCurrentUserId() {
    final firebaseUid = _firebaseAuth.currentUser?.uid;
    if (firebaseUid != null) {
      return firebaseUid;
    }
    return _prefs.getString(_userIdKey);
  }

  /// Get the stored display name
  String? getDisplayName() {
    return _prefs.getString(_displayNameKey);
  }

  /// Initialize authentication (automatic anonymous login if not logged in)
  Future<void> initialize() async {
    try {
      if (_firebaseAuth.currentUser != null) {
        debugPrint('User already logged in: ${_firebaseAuth.currentUser?.uid}');
        return;
      }

      final savedUserId = _prefs.getString(_userIdKey);
      if (savedUserId != null) {
        debugPrint('Found saved user ID: $savedUserId');
        return;
      }

      await loginAnonymously();
    } catch (e) {
      debugPrint('Error during auth initialization: $e');
      _generateLocalUserId();
    }
  }

  /// Login anonymously and persist the user ID
  Future<UserCredential> loginAnonymously() async {
    try {
      debugPrint('Attempting anonymous login...');
      final userCredential = await _firebaseAuth.signInAnonymously();
      final userId = userCredential.user?.uid;

      if (userId != null) {
        await _prefs.setString(_userIdKey, userId);
        debugPrint('Anonymous login successful. User ID: $userId');
        return userCredential;
      }
      throw Exception('Failed to get user ID from anonymous login');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth error: ${e.code} - ${e.message}');
      _generateLocalUserId();
      rethrow;
    } catch (e) {
      debugPrint('Anonymous login failed: $e');
      _generateLocalUserId();
      rethrow;
    }
  }

  /// Generate a local user ID as fallback when Firebase auth fails
  void _generateLocalUserId() {
    final localUserId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    try {
      _prefs.setString(_userIdKey, localUserId);
      debugPrint('Generated local user ID: $localUserId');
    } catch (e) {
      debugPrint('Error saving local user ID: $e');
    }
  }

  /// Set display name for the anonymous user
  Future<void> setDisplayName(String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await _prefs.setString(_displayNameKey, displayName);
        debugPrint('Display name updated: $displayName');
      }
    } catch (e) {
      debugPrint('Error setting display name: $e');
      rethrow;
    }
  }

  /// Logout (clears persistent data)
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _prefs.remove(_userIdKey);
      await _prefs.remove(_displayNameKey);
      debugPrint('Logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Listen to authentication state changes
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}
