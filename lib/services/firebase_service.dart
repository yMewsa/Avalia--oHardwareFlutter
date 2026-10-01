import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../models/punch_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapAuthError(error.code));
    } catch (_) {
      throw Exception('Não foi possível autenticar. Tente novamente.');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      throw Exception('Não foi possível encerrar a sessão.');
    }
  }

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

  Future<bool> authenticateWithBiometrics() async {
    final available = await isBiometricAvailable();
    if (!available) {
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

  Future<void> saveAttendance({
    required String userId,
    required double latitude,
    required double longitude,
    required String status,
  }) async {
    try {
      await _firestore.collection('attendance_registry').add({
        'userId': userId,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'checkedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw Exception(
        error.message ?? 'Erro ao salvar o registro de ponto no Firestore.',
      );
    } catch (_) {
      throw Exception('Erro ao registrar ponto. Tente novamente mais tarde.');
    }
  }

  Future<void> savePunchRecord(PunchRecord record) async {
    try {
      await _firestore.collection('attendance_registry').doc(record.id).set(
        record.toMap(),
        SetOptions(merge: true),
      );
    } on FirebaseException catch (error) {
      throw Exception(
        error.message ?? 'Erro ao salvar o registro de ponto no Firestore.',
      );
    } catch (_) {
      throw Exception('Erro ao registrar ponto. Tente novamente mais tarde.');
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Usuário bloqueado.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro na autenticação com Firebase.';
    }
  }
}
