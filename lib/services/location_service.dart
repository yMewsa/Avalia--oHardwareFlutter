import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double workplaceLatitude = -23.5489;
  static const double workplaceLongitude = -46.6388;
  static const double maxDistanceInMeters = 100;

  Future<Position> getCurrentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('O GPS está desligado. Ative a localização para continuar.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'A permissão de localização foi negada permanentemente. Ative em Ajustes.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      throw Exception('Não foi possível obter a localização atual.');
    }
  }

  double calculateDistanceInMeters(
    Position currentPosition,
    double targetLatitude,
    double targetLongitude,
  ) {
    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLatitude,
      targetLongitude,
    );
  }

  double calculateDistanceToWorkplace(Position position) {
    return calculateDistanceInMeters(
      position,
      workplaceLatitude,
      workplaceLongitude,
    );
  }

  bool isWithinWorkRadius(Position position) {
    final distance = calculateDistanceToWorkplace(position);
    return distance <= maxDistanceInMeters;
  }

  bool isInsideCompanyRadius(Position currentPosition) {
    return isWithinWorkRadius(currentPosition);
  }
}
