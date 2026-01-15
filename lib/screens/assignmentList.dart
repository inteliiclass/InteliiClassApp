import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/providers/assignment_provider.dart';
import 'package:inteliiclass/providers/submission_provider.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/models/assignment_model.dart';
import 'package:intl/intl.dart';

class AssignmentList extends StatefulWidget {
  const AssignmentList({super.key});

  @override
  State<AssignmentList> createState() => _AssignmentListState();
}

class _AssignmentListState extends State<AssignmentList> {
  @override
  void initState() {
    super.initState();
    // Fetch assignments, submissions and related class info when the screen loads
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

      await assignmentProvider.fetchAssignments();
      await submissionProvider.fetchSubmissions();

      // Ensure class cache contains classes referenced by assignments
      for (var a in assignmentProvider.assignments) {
        if (classProvider.getClassById(a.classId) == null) {
          await classProvider.fetchClassById(a.classId);
        }
      }
      setState(() {});
    });
  }

  Widget _buildAssignmentCard(AssignmentModel assignment) {
    // Compute submission percentage from SubmissionProvider and ClassProvider
    final submissionProvider = Provider.of<SubmissionProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);

    final submissionCount = submissionProvider
        .getSubmissionsByAssignmentId(assignment.assignmentId)
        .length;
    final classModel = classProvider.getClassById(assignment.classId);
    final totalStudents = classModel?.studentIds.length ?? 0;

    double submissionPercentage;
    if (totalStudents > 0) {
      submissionPercentage = (submissionCount / totalStudents) * 100;
    } else {
      submissionPercentage = submissionCount > 0 ? 100.0 : 0.0;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/assignmentdetails',
          arguments: assignment,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          assignment.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          assignment.description,
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.grade, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${assignment.totalMarks ?? 0} pts',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submissions',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: submissionPercentage / 100,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${submissionPercentage.toInt()}% submitted',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 4, 48, 85),
        title: Text(
          'Assignments',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.filter_list))],
      ),
      body: assignmentProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : ListView(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Assignments (${assignmentProvider.assignments.length})',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (assignmentProvider.assignments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No assignments yet',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...assignmentProvider.assignments
                      .map(_buildAssignmentCard)
                      .toList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createassignment');
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
