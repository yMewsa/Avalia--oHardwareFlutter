import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/attendance_record.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

class AttendanceController extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isRegistering = false;
  double _currentDistance = 0;
  String? _statusMessage;
  String? _errorMessage;

  bool get isRegistering => _isRegistering;
  double get currentDistance => _currentDistance;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;

  Future<void> updateCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      _currentDistance = _locationService.calculateDistanceInMeters(
        position,
        AppConstants.companyLatitude,
        AppConstants.companyLongitude,
      );

      _statusMessage = _currentDistance <= AppConstants.permittedRadiusInMeters
          ? 'Você está dentro do raio permitido.'
          : 'Você está fora do raio permitido.';
      _errorMessage = null;
    } catch (error) {
      _statusMessage = 'Não foi possível obter a localização.';
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<void> registerAttendance({required String userId}) async {
    _isRegistering = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      final distance = _locationService.calculateDistanceInMeters(
        position,
        AppConstants.companyLatitude,
        AppConstants.companyLongitude,
      );

      if (distance > AppConstants.permittedRadiusInMeters) {
        _statusMessage = 'Registro bloqueado: fora do raio permitido.';
        _errorMessage = 'Você precisa estar até 100 metros da empresa.';
        notifyListeners();
        return;
      }

      final record = AttendanceRecord(
        id: '',
        userId: userId,
        checkedAt: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        status: 'Dentro',
      );

      await _firestoreService.saveAttendance(record);
      _statusMessage = 'Ponto registrado com sucesso.';
      _currentDistance = distance;
    } catch (error) {
      _statusMessage = 'Erro ao registrar ponto.';
      _errorMessage = error.toString();
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  Stream<List<AttendanceRecord>> getHistory(String userId) {
    return _firestoreService.getAttendanceHistory(userId);
  }
}
