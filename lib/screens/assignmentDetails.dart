import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inteliiclass/providers/assignment_provider.dart';
import 'package:inteliiclass/providers/submission_provider.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/models/assignment_model.dart';
import 'package:inteliiclass/models/submission_model.dart';

class AssignmentDetails extends StatefulWidget {
  const AssignmentDetails({super.key});

  @override
  State<AssignmentDetails> createState() => _AssignmentDetailsState();
}

class _AssignmentDetailsState extends State<AssignmentDetails> {
  AssignmentModel? _assignmentModel;
  List<SubmissionModel> _submissions = [];
  bool _isLoading = true;

  Widget _buildSubmissionCard(SubmissionModel submission) {
    final studentName = submission.studentName;
    final submittedAt = submission.submittedAt.toLocal().toString().split(
      ' ',
    )[0];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            studentName.isNotEmpty ? studentName[0] : 'S',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          studentName,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submitted: $submittedAt',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
            ),
            if (submission.isLate)
              Text(
                'Late Submission',
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
        trailing: submission.obtainedMarks != null
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${submission.obtainedMarks}/${_assignmentModel?.totalMarks?.toInt() ?? 0}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: () => _showGradeDialog(submission),
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                ),
                child: Text(
                  'Grade',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
      ),
    );
  }

  Future<void> _showGradeDialog(SubmissionModel submission) async {
    final marksController = TextEditingController();
    final feedbackController = TextEditingController();
    final submissionProvider = Provider.of<SubmissionProvider>(
      context,
      listen: false,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 4, 48, 85),
          title: Text(
            'Grade Submission',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: marksController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Marks',
                  hintText: 'e.g. 85',
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(labelText: 'Feedback (optional)'),
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final marksText = marksController.text.trim();
                if (marksText.isEmpty) return;
                final marks = double.tryParse(marksText) ?? 0.0;
                final feedback = feedbackController.text.trim().isEmpty
                    ? null
                    : feedbackController.text.trim();
                try {
                  await submissionProvider.gradeSubmission(
                    submission.submissionId,
                    marks,
                    feedback,
                  );
                  Navigator.pop(context, true);
                } catch (e) {
                  Navigator.pop(context, false);
                }
              },
              child: Text(
                'Submit',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // refresh submissions
      if (_assignmentModel?.assignmentId != null) {
        await submissionProvider.fetchSubmissions(
          assignmentId: _assignmentModel!.assignmentId,
        );
        setState(() {
          _submissions = submissionProvider.getSubmissionsByAssignmentId(
            _assignmentModel!.assignmentId,
          );
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Graded successfully')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final assignmentProvider = Provider.of<AssignmentProvider>(
        context,
        listen: false,
      );
      final submissionProvider = Provider.of<SubmissionProvider>(
        context,
        listen: false,
      );
      final classProvider = Provider.of<ClassProvider>(context, listen: false);

      final args = ModalRoute.of(context)?.settings.arguments;
      String? assignmentId;
      if (args is String) {
        assignmentId = args;
      } else if (args is AssignmentModel) {
        _assignmentModel = args;
        assignmentId = _assignmentModel?.assignmentId;
      }

      if (_assignmentModel == null && assignmentId != null) {
        // try provider cache first
        _assignmentModel = assignmentProvider.getAssignmentById(assignmentId);
        if (_assignmentModel == null) {
          await assignmentProvider.fetchAssignments();
          _assignmentModel = assignmentProvider.getAssignmentById(assignmentId);
        }
        // final fallback: fetch doc directly
        if (_assignmentModel == null) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection('assignments')
                .doc(assignmentId)
                .get();
            if (doc.exists) {
              _assignmentModel = AssignmentModel.fromMap(
                doc.data() as Map<String, dynamic>,
              );
            }
          } catch (_) {}
        }
      }

      if (assignmentId != null) {
        await submissionProvider.fetchSubmissions(assignmentId: assignmentId);
        _submissions = submissionProvider.getSubmissionsByAssignmentId(
          assignmentId,
        );
      }

      if (_assignmentModel != null) {
        // ensure class is cached for name lookup
        if (classProvider.getClassById(_assignmentModel!.classId) == null) {
          await classProvider.fetchClassById(_assignmentModel!.classId);
        }
      }

      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 48, 85),
        title: Text(
          'Assignment Details',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.edit))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.assignment,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _assignmentModel?.title ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '${_assignmentModel != null ? (Provider.of<ClassProvider>(context).getClassById(_assignmentModel!.classId)?.className ?? '') : ''}',
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.grey, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Dr. ${_assignmentModel != null ? (Provider.of<ClassProvider>(context).getClassById(_assignmentModel!.classId)?.instructorName ?? _assignmentModel!.instructorId) : ''}',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Due: ${_assignmentModel != null ? _assignmentModel!.dueDate.toLocal().toString().split(' ')[0] : ''}',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.grade, color: Colors.grey, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Total Marks: ${_assignmentModel?.totalMarks?.toInt() ?? 0}',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Description',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _assignmentModel?.description ?? '',
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
                  child: Text(
                    'Submissions (${_submissions.length})',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ..._submissions.map((s) => _buildSubmissionCard(s)).toList(),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
