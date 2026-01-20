import 'package:flutter/material.dart';
import 'package:inteliiclass/models/attendence_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceProvider extends ChangeNotifier {
  final List<AttendanceModel> _attendances = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceModel> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get attendance records for a specific class
  List<AttendanceModel> getAttendanceByClassId(String classId) {
    return _attendances.where((a) => a.classId == classId).toList();
  }

  // Fetch attendance records from Firestore
  Future<void> fetchAttendance({String? classId, String? studentId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query query = FirebaseFirestore.instance.collection('attendance');
      
      if (classId != null) {
        query = query.where('classId', isEqualTo: classId);
      } else if (studentId != null) {
        query = query.where('studentId', isEqualTo: studentId);
      }

      final snapshot = await query.get();
      _attendances.clear();
      
      for (var doc in snapshot.docs) {
        _attendances.add(
          AttendanceModel.fromMap(doc.data() as Map<String, dynamic>),
        );
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add/Mark attendance
  Future<void> markAttendance(AttendanceModel attendance) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(attendance.attendanceId)
          .set(attendance.toMap());

      _attendances.add(attendance);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
