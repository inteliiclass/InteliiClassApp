import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/providers/submission_provider.dart';
import 'package:inteliiclass/providers/assignment_provider.dart';
import 'package:inteliiclass/providers/user_provider.dart';
import 'package:inteliiclass/models/submission_model.dart';
import 'package:inteliiclass/models/assignment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmitAssignment extends StatefulWidget {
  const SubmitAssignment({super.key});

  @override
  State<SubmitAssignment> createState() => _SubmitAssignmentState();
}

class _SubmitAssignmentState extends State<SubmitAssignment> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController submissionController = TextEditingController();

  String? _selectedFile;
  bool _isLoading = false;
  AssignmentModel? _assignmentModel;
  String? _assignmentId;

  void _selectFile() {
    // Simulate file picker
    setState(() {
      _selectedFile = 'assignment_file.pdf';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File selected: $_selectedFile'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _submitAssignment() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null && submissionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide submission text or attach a file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final submissionProvider = Provider.of<SubmissionProvider>(
          context,
          listen: false,
        );
        final assignmentProvider = Provider.of<AssignmentProvider>(
          context,
          listen: false,
        );
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Ensure we have assignment data
        if (_assignmentModel == null && _assignmentId != null) {
          _assignmentModel = assignmentProvider.getAssignmentById(
            _assignmentId!,
          );
          if (_assignmentModel == null) {
            await assignmentProvider.fetchAssignments();
            _assignmentModel = assignmentProvider.getAssignmentById(
              _assignmentId!,
            );
          }
          if (_assignmentModel == null) {
            // final fallback: try to fetch directly
            try {
              final doc = await FirebaseFirestore.instance
                  .collection('assignments')
                  .doc(_assignmentId)
                  .get();
              if (doc.exists) {
                _assignmentModel = AssignmentModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                );
              }
            } catch (_) {}
          }
        }

        final user = userProvider.currentUser;
        final authUser = FirebaseAuth.instance.currentUser;
        final studentId = user?.uid ?? authUser?.uid ?? 'unknown_student';
        final studentName = user?.name ?? authUser?.email ?? 'Student';

        final submissionId = FirebaseFirestore.instance
            .collection('submissions')
            .doc()
            .id;

        final submission = SubmissionModel(
          submissionId: submissionId,
          assignmentId: _assignmentModel?.assignmentId ?? _assignmentId ?? '',
          classId: _assignmentModel?.classId ?? '',
          studentId: studentId,
          studentName: studentName,
          submissionText: submissionController.text.trim().isEmpty
              ? null
              : submissionController.text.trim(),
          submissionFileUrl: _selectedFile, // for now store file name
          submittedAt: DateTime.now(),
          isLate: _assignmentModel != null
              ? DateTime.now().isAfter(_assignmentModel!.dueDate)
              : false,
        );

        await submissionProvider.submitAssignment(submission);

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Assignment submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submit failed: $e')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 48, 85),
        title: Text(
          'Submit Assignment',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
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
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.assignment,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flutter Quiz App',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Due: Jan 20, 2026',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '100 Points',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Submission',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: submissionController,
                      style: TextStyle(color: Colors.white),
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: 'Submission Text',
                        hintText: 'Write your submission here...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attach File',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedFile == null)
                      GestureDetector(
                        onTap: _selectFile,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: Colors.grey,
                                size: 50,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to upload file',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PDF, DOC, DOCX, ZIP',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 2, 20, 34),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              color: Colors.blue,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFile!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '2.5 MB',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _removeFile,
                              icon: Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: _isLoading ? null : _submitAssignment,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Submit Assignment',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    submissionController.dispose();
    super.dispose();
  }
}
