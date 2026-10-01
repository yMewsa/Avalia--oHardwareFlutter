import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String userId;
  final DateTime checkedAt;
  final double latitude;
  final double longitude;
  final String status;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.checkedAt,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecord(
      id: id,
      userId: map['userId'] ?? '',
      checkedAt: (map['checkedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Indefinido',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'checkedAt': checkedAt,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
  }
}
