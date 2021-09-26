import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ucspin/Admin/AdminHomePage.dart';
import 'package:ucspin/Auth/loginPage.dart';
import 'package:ucspin/components/customWidgets.dart';

class AdminLoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _AdminLoginPageState createState() => new _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  TextEditingController? _emailController =  TextEditingController();
  TextEditingController?  _passwordController =  TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FlutterSecureStorage secureStorage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {


    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _emailController,
      validator: (v) {
        if ( !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(v!)) {
          return 'email is not valid';
        } else if(v == "") {
          return "Please enter a email";
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: _passwordController,
      validator: (v) {
        if(v == "") {
          return "Please enter a password";
        } else {
          return null;
        }
      },

      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate())  {
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                email: _emailController!.text, password: _passwordController!.text)
                .then((value) async  {
                  await secureStorage.write(key: 'user', value: jsonEncode(value.user.toString()));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AdminHomePage()),
                  );
            }).catchError((e) {
              CustomWidgets.showInSnackBar(e.toString(), "type", _scaffoldKey);
            });
          }
        },
        padding: EdgeInsets.all(12),
        color: Colors.black,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );


    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Center(
        child:Form(
          key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
          SizedBox(height: 24.0),
          ElevatedButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('User Login',style: TextStyle(color: Colors.black),)
                ],
              ),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // <-- Radius
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold))),

          ],
        ),
      ),
      ),
    );
  }
}