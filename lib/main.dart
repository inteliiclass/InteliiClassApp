import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inteliiclass/screens/instructorLogin.dart';
import 'package:inteliiclass/screens/instructordashborad.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => MainApp(),
        '/instructorlogin': (context) => Instructorlogin(),
        '/instructordashborad': (context) => Instructordashborad(),
      },
      theme: ThemeData(
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Instructorlogin());
  }
}
