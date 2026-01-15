import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:inteliiclass/models/assignment_model.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/providers/assignment_provider.dart';
import 'package:inteliiclass/providers/attendance_provider.dart';
import 'package:inteliiclass/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentClassDetails extends StatefulWidget {
  const StudentClassDetails({super.key});

  @override
  State<StudentClassDetails> createState() => _StudentClassDetailsState();
}

class _StudentClassDetailsState extends State<StudentClassDetails> {
  ClassModel? _classModel;
  bool _isLoading = true;
  List<AssignmentModel> _assignments = [];
  int _absenceCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final assignmentProvider = Provider.of<AssignmentProvider>(
      context,
      listen: false,
    );

    final args = ModalRoute.of(context)?.settings.arguments;
    String? classId;
    if (args is ClassModel) {
      _classModel = args;
      classId = _classModel!.classId;
    } else if (args is String) {
      classId = args;
    }

    if (_classModel == null && classId != null) {
      await classProvider.fetchClassById(classId);
      _classModel = classProvider.getClassById(classId);
    }

    if (_classModel != null) {
      await assignmentProvider.fetchAssignments(classId: _classModel!.classId);
      _assignments = assignmentProvider.getAssignmentsByClassId(
        _classModel!.classId,
      );
      // Fetch attendance and compute absences for current student
      try {
        final attendanceProvider = Provider.of<AttendanceProvider>(
          context,
          listen: false,
        );
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        await attendanceProvider.fetchAttendance(classId: _classModel!.classId);

        final studentId =
            userProvider.currentUser?.uid ??
            FirebaseAuth.instance.currentUser?.uid;
        if (studentId != null) {
          final classAttendances = attendanceProvider.getAttendanceByClassId(
            _classModel!.classId,
          );
          _absenceCount = classAttendances
              .where(
                (a) =>
                    a.studentId == studentId &&
                    a.status.toLowerCase() == 'absent',
              )
              .length;
        }
      } catch (_) {}
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildAssignmentTile(AssignmentModel a) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.assignment, color: Colors.amber),
        title: Text(
          a.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Due: ${a.dueDate.toLocal().toString().split(' ')[0]}',
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/submitassignment',
              arguments: a.assignmentId,
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.blue),
          ),
          child: Text(
            'Submit',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 48, 85),
        title: Text(
          _classModel?.className ?? 'Class',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_classModel == null)
          ? Center(
              child: Text(
                'Class not found',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 2, 20, 34),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.book,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _classModel!.className,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _classModel!.classCode ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Dr. ${_classModel!.instructorName}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _classModel!.subject ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Absences: $_absenceCount',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _classModel!.description ?? '',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Assignments (${_assignments.length})',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ..._assignments.map(_buildAssignmentTile).toList(),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
