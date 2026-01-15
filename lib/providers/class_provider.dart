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

  // Get classes by student ID
  List<ClassModel> getClassesByStudentId(String studentId) {
    return _classes.where((c) => c.studentIds.contains(studentId)).toList();
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

  // Add a new class
  Future<void> addClass(ClassModel classModel) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classModel.classId)
          .set(classModel.toMap());

      _classes.add(classModel);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update a class
  Future<void> updateClass(ClassModel classModel) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classModel.classId)
          .update(classModel.toMap());

      final index = _classes.indexWhere((c) => c.classId == classModel.classId);

      if (index != -1) {
        _classes[index] = classModel;
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

  // Delete a class
  Future<void> deleteClass(String classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .delete();

      _classes.removeWhere((c) => c.classId == classId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add student to class
  Future<void> addStudentToClass(String classId, String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .update({
            'studentIds': FieldValue.arrayUnion([studentId]),
          });

      final index = _classes.indexWhere((c) => c.classId == classId);
      if (index != -1) {
        final updatedClass = ClassModel(
          classId: _classes[index].classId,
          className: _classes[index].className,
          description: _classes[index].description,
          instructorId: _classes[index].instructorId,
          instructorName: _classes[index].instructorName,
          studentIds: [..._classes[index].studentIds, studentId],
          subject: _classes[index].subject,
          classCode: _classes[index].classCode,
          createdAt: _classes[index].createdAt,
          updatedAt: DateTime.now(),
        );
        _classes[index] = updatedClass;
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

  // Get a single class by ID
  ClassModel? getClassById(String classId) {
    try {
      return _classes.firstWhere((c) => c.classId == classId);
    } catch (e) {
      return null;
    }
  }

  // Fetch a single class document by ID from Firestore and cache it
  Future<ClassModel?> fetchClassById(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to get by document id first (some codebases store classId as doc id)
      final docRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(classId);
      final doc = await docRef.get();
      if (doc.exists) {
        final classModel = ClassModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );

        final index = _classes.indexWhere(
          (c) => c.classId == classModel.classId,
        );
        if (index != -1) {
          _classes[index] = classModel;
        } else {
          _classes.add(classModel);
        }

        _isLoading = false;
        notifyListeners();
        return classModel;
      }

      // Fallback: query by the 'classId' field inside the document
      final q = await FirebaseFirestore.instance
          .collection('classes')
          .where('classId', isEqualTo: classId)
          .limit(1)
          .get();

      if (q.docs.isNotEmpty) {
        final classModel = ClassModel.fromMap(
          q.docs.first.data() as Map<String, dynamic>,
        );
        final index = _classes.indexWhere(
          (c) => c.classId == classModel.classId,
        );
        if (index != -1) {
          _classes[index] = classModel;
        } else {
          _classes.add(classModel);
        }

        _isLoading = false;
        notifyListeners();
        return classModel;
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Clear all classes
  void clearClasses() {
    _classes.clear();
    notifyListeners();
  }

  // Increment an assignments counter field on the class document (if present)
  Future<void> incrementAssignmentsCount(String classId, int delta) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .update({'assignments': FieldValue.increment(delta)});

      // Optionally refresh cached class
      final index = _classes.indexWhere((c) => c.classId == classId);
      if (index != -1) {
        final refreshed = await fetchClassById(classId);
        if (refreshed != null) _classes[index] = refreshed;
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
}
