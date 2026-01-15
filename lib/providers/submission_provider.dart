import 'package:flutter/material.dart';
import 'package:inteliiclass/models/submission_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionProvider extends ChangeNotifier {
  final List<SubmissionModel> _submissions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SubmissionModel> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get submissions for a specific assignment
  List<SubmissionModel> getSubmissionsByAssignmentId(String assignmentId) {
    return _submissions.where((s) => s.assignmentId == assignmentId).toList();
  }

  // Get submissions by a specific student
  List<SubmissionModel> getSubmissionsByStudentId(String studentId) {
    return _submissions.where((s) => s.studentId == studentId).toList();
  }

  // Get graded submissions
  List<SubmissionModel> getGradedSubmissions() {
    return _submissions.where((s) => s.obtainedMarks != null).toList();
  }

  // Get ungraded submissions
  List<SubmissionModel> getUngradedSubmissions() {
    return _submissions.where((s) => s.obtainedMarks == null).toList();
  }

  // Fetch submissions from Firestore
  Future<void> fetchSubmissions({String? assignmentId, String? studentId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query query = FirebaseFirestore.instance.collection('submissions');
      
      if (assignmentId != null) {
        query = query.where('assignmentId', isEqualTo: assignmentId);
      } else if (studentId != null) {
        query = query.where('studentId', isEqualTo: studentId);
      }

      final snapshot = await query.get();
      _submissions.clear();
      
      for (var doc in snapshot.docs) {
        _submissions.add(
          SubmissionModel.fromMap(doc.data() as Map<String, dynamic>),
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

  // Submit assignment
  Future<void> submitAssignment(SubmissionModel submission) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(submission.submissionId)
          .set(submission.toMap());

      _submissions.add(submission);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update submission (for re-submission or grading)
  Future<void> updateSubmission(SubmissionModel submission) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(submission.submissionId)
          .update(submission.toMap());

      final index = _submissions.indexWhere(
        (s) => s.submissionId == submission.submissionId,
      );
      
      if (index != -1) {
        _submissions[index] = submission;
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

  // Grade submission
  Future<void> gradeSubmission(
    String submissionId,
    double obtainedMarks,
    String? feedback,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(submissionId)
          .update({
        'obtainedMarks': obtainedMarks,
        'feedback': feedback,
        'gradedAt': DateTime.now(),
      });

      final index = _submissions.indexWhere(
        (s) => s.submissionId == submissionId,
      );
      
      if (index != -1) {
        final updatedSubmission = SubmissionModel(
          submissionId: _submissions[index].submissionId,
          assignmentId: _submissions[index].assignmentId,
          classId: _submissions[index].classId,
          studentId: _submissions[index].studentId,
          studentName: _submissions[index].studentName,
          submissionText: _submissions[index].submissionText,
          submissionFileUrl: _submissions[index].submissionFileUrl,
          submittedAt: _submissions[index].submittedAt,
          isLate: _submissions[index].isLate,
          obtainedMarks: obtainedMarks,
          feedback: feedback,
          gradedAt: DateTime.now(),
        );
        _submissions[index] = updatedSubmission;
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

  // Delete submission
  Future<void> deleteSubmission(String submissionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(submissionId)
          .delete();

      _submissions.removeWhere((s) => s.submissionId == submissionId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get submission by student for a specific assignment
  SubmissionModel? getStudentSubmission(String assignmentId, String studentId) {
    try {
      return _submissions.firstWhere(
        (s) => s.assignmentId == assignmentId && s.studentId == studentId,
      );
    } catch (e) {
      return null;
    }
  }

  // Clear all submissions
  void clearSubmissions() {
    _submissions.clear();
    notifyListeners();
  }
}
