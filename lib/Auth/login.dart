import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ucspin/components/customWidgets.dart';
import 'package:ucspin/demo_screen.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController? _emailController =  TextEditingController();
  TextEditingController?  _passwordController =  TextEditingController();
  TextEditingController?  _nameController =  TextEditingController();
  TextEditingController? _pubgIdController =  TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {

    //GO logo widget
    Widget logo() {
      return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 220,
          child: Stack(
            children: <Widget>[
              Positioned(
                  child: Container(
                    child: Align(
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        width: 150,
                        height: 150,
                      ),
                    ),
                    height: 154,
                  )),
              Positioned(
                child: Container(
                    height: 154,
                    child: Align(
                      child: Text(
                        "GO",
                        style: TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )),
              ),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.width * 0.15,
                bottom: MediaQuery.of(context).size.height * 0.046,
                right: MediaQuery.of(context).size.width * 0.22,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                ),
              ),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.08,
                height: MediaQuery.of(context).size.width * 0.08,
                bottom: 0,
                right: MediaQuery.of(context).size.width * 0.32,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    void _loginSheet(context) {


      showBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        builder: (BuildContext context) {
          return BottomSheet(
            emailController: _emailController,
            passwordController: _passwordController,
            pubgIdController: _pubgIdController,
            register: false,
            scaffoldKey: _scaffoldKey,
          );
        },
      );
    }

    void _registerSheet(context) {
      showBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return BottomSheet(
            emailController: _emailController,
            passwordController: _passwordController,
            nameController: _nameController,
            pubgIdController: _pubgIdController,
            register: true,
            scaffoldKey: _scaffoldKey,
          );
        },
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            logo(),
            Padding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomButton(
                    label: "LOGIN",
                    primaryColor: Colors.white,
                    secondaryColor:  Theme.of(context).primaryColor,
                    onPressed: () => _loginSheet(context),
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    label: "REGISTER",
                    primaryColor:  Theme.of(context).primaryColor,
                    secondaryColor: Colors.white,
                    onPressed: () => _registerSheet(context),
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 80, left: 20, right: 20),
            ),
            Expanded(
              child: Align(
                child: ClipPath(
                  child: Container(
                    color: Colors.white,
                    height: 300,
                  ),
                  clipper: BottomWaveClipper(),
                ),
                alignment: Alignment.bottomCenter,
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        );
      }),
    );
  }
}

class CustomButton extends StatelessWidget {
  final Color? primaryColor;
  final Color? secondaryColor;

  final String? label;
  final Function()? onPressed;
  const CustomButton({
    Key? key,
    this.primaryColor,
    this.secondaryColor,
    @required this.label,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: RaisedButton(
        highlightElevation: 0.0,
        splashColor: secondaryColor,
        highlightColor: primaryColor,
        elevation: 0.0,
        color: primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0), side: BorderSide(color: Colors.white, width: 3)),
        child: Text(
          label!,
          style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor, fontSize: 20),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final Icon? icon;
  final String? hint;
  final TextEditingController? controller;
  final bool? obsecure;
  final String? Function(String?)? validator;

  const CustomTextField({
    this.controller,
    this.hint,
    this.icon,
    this.obsecure,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obsecure ?? false,
      style: TextStyle(
        fontSize: 20,
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
          hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          hintText: hint,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 3,
            ),
          ),
          prefixIcon: Padding(
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).primaryColor),
              child: icon!,
            ),
            padding: EdgeInsets.only(left: 30, right: 10),
          )),
    );
  }
}

class BottomSheet extends StatelessWidget {
   BottomSheet({
    Key? key,
    @required TextEditingController? emailController,
    @required TextEditingController? passwordController,
    TextEditingController? nameController,
    TextEditingController? pubgIdController,
    bool? register,
     GlobalKey<ScaffoldState>? scaffoldKey,
  })  : _emailController = emailController,
        _passwordController = passwordController,
        _nameController = nameController,
        _pubgIdController = pubgIdController,
        _register = register,
         _scaffoldKey = scaffoldKey,
        super(key: key);

  final TextEditingController? _emailController;
  final TextEditingController? _passwordController;
  final TextEditingController? _nameController;
  final TextEditingController? _pubgIdController;
  final bool? _register;
  final GlobalKey<ScaffoldState>? _scaffoldKey;
   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   FlutterSecureStorage secureStorage = FlutterSecureStorage();

