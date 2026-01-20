import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:inteliiclass/providers/attendance_provider.dart';
import 'package:provider/provider.dart';
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
  int _absenceCount = 0;
  late UserProvider userProvider;
  late AttendanceProvider attendanceProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ClassModel) {
        setState(() {
          _classModel = args;
        });
        await _fetchAbsences();
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _fetchAbsences() async {
    if (_classModel == null) return;

    final currentUserId = userProvider.currentUser?.uid ??
        FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return;

    // Fetch attendance records for this student in this class
    await attendanceProvider.fetchAttendance(
      classId: _classModel!.classId,
    );

    // Count absences for the current student
    final studentAttendances = attendanceProvider.attendances
        .where((a) => a.studentId == currentUserId && a.classId == _classModel!.classId)
        .toList();

    final absences = studentAttendances
        .where((a) => a.status == 'absent')
        .length;

    if (mounted) {
      setState(() {
        _absenceCount = absences;
      });
    }
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
                              _classModel!.subject,
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
                    _classModel!.description,
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}