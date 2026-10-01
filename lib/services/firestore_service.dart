import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/attendance_record.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAttendance(AttendanceRecord record) async {
    await _firestore
        .collection(AppConstants.attendanceCollection)
        .add(record.toMap());
  }

  Stream<List<AttendanceRecord>> getAttendanceHistory(String userId) {
    return _firestore
        .collection(AppConstants.attendanceCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('checkedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AttendanceRecord.fromMap(doc.id, doc.data());
          }).toList();
        });
  }
}
