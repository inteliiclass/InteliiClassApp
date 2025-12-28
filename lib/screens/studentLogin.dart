import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';


class Studentlogin extends StatefulWidget {
  const Studentlogin({super.key});

  @override
  State<Studentlogin> createState() => _StudentloginState();
}

class _StudentloginState extends State<Studentlogin> {
 final  _key = GlobalKey<FormState>();
 var obscure = true;
 TextEditingController emailcontroller = TextEditingController();
 TextEditingController passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {


    return Scaffold(body:LayoutBuilder(builder: (context,constraints) {
      double maxwidth = constraints.maxWidth;
      double maxhieght = constraints.maxHeight;
      double formwidth;
      double formhieght;
      if (maxwidth < 600) {
        formwidth = maxwidth * 0.9;
        formhieght = maxhieght * 0.8;
      } else if (maxwidth < 1000&& maxwidth>600) {
        formwidth = 520;
        formhieght =550;
      }
      else {
        formwidth = 500;
        formhieght =700;
      }
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: formwidth,minHeight:formhieght),
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                      width: 120,
                      height: 120,
                      margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 4, 48, 85),
                        borderRadius: BorderRadius.circular(25),

                      ),

                      child: Image.asset(
                        'images/logo.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.fill,
                        color: Colors.blue,
                      )
                  ),
                ),
                Center(
                  child: Text(" Student Portal",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: formwidth*0.07,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                Center(
                  child: Text("Login in to access your courses",
                    style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: formwidth*0.035
                    ),),
                ),
                Form(
                    key: _key,
                    child: Column(
                      children: [
                             ListTile(
                            title: Text('Student Email',
                              style: TextStyle(color: Colors.white),),
                            subtitle: TextFormField(
                              controller: emailcontroller,
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),

                                  ),
                                  filled: true,
                                  fillColor: Color.fromRGBO(44, 62, 80, 0.3),
                                  prefixIcon: Icon(
                                    Icons.badge,
                                  ),
                                  hintText: "Student@gmail.com",
                                  hintStyle: TextStyle(color: Colors.grey)
                              ),
                             validator: (value){
                                if(value==null || value!.isEmpty){
                                  return 'Please enter your Email';
                                }if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                ).hasMatch(value)) {
                                  return 'Enter a valid email address';
                                }
                                return null;

                             },
                            ),
                          ),
                        ListTile(
                          title: Text("Password",style: TextStyle(color: Colors.white),),
                          subtitle: TextFormField(
                            controller: passwordcontroller,
                            obscureText:  obscure ,
                            maxLength: 20,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color.fromRGBO(44, 62, 80, 0.3),
                              prefixIcon: Icon(Icons.lock),
                              hintText: "Enter your password",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: IconButton(onPressed: (){
                                setState(() {
                                  obscure = !obscure ;
                                });
                                },
                                  icon: Icon(obscure?Icons.visibility_off:Icons.visibility)

                              )
                            ),
                            validator: (value){
                              if(value!.isEmpty){
                                return 'Please enter your password';
                              }else if(value!.length<8 ){
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                        ),Container(
                          margin: EdgeInsets.only(top: 5,bottom: 10),
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forget Password?",
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                              padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                             fixedSize: WidgetStatePropertyAll(Size.fromWidth(formwidth/1.5)),
                              backgroundColor:WidgetStatePropertyAll(Colors.blue[900]) ,
                            ),
                            onPressed: (){
                          if(_key.currentState!.validate()){
                         print(passwordcontroller.text);
                         print(emailcontroller.text);

                          }

                        }, child: Text("Log in",style: TextStyle(
                            color: Colors.grey
                        ,fontFamily: GoogleFonts.poppins().fontFamily
                        ),))


                      ],
                    )

                ),

              ],
            ),
          ),

        ),
      );
    })

    );
  }
}
