class AttendanceModel {
  final String attendanceId;
  final String classId;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String status;
  final String? remarks;
  final DateTime recordedAt;

  AttendanceModel({
    required this.attendanceId,
    required this.classId,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.status,
    this.remarks,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'classId': classId,
      'studentId': studentId,
      'studentName': studentName,
      'date': date,
      'status': status,
      'remarks': remarks,
      'recordedAt': recordedAt,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      attendanceId: map['attendanceId'] ?? '',
      classId: map['classId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      date: map['date']?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'absent',
      remarks: map['remarks'],
      recordedAt: map['recordedAt']?.toDate() ?? DateTime.now(),
    );
  }
}