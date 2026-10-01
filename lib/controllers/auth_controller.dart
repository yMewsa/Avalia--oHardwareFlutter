import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/firebase_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get biometricAvailable => _isBiometricAvailable;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser ?? _firebaseService.currentUser;

  Future<void> login(String email, String password) async {
    await loginWithEmailAndPassword(email: email, password: password);
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
    } on Exception catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkBiometricSupport() async {
    try {
      _isBiometricAvailable = await _firebaseService.isBiometricAvailable();
    } catch (_) {
      _isBiometricAvailable = false;
    }

    notifyListeners();
  }

  Future<void> loginWithBiometrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authenticated = await _firebaseService.authenticateWithBiometrics();
      if (!authenticated) {
        _errorMessage = 'Biometria não autorizada.';
      }
    } on Exception catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.signOut();
      _currentUser = null;
    } on Exception catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
