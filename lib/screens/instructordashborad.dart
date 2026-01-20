import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/providers/user_provider.dart';


class Instructordashborad extends StatefulWidget {
  const Instructordashborad({super.key});

  @override
  State<Instructordashborad> createState() => _InstructordashboradState();



}

class _InstructordashboradState extends State<Instructordashborad> {

  late ClassProvider classProvider;
  late UserProvider userProvider;
  @override
  void initState() {
    super.initState();
    classProvider = Provider.of<ClassProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);


    if (userProvider.currentUser != null) {
      classProvider.fetchClasses(instructorId: userProvider.currentUser!.uid);
    }


  }


  @override
  Widget build(BuildContext context) {
    classProvider = Provider.of<ClassProvider>(context);
    userProvider = Provider.of<UserProvider>(context);
    Widget classSection;

    if (classProvider.isLoading) {
      classSection = Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    } else if (classProvider.classes.isEmpty) {
      classSection = Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'No classes yet',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    } else {
      classSection = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: classProvider.classes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/classdetails', arguments:  classProvider.classes[index]);
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      child: Center(
                        child: Icon(Icons.school, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classProvider.classes[index].className,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            classProvider.classes[index].subject,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

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
                    image: userProvider.currentUser?.profileImageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(
                        userProvider.currentUser!.profileImageUrl!,
                      ),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: Colors.blue,
                  ),
                  child: userProvider.currentUser?.profileImageUrl == null
                      ? Icon(Icons.person, color: Colors.white, size: 35)
                      : null,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome,",
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
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                  children: [
                    GestureDetector(
                      child: Card(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_fill,
                                color: Colors.blue,
                                size: 45,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                  "Manage Classes",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/manageclasses');
                      },
                    ),
                    GestureDetector(
                      child: Card(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_ind,
                                color: Colors.deepPurple,
                                size: 45,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                  "Attendance",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/attendance');
                      },
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
          classSection,
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.blue),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
              fixedSize: WidgetStatePropertyAll(Size(370, 65)),
            ),
            child: Text("Log Out"),
          ),
        ],
      ),
    );
  }
}
