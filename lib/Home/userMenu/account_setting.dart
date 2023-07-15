import 'package:atrip/Home/userMenu/user_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../component/account_setting_bar_container.dart';
import '../../component/loading.dart';
import '../../get_start/SplashScreen.dart';
import '../homeScreen.dart';

class account_setting extends StatefulWidget {
  const account_setting({Key? key}) : super(key: key);

  @override
  State<account_setting> createState() => _account_settingState();
}

class _account_settingState extends State<account_setting> {
  var firstName;
  var lastName;

  bool _isHidden1 = true;
  bool _isHidden2 = true;
  bool _isHidden3 = true;

  TextEditingController _currentpasswordcontroller = TextEditingController();
  TextEditingController _newpasswordcontroller = TextEditingController();
  TextEditingController _repeatnewpasswordcontroller = TextEditingController();

  void _togglePasswordView1() {
    setState(() {
      _isHidden1 = !_isHidden1;
    });
  }

  void _togglePasswordView2() {
    setState(() {
      _isHidden2 = !_isHidden2;
    });
  }

  void _togglePasswordView3() {
    setState(() {
      _isHidden3 = !_isHidden3;
    });
  }

  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Welcome, $FirstName",
            style: new TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),elevation: 0,
          backgroundColor: Colors.deepOrange.shade300,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade300,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: app_bar_container(),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 15, left: 10),
                              child: Text(
                                'Edit Your Information :',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: TextFormField(
                              initialValue: '${FirstName}',
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                labelText: 'First Name',
                                labelStyle: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    color: HexColor("#000000")),
                                hintText: 'Enter your first name',
                                hintStyle: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        HexColor("#000000").withOpacity(0.5)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.deepOrange,),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              onChanged: (text) {
                                firstName = text;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please Enter Your First Name';
                                } else if (firstName == null) {
                                  firstName = "${FirstName}";
                                }
                              }),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Center(
                          child: TextFormField(
                              initialValue: '${LastName}',
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                labelText: 'Last Name',
                                labelStyle: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                                hintText: 'Enter your last name',
                                hintStyle: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.deepOrange,),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              onChanged: (text) {
                                lastName = text;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please Enter Your Last Name';
                                } else if (lastName == null) {
                                  lastName = "${LastName}";
                                }
                              }),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: TextFormField(
                            enabled: false,
                            initialValue: '${Email}',
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#000000")),
                              hintText: 'Enter your Email',
                              hintStyle: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#000000").withOpacity(0.5)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(21),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      2, 5), // changes position of shadow
                                ),
                              ],
                            ),
                            width: 180,
                            height: 45,
                            child: TextButton(
                              onPressed: () async {
                                UpdateData(context);
                              },
                              style:
                                  TextButton.styleFrom(primary: Colors.deepOrange,),
                              child: Text(
                                'update Info',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Divider(thickness: 2),
                ),
                Form(
                    key: _formkey2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 40, left: 10),
                              child: Text(
                                'Change Password :',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              top: 15, left: 15, right: 15, bottom: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: TextFormField(
                                obscureText: _isHidden1,
                                controller: _currentpasswordcontroller,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  labelText: 'Current Password',
                                  labelStyle: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                  hintText: 'Enter your Current password',
                                  hintStyle: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.5)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.deepOrange,),
                                  ),                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Colors.black45),
                                  suffixIcon: InkWell(
                                    onTap: _togglePasswordView1,
                                    child: Icon(
                                      Icons.visibility,
                                      color:
                                          HexColor("#496171").withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Fill Current Password Input';
                                  }
                                  return null;
                                }),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              top: 15, left: 15, right: 15, bottom: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: TextFormField(
                                obscureText: _isHidden2,
                                controller: _newpasswordcontroller,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  labelText: 'New Password',
                                  labelStyle: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                  hintText: 'Enter your New password',
                                  hintStyle: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.5)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.deepOrange,),
                                  ),                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Colors.black45),
                                  suffixIcon: InkWell(
                                    onTap: _togglePasswordView2,
                                    child: Icon(
                                      Icons.visibility,
                                      color:
                                          HexColor("#496171").withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Fill New Password Input';
                                  }
                                  return null;
                                }),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              top: 15, left: 15, right: 15, bottom: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: TextFormField(
                                obscureText: _isHidden3,
                                controller: _repeatnewpasswordcontroller,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  labelText: 'Repeat Your Password',
                                  labelStyle: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                  hintText: 'Current Password',
                                  hintStyle: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.5)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.deepOrange,),
                                  ),                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Colors.black45),
                                  suffixIcon: InkWell(
                                    onTap: _togglePasswordView3,
                                    child: Icon(
                                      Icons.visibility,
                                      color:
                                          HexColor("#496171").withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please Repeat Your Password';
                                  } else {
                                    return _newpasswordcontroller.text == value
                                        ? null
                                        : "Please Validate Your Entered Password";
                                  }
                                }),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      2, 5), // changes position of shadow
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(21),
                            ),
                            width: 250,
                            height: 45,
                            child: TextButton(
                              onPressed: () async {
                                Updateassword(context);
                              },
                              style:
                                  TextButton.styleFrom(primary: Colors.white),
                              child: Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Divider(thickness: 2),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: HexColor("#BC2C2C"),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: 180,
                  height: 45,
                  child: new TextButton(
                      style: TextButton.styleFrom(primary: Colors.white),
                      onPressed: () {
                        deleteAccount(context);
                      },
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> UpdateData(context) async {
    if (_formkey.currentState!.validate()) {
      try {
        var uid = FirebaseAuth.instance.currentUser!.uid;
        var url = ImgUrl;
        showLoading(context);
        if (imgpicked != null) {
          try {
            var refstorage = await FirebaseStorage.instance
                .ref("images/user_profile_images/$imgname");
            await refstorage.putFile(file!);
            url = await refstorage.getDownloadURL();

            //await FirebaseStorage.instance.refFromURL(ImgUrl!).delete();
          } catch (e) {
            print(e);
          }
        }
        var userInfo =
            FirebaseFirestore.instance.collection('users').doc('$uid');
        userInfo.update({
          'first name': firstName,
          'last name': lastName,
          'image url': url,
        });
        const snackBar = const SnackBar(
            content: Text(
              'Data Has been Updated Successfully',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const homeScreen()),
        );
      } catch (e) {}
    }
    const snackBar = const SnackBar(
        content: Text(
          'Data Has been Updated Successfully',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> Updateassword(context) async {
    if (_formkey2.currentState!.validate()) {
      showLoading(context);
      try {
        UserCredential credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: Email, password: _currentpasswordcontroller.text);
        if (credential != null) {
          FirebaseAuth instance = FirebaseAuth.instance;
          await instance.currentUser
              ?.updatePassword(_newpasswordcontroller.text)
              .then((_) {
            print("Successfully changed password");
            Navigator.of(context).pop();
            const snackBar = const SnackBar(
                content: Text(
                  'Successfully changed password',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const homeScreen()),
            );
          }).catchError((error) {
            print("Password can't be changed" + error.toString());
            var e = error.toString();
            if (e.contains('weak-password') ) {
              Navigator.of(context).pop();
              final snackBar = SnackBar(
                  content: Text(
                    'weak password',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.redAccent);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          });
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          Navigator.of(context).pop();
          final snackBar = SnackBar(
              content: Text(
                'invalid email',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        if (e.code == 'user-disabled') {
          Navigator.of(context).pop();
          final snackBar = SnackBar(
              content: Text(
                'user disabled',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        if (e.code == 'user-not-found') {
          Navigator.of(context).pop();
          final snackBar = SnackBar(
              content: Text(
                'user not found',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        if (e.code == 'wrong-password') {
          Navigator.of(context).pop();
          final snackBar = SnackBar(
              content: Text(
                'your current password is wrong',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      TextEditingController passwordController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter your password to confirm account deletion:'),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    String password = passwordController.text;

                    var uid = FirebaseAuth.instance.currentUser!.uid;
                    showLoading(context);
                    try {
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: password,
                      );
                      await user.reauthenticateWithCredential(credential);
                      try {
                        await user.delete();
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .delete();
                        const snackBar = const SnackBar(
                            content: Text(
                              'Your account deleted successfully.',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.white);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Splash()),
                        );
                        print("User account deleted successfully.");
                      } catch (e) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        var snackBar = SnackBar(
                            content: Text(
                              "Failed to delete user account: $e",
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.white);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        print("Failed to delete user account:\n$e");
                      }
                    } on FirebaseAuthException catch (e) {
                      Navigator.of(context).pop();
                      if (e.code == 'invalid-email') {
                        Navigator.of(context).pop();
                        final snackBar = SnackBar(
                            content: Text(
                              'invalid email',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      if (e.code == 'user-disabled') {
                        Navigator.of(context).pop();
                        final snackBar = SnackBar(
                            content: Text(
                              'user disabled',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      if (e.code == 'user-not-found') {
                        Navigator.of(context).pop();
                        final snackBar = SnackBar(
                            content: Text(
                              'user not found',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      if (e.code == 'wrong-password') {
                        Navigator.of(context).pop();
                        final snackBar = SnackBar(
                            content: Text(
                              'your entered password is wrong',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  }),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop();
      var snackBar = SnackBar(
          content: Text(
            "Please re-signin to be able to delete your account",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print("No user is currently signed in.");
    }
  }
}
