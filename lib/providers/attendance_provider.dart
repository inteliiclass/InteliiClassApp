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

  // Get attendance records for a specific student
  List<AttendanceModel> getAttendanceByStudentId(String studentId) {
    return _attendances.where((a) => a.studentId == studentId).toList();
  }

  // Get attendance for a specific date
  List<AttendanceModel> getAttendanceByDate(DateTime date) {
    return _attendances.where((a) {
      return a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day;
    }).toList();
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

  // Update attendance
  Future<void> updateAttendance(AttendanceModel attendance) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(attendance.attendanceId)
          .update(attendance.toMap());

      final index = _attendances.indexWhere(
        (a) => a.attendanceId == attendance.attendanceId,
      );
      
      if (index != -1) {
        _attendances[index] = attendance;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete attendance record
  Future<void> deleteAttendance(String attendanceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(attendanceId)
          .delete();

      _attendances.removeWhere((a) => a.attendanceId == attendanceId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Calculate attendance percentage for a student in a class
  double getAttendancePercentage(String studentId, String classId) {
    final classAttendances = _attendances.where(
      (a) => a.studentId == studentId && a.classId == classId,
    ).toList();

    if (classAttendances.isEmpty) return 0.0;

    final presentCount = classAttendances
        .where((a) => a.status.toLowerCase() == 'present')
        .length;

    return (presentCount / classAttendances.length) * 100;
  }

  // Clear all attendance records
  void clearAttendance() {
    _attendances.clear();
    notifyListeners();
  }
}