  List<Widget> get _registerLogo => [
    Positioned(
      child: Container(
        padding: EdgeInsets.only(bottom: 25, right: 40),
        child: Text(
          "REGI",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        alignment: Alignment.center,
      ),
    ),
    Positioned(
      child: Align(
        child: Container(
          padding: EdgeInsets.only(top: 40, left: 28),
          width: 130,
          child: Text(
            "STER",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 36),
          ),
        ),
        alignment: Alignment.center,
      ),
    ),
  ];
  List<Widget> get _loginLogo => [
    Align(
      alignment: Alignment.center,
      child: Container(
        child: Text(
          "LOGIN",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        alignment: Alignment.center,
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {

    return  Container(
          height: MediaQuery.of(context).size.height / 1.1,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,),
          child: ListView(
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 10,
                      top: 10,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _emailController?.clear();
                          _passwordController?.clear();
                          _nameController?.clear();
                          _pubgIdController?.clear();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 30.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  ],
                ),
                height: 50,
                width: 50,
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Form(
                    key: _formKey,
                    child:Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 140,
                          child: Stack(
                            children: <Widget>[
                              Align(
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration:
                                  BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                                ),
                                alignment: Alignment.center,
                              ),
                              ..._nameController != null ? _registerLogo : _loginLogo
                            ],
                          ),
                        ),
                        SizedBox(height: 60),
                          if(_register!)
                          CustomTextField(
                            controller: _nameController,
                            hint: "NAME",
                            icon: Icon(Icons.person),
                            validator: (v) {
                              if(v == "") {
                                return "Please enter a name";
                              } else {
                                return null;
                              }
                            },
                          ),
                        if(_register!)
                          SizedBox(height: 20),
                          CustomTextField(
                            controller: _pubgIdController,
                            hint: "PUBG ID",
                            icon: Icon(Icons.person),
                            validator: (v) {
                              if(v == "") {
                                return "Please enter a pubgId";
                              } else {
                                return null;
                              }
                            },
                          ),
                        SizedBox(height: 20),
                        if(_register!)
                          CustomTextField(
                          controller: _emailController,
                          hint: "EMAIL",
                          icon: Icon(Icons.email),
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
                        ),
                        if (_register!)
                          SizedBox(height: 20),
                        CustomTextField(
                          controller: _passwordController,
                          hint: "PASSWORD",
                          icon: Icon(Icons.lock),
                          obsecure: true,
                          validator: (v) {
                            if(v == "") {
                              return "Please enter a password";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                          label: _register! ? "REGISTER" : "LOGIN",
                          primaryColor: Theme.of(context).primaryColor,
                          secondaryColor: Colors.white,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_register!) {
                                register(context);
                              } else {
                                login(context);
                              }
                            }
                          },
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // height: MediaQuery.of(context).size.height / 1.1,
          // width: MediaQuery.of(context).size.width,
          color: Colors.white,

        );
  }

  register(context) async  {
    CustomWidgets.loader(context, show: true);
    var documentReference = FirebaseFirestore.instance
        .collection('Users')
        .doc(_pubgIdController?.text);

    DocumentSnapshot documentSnapshot = await documentReference.get();
    var data = documentSnapshot.data();
    if (data == null) {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'name': _nameController?.text,
            'pubgId': _pubgIdController?.text,
            'email': _emailController?.text,
            'password': _passwordController?.text,
            'status': 0,
            'requests': 0,
            'currentUC' : 0,
            'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
          },
        );
      }).then((value) async {
        await secureStorage.write(key: 'user', value: jsonEncode({
          'name': _nameController?.text,
          'pubgId': _pubgIdController?.text,
          'email': _emailController?.text,
          'password': _passwordController?.text,
          'status': 0,
          'requests': 0,
          'currentUC' : 0,
          'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
        },));
        CustomWidgets.loader(context, show: false);
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DemoScreen()),
        );
      });
    } else {
      CustomWidgets.loader(context, show: false);
      Navigator.pop(context);
      _scaffoldKey!.currentState!.showSnackBar(new SnackBar(
          content: new Text('user already exist')
      ));
    }



  }
  login(context) async {
    CustomWidgets.loader(context, show: true);
    var documentReference = FirebaseFirestore.instance
        .collection('Users')
        .doc(_pubgIdController?.text);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    var data = documentSnapshot.data();
    var documentData = jsonEncode(documentSnapshot.data());
    CustomWidgets.loader(context, show: false);
    if (data == null) {
      Navigator.pop(context);
      _scaffoldKey!.currentState!.showSnackBar(new SnackBar(
          content: new Text('User does not exist')
      ));
    } else {
      if (jsonDecode(documentData)['password'] != _passwordController?.text) {
        Navigator.pop(context);
        _scaffoldKey!.currentState!.showSnackBar(new SnackBar(
            content: new Text('password does not match with this pubg id')));
      } else {
        await secureStorage.write(key: 'user', value: documentData);
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DemoScreen()),
        );
      }
    }

  }


}


class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.lineTo(0.0, size.height + 5);
    var secondControlPoint = Offset(size.width - (size.width / 6), size.height);
    var secondEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}