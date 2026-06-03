import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _firebase.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    _user = await _firebase.getUser(userId);
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await _firebase.signUp(email, password);
      
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        username: username,
        createdAt: DateTime.now(),
      );
      
      await _firebase.createUser(user);
      _user = user;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await _firebase.signIn(email, password);
      await _loadUserData(credential.user!.uid);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _firebase.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_user == null) return false;

    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

      await _firebase.updateUser(_user!.id, data);
      
      _user = _user!.copyWith(
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _firebase.resetPassword(email);
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.contains('user-not-found')) {
      return '用户不存在';
    } else if (message.contains('wrong-password')) {
      return '密码错误';
    } else if (message.contains('email-already-in-use')) {
      return '邮箱已被注册';
    } else if (message.contains('invalid-email')) {
      return '邮箱格式不正确';
    } else if (message.contains('weak-password')) {
      return '密码强度不够';
    }
    return '操作失败，请重试';
  }
}
