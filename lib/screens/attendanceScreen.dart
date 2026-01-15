import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/providers/attendance_provider.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inteliiclass/providers/user_provider.dart';
import 'package:inteliiclass/models/attendence_model.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:inteliiclass/models/user_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  ClassModel? _classModel;
  bool _isLoading = true;
  Map<String, String> _statuses = {}; // studentId -> status
  Map<String, UserModel> _students = {}; // studentId -> UserModel
  List<ClassModel> _availableClasses = [];
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final args = ModalRoute.of(context)?.settings.arguments;
      String? classId;
      if (args is ClassModel) {
        _classModel = args;
        classId = _classModel!.classId;
      } else if (args is String) {
        classId = args;
      }

      // Load instructor classes (if any)
      String? instructorId =
          userProvider.currentUser?.uid ??
          FirebaseAuth.instance.currentUser?.uid;
      if (instructorId != null) {
        await classProvider.fetchClasses(instructorId: instructorId);
        _availableClasses = classProvider.getClassesByInstructorId(
          instructorId,
        );
      }

      // If a classId was passed via args, load that class; otherwise, if instructor has classes, pick first
      if (_classModel == null && classId != null) {
        await _loadClassData(
          classId,
          classProvider,
          attendanceProvider,
          userProvider,
        );
        _selectedClassId = classId;
      } else if (_classModel == null && _availableClasses.isNotEmpty) {
        _selectedClassId = _availableClasses.first.classId;
        await _loadClassData(
          _selectedClassId!,
          classProvider,
          attendanceProvider,
          userProvider,
        );
      } else if (_classModel != null) {
        // class was provided via args
        _selectedClassId = _classModel!.classId;
        await _loadClassData(
          _classModel!.classId,
          classProvider,
          attendanceProvider,
          userProvider,
        );
      }

      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _setStatus(String studentId, String status) {
    setState(() {
      _statuses[studentId] = status;
    });
  }

  int _countStatus(String status) {
    return _statuses.values.where((s) => s == status).length;
  }

  Future<void> _loadClassData(
    String classId,
    ClassProvider classProvider,
    AttendanceProvider attendanceProvider,
    UserProvider userProvider,
  ) async {
    setState(() {
      _isLoading = true;
      _students = {};
      _statuses = {};
    });

    // Fetch class document
    final cls = await classProvider.fetchClassById(classId);
    if (cls == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    _classModel = cls;

    // Load today's attendance for the class
    await attendanceProvider.fetchAttendance(classId: _classModel!.classId);

    // Load student profiles
    final students = await userProvider.fetchUsersByIds(
      _classModel!.studentIds,
    );
    _students = {for (var s in students) s.uid: s};

    // Initialize statuses for each student based on today's attendance if available
    final today = DateTime.now();
    final classAttendances = attendanceProvider
        .getAttendanceByClassId(_classModel!.classId)
        .where(
          (a) =>
              a.date.year == today.year &&
              a.date.month == today.month &&
              a.date.day == today.day,
        )
        .toList();

    for (final sid in _classModel!.studentIds) {
      final record = classAttendances.firstWhere(
        (a) => a.studentId == sid,
        orElse: () => AttendanceModel(
          attendanceId: '',
          classId: _classModel!.classId,
          studentId: sid,
          studentName: _students[sid]?.name ?? sid,
          date: today,
          status: 'present',
          recordedAt: DateTime.now(),
        ),
      );
      _statuses[sid] = record.status;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveAttendance() async {
    if (_classModel == null) return;
    setState(() => _isLoading = true);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    try {
      for (final entry in _statuses.entries) {
        final attendance = AttendanceModel(
          attendanceId: '${entry.key}_${DateTime.now().millisecondsSinceEpoch}',
          classId: _classModel!.classId,
          studentId: entry.key,
          studentName: entry.key,
          date: DateTime.now(),
          status: entry.value,
          recordedAt: DateTime.now(),
        );
        await attendanceProvider.markAttendance(attendance);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance saved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildStudentCard(String studentId) {
    final status = _statuses[studentId] ?? 'present';
    final displayName = _students[studentId]?.name ?? studentId;
    final email = _students[studentId]?.email ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0] : 'S',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _setStatus(studentId, 'present'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: status == 'present'
                            ? Colors.green
                            : const Color.fromARGB(255, 2, 20, 34),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: 'present',
                            groupValue: status,
                            onChanged: (v) =>
                                _setStatus(studentId, v ?? 'present'),
                            activeColor: Colors.white,
                          ),
                          Text(
                            'Present',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _setStatus(studentId, 'absent'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: status == 'absent'
                            ? Colors.red
                            : const Color.fromARGB(255, 2, 20, 34),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: 'absent',
                            groupValue: status,
                            onChanged: (v) =>
                                _setStatus(studentId, v ?? 'absent'),
                            activeColor: Colors.white,
                          ),
                          Text(
                            'Absent',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _setStatus(studentId, 'late'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: status == 'late'
                            ? Colors.orange
                            : const Color.fromARGB(255, 2, 20, 34),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: 'late',
                            groupValue: status,
                            onChanged: (v) =>
                                _setStatus(studentId, v ?? 'late'),
                            activeColor: Colors.white,
                          ),
                          Text(
                            'Late',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
          'Attendance',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _isLoading
                ? SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : (_availableClasses.isEmpty
                      ? SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'No classes available',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() => _isLoading = true);
                                  final userProvider =
                                      Provider.of<UserProvider>(
                                        context,
                                        listen: false,
                                      );
                                  final classProvider =
                                      Provider.of<ClassProvider>(
                                        context,
                                        listen: false,
                                      );
                                  final instructorId =
                                      userProvider.currentUser?.uid ??
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (instructorId != null) {
                                    await classProvider.fetchClasses(
                                      instructorId: instructorId,
                                    );
                                    _availableClasses = classProvider
                                        .getClassesByInstructorId(instructorId);
                                    if (_availableClasses.isNotEmpty) {
                                      _selectedClassId =
                                          _availableClasses.first.classId;
                                      final attendanceProvider =
                                          Provider.of<AttendanceProvider>(
                                            context,
                                            listen: false,
                                          );
                                      final userProv =
                                          Provider.of<UserProvider>(
                                            context,
                                            listen: false,
                                          );
                                      await _loadClassData(
                                        _selectedClassId!,
                                        classProvider,
                                        attendanceProvider,
                                        userProv,
                                      );
                                    }
                                  }
                                  if (mounted)
                                    setState(() => _isLoading = false);
                                },
                                child: Text(
                                  'Reload',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedClassId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 2, 20, 34),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          dropdownColor: const Color.fromARGB(255, 2, 20, 34),
                          style: GoogleFonts.poppins(color: Colors.white),
                          hint: Text(
                            'Select class',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          items: _availableClasses
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.classId,
                                  child: Text(c.className),
                                ),
                              )
                              .toList(),
                          onChanged: (val) async {
                            if (val == null) return;
                            setState(() => _selectedClassId = val);
                            final classProvider = Provider.of<ClassProvider>(
                              context,
                              listen: false,
                            );
                            final attendanceProvider =
                                Provider.of<AttendanceProvider>(
                                  context,
                                  listen: false,
                                );
                            final userProvider = Provider.of<UserProvider>(
                              context,
                              listen: false,
                            );
                            await _loadClassData(
                              val,
                              classProvider,
                              attendanceProvider,
                              userProvider,
                            );
                          },
                        )),
          ),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 2, 20, 34),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.school, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _classModel?.className ?? 'Class',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _classModel?.subject ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${DateTime.now().toString().split(' ')[0]}',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_countStatus('present')}',
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'Present',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_countStatus('absent')}',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'Absent',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_countStatus('late')}',
                        style: GoogleFonts.poppins(
                          color: Colors.orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'Late',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _classModel == null
                ? Center(
                    child: Text(
                      'No class selected',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.fromLTRB(0, 17, 0, 0),
                    child: ListView.builder(
                      itemCount: _classModel!.studentIds.length,
                      itemBuilder: (context, index) {
                        final sid = _classModel!.studentIds[index];
                        return _buildStudentCard(sid);
                      },
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: _isLoading ? null : _saveAttendance,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Attendance',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
