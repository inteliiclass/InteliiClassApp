import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:inteliiclass/models/assignment_model.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/providers/assignment_provider.dart';
import 'package:inteliiclass/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Widget buildClassCard(ClassModel classData) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/studentclassdetails',
          arguments: classData,
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
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.book, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classData.className,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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
                  Icon(Icons.person, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      "Dr." + " " + classData.instructorName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.subject, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    classData.subject,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
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

  Widget buildAssignmentCard(AssignmentModel assignment) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/submitassignment');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.assignment, color: Colors.amber, size: 40),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      "Due: ${assignment.dueDate.toString().split(' ')[0]}",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pending',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      final assignmentProvider = Provider.of<AssignmentProvider>(
        context,
        listen: false,
      );

      Future<void> fetchAll() async {
        if (userProvider.currentUser != null) {
          await classProvider.fetchClasses(
            studentId: userProvider.currentUser!.uid,
          );
        } else {
          final authUser = FirebaseAuth.instance.currentUser;
          if (authUser != null) {
            await userProvider.fetchCurrentUser(authUser.uid);
            await classProvider.fetchClasses(
              studentId: userProvider.currentUser!.uid,
            );
          }
        }
        // After classes are loaded, fetch assignments once (all) so we can filter locally
        await assignmentProvider.fetchAssignments();
      }

      await fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final assignmentProvider = Provider.of<AssignmentProvider>(context);
    // Gather all assignments for the student's classes
    final studentClassIds = classProvider.classes.map((c) => c.classId).toSet();
    final assignments = assignmentProvider.assignments
        .where((a) => studentClassIds.contains(a.classId))
        .toList();
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        children: [
          ListTile(
            title: Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(5, 20, 20, 0),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back,",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      Text(
                        userProvider.currentUser?.name ?? "Student",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "My Classes",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          classProvider.isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                )
              : classProvider.classes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No classes enrolled',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: classProvider.classes.length,
                  itemBuilder: (context, index) {
                    return buildClassCard(classProvider.classes[index]);
                  },
                ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Upcoming Assignments",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          assignmentProvider.isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),
                )
              : assignments.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No upcoming assignments',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    return buildAssignmentCard(assignments[index]);
                  },
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
