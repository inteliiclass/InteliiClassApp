class ClassModel {
  final String classId;
  final String className;
  final String description;
  final String instructorId;
  final String instructorName;
  final List<String> studentIds;
  final String subject;
  final String? classCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassModel({
    required this.classId,
    required this.className,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    this.studentIds = const [],
    required this.subject,
    this.classCode,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'className': className,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'studentIds': studentIds,
      'subject': subject,
      'classCode': classCode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Firestore document
  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      description: map['description'] ?? '',
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
      subject: map['subject'] ?? '',
      classCode: map['classCode'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }
}
