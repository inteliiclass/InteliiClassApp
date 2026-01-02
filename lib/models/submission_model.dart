class SubmissionModel {
  final String submissionId;
  final String assignmentId;
  final String classId;
  final String studentId;
  final String studentName;
  final String? submissionText;
  final String? submissionFileUrl;
  final DateTime submittedAt;
  final bool isLate;
  final double? obtainedMarks;
  final String? feedback;
  final DateTime? gradedAt;

  SubmissionModel({
    required this.submissionId,
    required this.assignmentId,
    required this.classId,
    required this.studentId,
    required this.studentName,
    this.submissionText,
    this.submissionFileUrl,
    required this.submittedAt,
    this.isLate = false,
    this.obtainedMarks,
    this.feedback,
    this.gradedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'submissionId': submissionId,
      'assignmentId': assignmentId,
      'classId': classId,
      'studentId': studentId,
      'studentName': studentName,
      'submissionText': submissionText,
      'submissionFileUrl': submissionFileUrl,
      'submittedAt': submittedAt,
      'isLate': isLate,
      'obtainedMarks': obtainedMarks,
      'feedback': feedback,
      'gradedAt': gradedAt,
    };
  }

  // Create from Firestore document
  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      submissionId: map['submissionId'] ?? '',
      assignmentId: map['assignmentId'] ?? '',
      classId: map['classId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      submissionText: map['submissionText'],
      submissionFileUrl: map['submissionFileUrl'],
      submittedAt: map['submittedAt']?.toDate() ?? DateTime.now(),
      isLate: map['isLate'] ?? false,
      obtainedMarks: map['obtainedMarks']?.toDouble(),
      feedback: map['feedback'],
      gradedAt: map['gradedAt']?.toDate(),
    );
  }
}
