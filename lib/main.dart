import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inteliiclass/screens/instructorLogin.dart';
import 'package:inteliiclass/screens/instructordashborad.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inteliiclass/screens/studentLogin.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Studentlogin(),
        '/instructordashborad': (context) => Instructordashborad(),
      },
      theme: ThemeData(
        cardTheme: CardThemeData(color: const Color.fromARGB(255, 35, 35, 37)),
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
