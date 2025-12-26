import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Instructordashborad extends StatefulWidget {
  const Instructordashborad({super.key});

  @override
  State<Instructordashborad> createState() => _InstructordashboradState();
}

class _InstructordashboradState extends State<Instructordashborad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
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
                      image: AssetImage('images/instructor.jpg'),
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
                        "Dr. Omar,",
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
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF0F2D4A),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Color(0xFF1E6DD8), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: const Color(0xFF1E6DD8),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "INTELLICLASS AI: ONLINE",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E6DD8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
