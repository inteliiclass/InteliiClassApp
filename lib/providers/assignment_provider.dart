import 'package:flutter/material.dart';
import 'package:inteliiclass/models/assignment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentProvider extends ChangeNotifier {
  final List<AssignmentModel> _assignments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AssignmentModel> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get assignments for a specific class
  List<AssignmentModel> getAssignmentsByClassId(String classId) {
    return _assignments.where((a) => a.classId == classId).toList();
  }

  // Fetch assignments from Firestore
  Future<void> fetchAssignments({String? classId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query query = FirebaseFirestore.instance.collection('assignments');
      
      if (classId != null) {
        query = query.where('classId', isEqualTo: classId);
      }

      final snapshot = await query.get();
      _assignments.clear();
      
      for (var doc in snapshot.docs) {
        _assignments.add(
          AssignmentModel.fromMap(doc.data() as Map<String, dynamic>),
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

  // Add a new assignment
  Future<void> addAssignment(AssignmentModel assignment) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignment.assignmentId)
          .set(assignment.toMap());

      _assignments.add(assignment);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update an assignment
  Future<void> updateAssignment(AssignmentModel assignment) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignment.assignmentId)
          .update(assignment.toMap());

      final index = _assignments.indexWhere(
        (a) => a.assignmentId == assignment.assignmentId,
      );
      
      if (index != -1) {
        _assignments[index] = assignment;
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

  // Delete an assignment
  Future<void> deleteAssignment(String assignmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignmentId)
          .delete();

      _assignments.removeWhere((a) => a.assignmentId == assignmentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get a single assignment by ID
  AssignmentModel? getAssignmentById(String assignmentId) {
    try {
      return _assignments.firstWhere((a) => a.assignmentId == assignmentId);
    } catch (e) {
      return null;
    }
  }

  // Clear all assignments
  void clearAssignments() {
    _assignments.clear();
    notifyListeners();
  }
}
