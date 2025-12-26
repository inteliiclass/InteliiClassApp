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
                Container(alignment: Alignment.bottomRight,child: IconButton(onPressed: (){}, icon: Icon(Icons.notifications,color: Colors.white,),))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
