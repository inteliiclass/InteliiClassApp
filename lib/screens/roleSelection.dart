import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Roleselection extends StatefulWidget {
  const Roleselection({super.key});

  @override
  State<Roleselection> createState() => _RoleselectionState();
}

class _RoleselectionState extends State<Roleselection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color.fromARGB(255, 4, 48, 85),
                  ),
                  child: Image.asset(
                    "images/logo.png",
                    width: 140,
                    height: 140,
                    fit: BoxFit.fill,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  "IntelliClass",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 50),
                ),
                Text(
                  "Welcome to the Future of Learning",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 20),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 40, 0, 20),
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    "Select your role",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 23,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work, color: Colors.blue, size: 40),
                          SizedBox(height: 8),
                          Text(
                            "I am a Instructor ",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  backgroundColor: WidgetStateProperty.all(
                                    Color.fromARGB(255, 8, 78, 134),
                                  ),
                                ),
                                onPressed: () {
                                   Navigator.pushNamed(context, '/instructorlogin');
                                },
                                child: Text(
                                  "Continue as Instructor",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school, color: Colors.blue, size: 40),
                          SizedBox(height: 8),
                          Text(
                            "I am a Student ",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  backgroundColor: WidgetStateProperty.all(
                                    Color.fromARGB(255, 8, 78, 134),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/studentlogin');
                                },
                                child: Text(
                                  "Continue as Student",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
