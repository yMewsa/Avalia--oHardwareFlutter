import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> canUseBiometrics() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = await _localAuth.isDeviceSupported();
    return canAuthenticateWithBiometrics && canAuthenticate;
  }

  Future<bool> authenticateWithBiometrics() async {
    final bool supported = await canUseBiometrics();
    if (!supported) {
      return false;
    }

    try {
      return await _localAuth.authenticate(
        localizedReason: 'Use sua biometria para acessar o aplicativo.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on Exception {
      return false;
    }
  }
}
