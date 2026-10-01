import 'package:flutter/foundation.dart';

import '../models/punch_model.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';

class PunchController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final LocationService _locationService = LocationService();

  bool _isRegistering = false;
  double _distanceToWork = 0.0;
  String? _statusMessage;
  String? _errorMessage;

  bool get isRegistering => _isRegistering;
  double get distanceToWork => _distanceToWork;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;

  Future<void> registerPunch({required String userId}) async {
    _isRegistering = true;
    _statusMessage = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      final distance = _locationService.calculateDistanceInMeters(
        position,
        LocationService.workplaceLatitude,
        LocationService.workplaceLongitude,
      );

      _distanceToWork = distance;

      final isWithinRadius = distance <= LocationService.maxDistanceInMeters;

      if (!isWithinRadius) {
        _statusMessage = 'Registro bloqueado: fora do raio permitido.';
        _errorMessage = 'Você precisa estar a até 100 metros da empresa.';
        _isRegistering = false;
        notifyListeners();
        return;
      }

      final record = PunchRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        timestamp: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        isWithinRadius: true,
      );

      await _firebaseService.savePunchRecord(record);

      _statusMessage = 'Ponto registrado com sucesso.';
      _errorMessage = null;
    } on Exception catch (error) {
      _statusMessage = 'Erro ao registrar ponto.';
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }
}
