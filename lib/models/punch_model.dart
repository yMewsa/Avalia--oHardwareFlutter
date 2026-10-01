import 'package:cloud_firestore/cloud_firestore.dart';

class PunchRecord {
  final String id;
  final String userId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool isWithinRadius;

  PunchRecord({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isWithinRadius,
  });

  factory PunchRecord.fromMap(String id, Map<String, dynamic> map) {
    return PunchRecord(
      id: id,
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      isWithinRadius: map['isWithinRadius'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'isWithinRadius': isWithinRadius,
    };
  }
}
