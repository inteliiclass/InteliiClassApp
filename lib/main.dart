import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:inteliiclass/screens/instructorLogin.dart';
import 'package:inteliiclass/screens/instructordashborad.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inteliiclass/screens/roleSelection.dart';
import 'package:inteliiclass/screens/studentLogin.dart';
import 'package:inteliiclass/screens/studentDashboard.dart';
import 'package:inteliiclass/screens/classDetails.dart';
import 'package:inteliiclass/screens/assignmentList.dart';
import 'package:inteliiclass/screens/assignmentDetails.dart';
import 'package:inteliiclass/screens/createAssignment.dart';
import 'package:inteliiclass/screens/submitAssignment.dart';
import 'package:inteliiclass/screens/attendanceScreen.dart';
import 'package:inteliiclass/screens/manageClasses.dart';
import 'package:inteliiclass/screens/studentClassDetails.dart';
import 'package:inteliiclass/providers/assignment_provider.dart';
import 'package:inteliiclass/providers/class_provider.dart';
import 'package:inteliiclass/providers/user_provider.dart';
import 'package:inteliiclass/providers/attendance_provider.dart';
import 'package:inteliiclass/providers/submission_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => SubmissionProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Roleselection(),
        '/instructordashborad': (context) => Instructordashborad(),
        '/instructorlogin': (context) => Instructorlogin(),
        '/studentlogin': (context) => Studentlogin(),
        '/studentdashboard': (context) => StudentDashboard(),
        '/classdetails': (context) => ClassDetails(),
        '/studentclassdetails': (context) => StudentClassDetails(),
        '/assignmentlist': (context) => AssignmentList(),
        '/assignmentdetails': (context) => AssignmentDetails(),
        '/createassignment': (context) => CreateAssignment(),
        '/submitassignment': (context) => SubmitAssignment(),
        '/attendance': (context) => AttendanceScreen(),
        '/manageclasses': (context) => ManageClasses(),
      },
      theme: ThemeData(
        cardTheme: CardThemeData(color: Color.fromARGB(255, 4, 48, 85)),
        inputDecorationTheme: InputDecorationThemeData(
          labelStyle: GoogleFonts.poppins(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          iconColor: Colors.grey,
        ),
        fontFamily: "GoogleFonts.poppins",
        //focusColor: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 2, 20, 34),
      ),
    );
  }
}
