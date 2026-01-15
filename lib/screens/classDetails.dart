import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:inteliiclass/models/user_model.dart';
import 'package:inteliiclass/models/assignment_model.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/providers/assignment_provider.dart';
import 'package:provider/provider.dart';

class ClassDetails extends StatefulWidget {
  const ClassDetails({super.key});

  @override
  State<ClassDetails> createState() => _ClassDetailsState();
}

class _ClassDetailsState extends State<ClassDetails> {
  ClassModel? _classModel;
  bool _isLoading = true;
  List<UserModel> _students = [];
  List<AssignmentModel> _assignments = [];

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
      await classProvider.fetchClasses();
      _classModel = classProvider.getClassById(classId);
    }

    if (_classModel != null) {
      await assignmentProvider.fetchAssignments(classId: _classModel!.classId);
      _assignments = assignmentProvider.getAssignmentsByClassId(
        _classModel!.classId,
      );
      await _loadStudents(_classModel!.studentIds);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadStudents(List<String> ids) async {
    _students = [];
    final usersRef = FirebaseFirestore.instance.collection('users');

    if (ids.isEmpty) return;

    try {
      if (ids.length <= 10) {
        final snapshot = await usersRef.where('uid', whereIn: ids).get();
        for (var doc in snapshot.docs) {
          _students.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
        }
      } else {
        for (final id in ids) {
          final snapshot = await usersRef
              .where('uid', isEqualTo: id)
              .limit(1)
              .get();
          if (snapshot.docs.isNotEmpty) {
            _students.add(
              UserModel.fromMap(
                snapshot.docs.first.data() as Map<String, dynamic>,
              ),
            );
          }
        }
      }
    } catch (_) {
      // ignore errors, fallback will show ids
    }
  }

  Widget _buildStudentCard(UserModel? student, String id) {
    final displayName = student?.name ?? id;
    final email = student?.email ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 2, 20, 34),
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
                  ),
                  const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildAssignmentCard(AssignmentModel a) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/assignmentdetails', arguments: a),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: const Icon(Icons.assignment, color: Colors.amber, size: 30),
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
          trailing: Text(
            '${a.totalMarks?.toInt() ?? 0} pts',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
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
          _classModel?.className ?? 'Class Details',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                                    _classModel?.className ?? '',
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
                                    _classModel?.classCode ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Dr. ${_classModel?.instructorName ?? ''}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _classModel?.subject ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _classModel?.description ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Students (${_classModel?.studentIds.length ?? 0})',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/manageclasses',
                          arguments: _classModel?.classId,
                        ),
                        icon: const Icon(Icons.add, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ..._classModel!.studentIds.map((id) {
                  final user = _students.firstWhere(
                    (u) => u.uid == id,
                    orElse: () => UserModel(
                      uid: id,
                      email: '',
                      name: id,
                      role: 'student',
                      phoneNumber: null,
                      profileImageUrl: null,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );
                  return _buildStudentCard(
                    user.uid == id && user.email == '' ? null : user,
                    id,
                  );
                }).toList(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assignments (${_assignments.length})',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/createassignment',
                          arguments: _classModel?.classId,
                        ),
                        icon: const Icon(Icons.add, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ..._assignments.map(_buildAssignmentCard).toList(),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
