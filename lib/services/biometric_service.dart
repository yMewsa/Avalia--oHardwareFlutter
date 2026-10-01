import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isSupported;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      throw Exception('Biometria indisponível ou não habilitada no dispositivo.');
    }

    try {
      return await _localAuth.authenticate(
        localizedReason: 'Use sua biometria para acessar o app de ponto.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      throw Exception('Não foi possível autenticar com biometria.');
    } catch (_) {
      throw Exception('Erro inesperado na autenticação biométrica.');
    }
  }
}
