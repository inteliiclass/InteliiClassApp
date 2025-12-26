import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Instructorlogin extends StatefulWidget {
  const Instructorlogin({super.key});

  @override
  State<Instructorlogin> createState() => _SignInState();
}

class _SignInState extends State<Instructorlogin> {
  final key = GlobalKey<FormState>();
  String pass = "";
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return ListView(
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
                "Instructor Portal",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 20),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Form(
            child: Column(
              children: [
                ListTile(
                  title: TextFormField(
                    style: TextStyle(color: Colors.grey),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "instructor@gmail.com",
                      icon: Icon(Icons.email),
                    ),
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    style: TextStyle(color: Colors.grey),
                    obscureText: obscure,
                    obscuringCharacter: "*",
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "***********",
                      icon: Icon(Icons.password),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                        icon: Icon(Icons.visibility),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        pass = value;
                      });
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forget Password?",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context ,'/instructordashborad');
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      fixedSize: WidgetStatePropertyAll(Size(370, 65)),
                    ),
                    child: Text("Log In"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
