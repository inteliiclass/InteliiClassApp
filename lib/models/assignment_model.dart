class AssignmentModel {
  final String assignmentId;
  final String classId;
  final String title;
  final String description;
  final String instructorId;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? totalMarks;
  final String? attachmentUrl;

  AssignmentModel({
    required this.assignmentId,
    required this.classId,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.totalMarks,
    this.attachmentUrl,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'classId': classId,
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'totalMarks': totalMarks,
      'attachmentUrl': attachmentUrl,
    };
  }

  // Create from Firestore document
  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      assignmentId: map['assignmentId'] ?? '',
      classId: map['classId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructorId: map['instructorId'] ?? '',
      dueDate: map['dueDate']?.toDate() ?? DateTime.now(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      totalMarks: map['totalMarks']?.toDouble(),
      attachmentUrl: map['attachmentUrl'],
    );
  }
}
