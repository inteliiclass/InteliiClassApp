import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:inteliiclass/models/user_model.dart';

class ClassDetails extends StatefulWidget {
  const ClassDetails({super.key});

  @override
  State<ClassDetails> createState() => _ClassDetailsState();
}

class _ClassDetailsState extends State<ClassDetails> {
  ClassModel? _classModel;
  bool _isLoading = true;
  List<UserModel> _students = [];

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
                ...(_classModel?.studentIds ?? []).map((id) {
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
              ],
            ),
    );
  }
}
