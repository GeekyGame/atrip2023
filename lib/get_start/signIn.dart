import 'package:atrip/get_start/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:atrip/Home/homeScreen.dart';

import '../../component/loading.dart';
import 'forget_password.dart';

class signIn extends StatefulWidget {
  const signIn({Key? key}) : super(key: key);

  @override
  State<signIn> createState() => _signIn();
}

class _signIn extends State<signIn> {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  bool passenable = true;
  
  Widget build(BuildContext context) {
    final Size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/sky2.png"),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,

            ),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: Size.height * 0.01),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff252525),
                        ),
                      ),
                      SizedBox(height: Size.height * 0.06),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Color(0xffFFF0DE).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextFormField(
                          controller: _emailcontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "Email",
                            labelStyle:
                                TextStyle(fontSize: 20, color: Color(0xff935B36)),
                            hintText: 'Enter your Email',
                            hintStyle: TextStyle(fontSize: 20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                print('value=$value');
                                return 'Please Fill Email Input';
                              }
                              return null;
                            }
                        ),

                      ),
                      SizedBox(height: Size.height * 0.05),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Color(0xffFFF0DE).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextFormField(
                          controller: _passwordcontroller,
                          obscureText: passenable,
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0.5),
                              border: InputBorder.none,
                              labelText: "Password",
                              labelStyle:
                                  TextStyle(fontSize: 20, color: Color(0xff935B36)),
                              hintText: 'Enter your Password',
                              hintStyle: TextStyle(fontSize: 20),
                              suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (passenable) {
                                        passenable = false;
                                      } else {
                                        passenable = true;
                                      }
                                    });
                                  },
                                  icon: Icon(passenable == true
                                      ? Icons.remove_red_eye
                                      : Icons.password))),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                print('value=$value');
                                return 'Please Fill Password Input';
                              }
                              return null;
                            }
                        ),
                      ),
                      SizedBox(height: Size.height * 0.05),
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xff935B36),
                              onPrimary: Colors.white,
                              textStyle: TextStyle(fontSize: 22),
                            ),
                            child: Text('Log In'),
                            onPressed: () {
                              _Singin(context);
                            },
                          ),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.black54,
                              textStyle: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline
                              ),
                            ),
                            child: Text('Forget Password'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  forget_password()),
                              );
                            },
                          ),

                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account ?",

                              style: TextStyle(fontSize: 20)),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              onPrimary: Color(0xff935B36),
                              textStyle: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text('Sign Up'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const signUp()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  _Singin (context) async {
    if(_formkey.currentState!.validate()){
      showLoading(context);
      try{

        UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailcontroller.text, password: _passwordcontroller.text);

        if(credential != null){
          print('login successfully');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => homeScreen()),
          );
        }

      }on FirebaseAuthException catch (e) {
        if(e.code == 'invalid-email'){
          Navigator.of(context).pop();
          final snackBar = SnackBar(content: Text('invalid email',style: TextStyle(color: Colors.white),),backgroundColor: Colors.redAccent);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        if(e.code == 'user-disabled'){
          Navigator.of(context).pop();
          final snackBar = SnackBar(content: Text('user disabled',style: TextStyle(color: Colors.white),),backgroundColor: Colors.redAccent);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }
        if(e.code == 'user-not-found'){
          Navigator.of(context).pop();
          final snackBar = SnackBar(content: Text('user not found',style: TextStyle(color: Colors.white),),backgroundColor: Colors.redAccent);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }
        if(e.code == 'wrong-password'){
          Navigator.of(context).pop();
          final snackBar = SnackBar(content: Text('wrong password',style: TextStyle(color: Colors.white),),backgroundColor: Colors.redAccent);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }
        else{print(e);}
      }
    }
  }
}
