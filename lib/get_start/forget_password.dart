import 'package:atrip/get_start/signIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../component/loading.dart';

class forget_password extends StatefulWidget {
  const forget_password({Key? key}) : super(key: key);

  @override
  State<forget_password> createState() => _forget_passwordState();
}

class _buildappbar extends StatelessWidget {
  final name;

  const _buildappbar({super.key, required this.name});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context)),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      flexibleSpace: Container(
        child: Container(
          alignment: Alignment.bottomCenter,
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [HexColor("#f5d3a5"), HexColor("#D3AC78"), HexColor("#7a4f25")],
            ),
            borderRadius: new BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0))),
      ),
      title: Text(
        name,
        style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _forget_passwordState extends State<forget_password> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController _emailcontroller = TextEditingController();

  @override
  void dispose() {
    _emailcontroller.dispose();

    super.dispose();
  }

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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: _buildappbar(name: "Forget Password"),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 600,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height:200 ,
                        width: 150,
                        margin: EdgeInsets.only(top:20),
                        child: Image(
                          image: AssetImage('assets/icons/forget_password.png'),
                        ),
                      ),
                      SizedBox(height: 20),

                      Container(
                        padding: EdgeInsets.only(left: 15,right: 15),
                        child: Form(
                            key: _formkey,
                            child: Column(
                              children: <Widget>[

                                Row(
                                  children: const [
                                    Text(
                                      'Enter Your Email:',
                                      style: TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: TextFormField(
                                      controller: _emailcontroller,
                                      decoration: InputDecoration(
                                        contentPadding:
                                        EdgeInsets.only(left: 15, right: 15),
                                        prefixIcon: const Icon(Icons.mail_outline_outlined,
                                            color: Colors.black45),
                                        labelText: 'Email Address',
                                        labelStyle: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black45),
                                        hintText: 'Ex namaemail@email.com',
                                        hintStyle: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500,
                                            color:
                                            Colors.black45),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Fill Email Input';
                                        }
                                        return null;
                                      }),
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                const Text(
                                  'Confirm your email and we will sent you the Instruction',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [HexColor("#f5d3a5"), HexColor("#7a4f25")],
                                      ),
                                      borderRadius: BorderRadius.circular(21),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(2, 5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    width: 200,
                                    height: 45,
                                    child: TextButton(
                                      onPressed: () async {
                                        _reset_password();
                                      },
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                      ),
                                      child: Text(
                                        'Reset Password',
                                        style: TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),


                              ],
                            )),
                      ),

                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
  _reset_password(){
    if (_formkey.currentState!.validate()) {
      showLoading(context);


      FirebaseAuth.instance.sendPasswordResetEmail(email: _emailcontroller.text)
          .then((value){
        final snackBar = SnackBar(
            content: Text(
              'Email has been Sent Successfully to \n ${_emailcontroller.text}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.lightGreen);
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => signIn()),
        );
      }).catchError((e){
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
        if (e.code == 'invalid-email') {
          print("e=${e.code}");
          Navigator.of(context).pop();
          final snackBar = SnackBar(
              content: Text(
                'invalid email',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    }
  }
}
