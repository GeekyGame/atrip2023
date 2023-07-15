import 'package:atrip/component/loading.dart';
import 'package:atrip/get_start/signIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'SplashScreen.dart';

class signUp extends StatefulWidget {
  const signUp({Key? key}) : super(key: key);

  @override
  State<signUp> createState() => _signUp();
}
class _signUp extends State<signUp> {

  TextEditingController _Firstnamecontroller = TextEditingController();
  TextEditingController _Secnamecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  TextEditingController _cPasswordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  bool passenable1 = true;
  bool passenable2 = true;

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
              image: AssetImage("assets/bg_sU.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: GestureDetector(
            onTap: (){
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: SingleChildScrollView(
              child: Center(
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      Text(
                        "Create an account",
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
                          borderRadius: BorderRadius.circular(5),            ),
                        child: TextFormField(
                            controller: _Firstnamecontroller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "First Name",
                              labelStyle: TextStyle(fontSize: 20,
                                  color: Color(0xff935B36)),
                              hintText: 'Enter your First Name',
                              hintStyle: TextStyle(fontSize: 20),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                print('value=$value');
                                return 'Please Fill First Name Input';
                              }
                              return null;
                            }
                        ),
                      ),
                      SizedBox(
                          height: Size.height * 0.02
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Color(0xffFFF0DE).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),            ),
                        child: TextFormField(
                          controller: _Secnamecontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "Second Name",
                            labelStyle: TextStyle(fontSize: 20,
                                color: Color(0xff935B36)),
                            hintText: 'Enter your Second Name',
                            hintStyle: TextStyle(fontSize: 20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                print('value=$value');
                                return 'Please Fill Second Name Input';
                              }
                              return null;
                            }
                        ),
                      ),

                      SizedBox(height: Size.height * 0.02),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Color(0xffFFF0DE).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),            ),
                        child: TextFormField(
                          controller: _emailcontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "Email",
                            labelStyle: TextStyle(fontSize: 20,
                                color: Color(0xff935B36)),
                            hintText: 'Enter your Email',
                            hintStyle: TextStyle(fontSize: 20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                print('value=$value');
                                return 'Please Fill Email Input';
                              }
                              return null;
                            }
                        ),
                      ),
                      SizedBox(height: Size.height * 0.02),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Color(0xffFFF0DE).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),            ),
                        child: TextFormField(
                          obscureText: passenable1,
                          controller: _passwordcontroller,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 0.5),
                              border: InputBorder.none,
                              labelText: "Password",
                              labelStyle: TextStyle(fontSize: 20,
                                  color: Color(0xff935B36)),
                              hintText: 'Enter your Password',
                              hintStyle: TextStyle(fontSize: 20),
                              suffix: IconButton(onPressed: (){
                                setState(() {
                                  if (passenable1){
                                    passenable1 = false;
                                  }
                                  else{
                                    passenable1 = true;
                                  }
                                });

                              },
                                  icon: Icon(passenable1 == true?Icons.remove_red_eye:Icons.password),
                              ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                print('value=$value');
                                return 'Please Fill Password Input';
                              }
                              return null;
                            }
                        ),
                      ),
                      SizedBox(
                          height: Size.height * 0.02
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Color(0xffFFF0DE).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),            ),
                        child: TextFormField(
                          controller: _cPasswordcontroller,
                          obscureText: passenable2,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 0.5),
                              border: InputBorder.none,
                              labelText: "Confirm Password",
                              labelStyle: TextStyle(fontSize: 20,
                                  color: Color(0xff935B36)),
                              hintText: 'Re-enter your Password',
                              hintStyle: TextStyle(fontSize: 20),
                              suffix: IconButton(onPressed: (){
                                setState(() {
                                  if (passenable2){
                                    passenable2 = false;
                                  }
                                  else{
                                    passenable2 = true;
                                  }
                                });

                              },icon: Icon(passenable2 == true?Icons.remove_red_eye:Icons.password)
                              )
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please Repeat Your Password';
                              }else{
                                return _passwordcontroller.text == value ? null : "Please Validate Your Entered Password";
                              }
                            }
                        ),
                      ),
                      SizedBox(
                          height: Size.height * 0.06
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xff935B36),
                              onPrimary: Colors.white,
                              textStyle: TextStyle(fontSize: 22),
                            ),
                            child: Text('Sign Up'),
                            onPressed: () {
                              if(_formkey.currentState!.validate()) {
                                _singupUser(context);
                              }
                            },
                          ),
                        ],
                      ),
                      Row(children:  [
                        Text("Already have an account ?",
                            style: TextStyle(fontSize: 20)),
                        TextButton(// <-- TextButton
                          style: ElevatedButton.styleFrom(
                            onPrimary: Color(0xffDA605B),
                            textStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold

                            ),
                          ),
                          child: Text('Sign In'),
                          onPressed: () {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const signIn()),
                            );
                          },
                        ),
                      ],
                        mainAxisAlignment: MainAxisAlignment.center,
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

  _singupUser(context) async {
    showLoading(context);
    try {
      var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailcontroller.text, password: _passwordcontroller.text);
      if (result != null) {
        var uid = FirebaseAuth.instance.currentUser!.uid;
        var imageName = 'defult_user_img.png';
        var refstorage = await FirebaseStorage.instance
            .ref("images/user_profile_images/$imageName");
        var url = await refstorage.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc('$uid')
            .set({
          'first name': _Firstnamecontroller.text,
          'second name': _Secnamecontroller.text,
          'email': _emailcontroller.text,
          'image url': url ,
          'userid': uid,
          'user state': 'new',
        });
        Navigator.of(context).pop();
        final snackBar = SnackBar(
            content: Text(
              'Accounts Created Successfully',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.lightGreen);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Splash()),
        );
      }
      else {
        Navigator.of(context).pop();
        final snackBar = SnackBar(
            content: Text(
              'please try later!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => signIn()),
        );
        final snackBar = SnackBar(
            content: Text(
              'Email already in use, Please SignIn',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else if (e.code == 'invalid-email') {
        Navigator.of(context).pop();
        final snackBar = SnackBar(
            content: Text(
              'invalid email',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else if (e.code == 'weak-password') {
        Navigator.of(context).pop();
        final snackBar = SnackBar(
            content: Text(
              'weak password',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else {
        print("error in signup:$e");
        Navigator.of(context).pop();
        final snackBar = SnackBar(
            content: Text(
              'if you the Admin, Check the Database Rules',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      }
    }
  }
}
