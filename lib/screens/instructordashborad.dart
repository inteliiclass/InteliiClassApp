import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inteliiclass/models/class_model.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Instructordashborad extends StatefulWidget {
  const Instructordashborad({super.key});

  @override
  State<Instructordashborad> createState() => _InstructordashboradState();
}

class _InstructordashboradState extends State<Instructordashborad> {
  @override
  void initState() {
    super.initState();
    // Fetch current user and then fetch their classes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final classProvider = Provider.of<ClassProvider>(context, listen: false);

      // First ensure user is loaded, then fetch their classes
      if (userProvider.currentUser != null) {
        classProvider.fetchClasses(instructorId: userProvider.currentUser!.uid);
      } else {
        // If user not loaded, fetch the user first
        final authUser = FirebaseAuth.instance.currentUser;
        if (authUser != null) {
          userProvider.fetchCurrentUser(authUser.uid).then((_) {
            final uid = userProvider.currentUser?.uid ?? authUser.uid;
            classProvider.fetchClasses(instructorId: uid);
          });
        }
      }
    });
  }

  Widget buildCourseCard(ClassModel course) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/classdetails', arguments: course);
      },
      child: Card(
        color: const Color(0xFF0F1A26),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 6, 28, 46),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.school, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.className,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${course.subject}",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

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
                    image: DecorationImage(
                      image:
                          (userProvider.currentUser?.profileImageUrl != null &&
                              userProvider
                                  .currentUser!
                                  .profileImageUrl!
                                  .isNotEmpty)
                          ? NetworkImage(
                              userProvider.currentUser!.profileImageUrl!,
                            )
                          : AssetImage('images/instructor.jpg')
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good Morning,",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      Text(
                        "Dr. ${userProvider.currentUser?.name ?? ''}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                        ),
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
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10, 25, 0, 0),
                  child: Text(
                    "Quick Actions",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
                GridView.count(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pushNamed(context, '/manageclasses');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 42,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Manage Classes",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pushNamed(context, '/attendance');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_ind,
                                  color: Colors.white,
                                  size: 42,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Attendance",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 'Generate Quiz' action removed per request
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pushNamed(context, '/assignmentlist');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_turned_in,
                                  color: Colors.white,
                                  size: 42,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Assignment",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Upcoming Classes",
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
                    'No classes yet',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: classProvider.classes.length,
                  itemBuilder: (context, index) {
                    return buildCourseCard(classProvider.classes[index]);
                  },
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
