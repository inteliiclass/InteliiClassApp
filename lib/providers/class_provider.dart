import 'package:flutter/material.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassProvider extends ChangeNotifier {
  final List<ClassModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get classes by instructor ID
  List<ClassModel> getClassesByInstructorId(String instructorId) {
    return _classes.where((c) => c.instructorId == instructorId).toList();
  }

  // Fetch classes from Firestore
  Future<void> fetchClasses({String? instructorId, String? studentId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query query = FirebaseFirestore.instance.collection('classes');

      if (instructorId != null) {
        query = query.where('instructorId', isEqualTo: instructorId);
      }

      final snapshot = await query.get();
      _classes.clear();

      for (var doc in snapshot.docs) {
        final classModel = ClassModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );

        // If filtering by student, check if student is in the class
        if (studentId != null) {
          if (classModel.studentIds.contains(studentId)) {
            _classes.add(classModel);
          }
        } else {
          _classes.add(classModel);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a single class document by ID
  Future<ClassModel?> fetchClassById(String classId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('classes')
          .where('classId', isEqualTo: classId).get();

      if (query.docs.isEmpty) return null;

      return ClassModel.fromMap(query.docs.single.data());
    } catch (_) {
      return null;
    }
  }


}
