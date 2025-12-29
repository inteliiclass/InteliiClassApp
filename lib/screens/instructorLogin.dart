import 'package:firebase_auth/firebase_auth.dart';
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
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
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
                  "Instructor Portal",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 20),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Form(
              key: key,
              child: Column(
                children: [
                  ListTile(
                    title: TextFormField(
                      controller: emailcontroller,
                      style: TextStyle(color: Colors.grey),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "instructor@gmail.com",
                        icon: Icon(Icons.email),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a Valid Email';
                        }
                        if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          emailcontroller.text = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: TextFormField(
                      controller: passwordcontroller,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your Password";
                        } else
                          return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          pass = value;
                          passwordcontroller.text = value;
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
                      onPressed: () async {
                        if ((key.currentState!.validate())) {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: emailcontroller.text.trim(),
                                  password: passwordcontroller.text,
                                );
                            Navigator.pushNamed(
                              context,
                              '/instructordashborad',
                            );
                          } on FirebaseAuthException catch (e) {
                            String message;
                            switch (e.code) {
                              case 'invalid-email':
                                message = 'Invalid email address.';
                                break;
                              case 'user-disabled':
                                message = 'User account is disabled.';
                                break;
                              case 'user-not-found':
                                message = 'No user found for that email.';
                                break;
                              case 'wrong-password':
                                message = 'Incorrect password.';
                                break;
                              default:
                                message = e.message ?? 'Sign-in failed.';
                            }
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Unexpected error: $e')),
                            );
                          }
                        }
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
      ),
    );
  }
}
