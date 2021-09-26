import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ucspin/demo_screen.dart';

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

  FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<String?> _authUser(LoginData data) async {
    print('Name: ${data.name}, Password: ${data.password}');
    var documentReference = FirebaseFirestore.instance
        .collection('Users')
        .doc(data.name);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    var data2 = documentSnapshot.data();
    var documentData = jsonEncode(documentSnapshot.data());
    if (data2 == null) {
      return 'User not exists';
    } else {
      if (jsonDecode(documentData)['password'] != data.password) {
       return 'password does not match with this pubg id';
      } else {
        await secureStorage.write(key: 'user', value: documentData);
        return null;

      }
    }

  }
  Future<String?> _authUse2(LoginData data) async {
    print('Name: ${data.name}, Password: ${data.password}');
    var documentReference = FirebaseFirestore.instance
        .collection('Users')
        .doc(data.name);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    var data2 = documentSnapshot.data();
    if (data2 == null) {
      await secureStorage.write(key: 'user', value: jsonEncode( {
        'name':'',
        'pubgId': data.name,
        'email': '',
        'password': data.password,
        'status': 0,
        'requests': 0,
        'currentUC' : 0,
        'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
      },));
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'name':'',
            'pubgId': data.name,
            'email': '',
            'password': data.password,
            'status': 0,
            'requests': 0,
            'currentUC' : 0,
            'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
          },
        );
      });
      return null;
    } else {
      return 'user already exist';
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(10.0),
      top: Radius.circular(20.0),
    );

    return FlutterLogin(

      title: 'UC Spin',
      logo: 'assets/ucLogo.png',
      messages: LoginMessages(
         userHint: 'Pubg Id',
      ),
      onLogin: _authUser,
      userValidator: (string) {
        if (string == '') {
          return 'invalid id';
        }
      },
      onSignup: _authUse2,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => DemoScreen(),
        ));
      },
      onRecoverPassword: (_) {},
      hideForgotPasswordButton: true,
      theme: LoginTheme(
        primaryColor: Colors.black,
        accentColor: Colors.yellow,
        errorColor: Colors.deepOrange,
        titleStyle: TextStyle(
          color: Colors.greenAccent,
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
        ),
        bodyStyle: TextStyle(
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
        ),
        textFieldStyle: TextStyle(
          color: Colors.orange,
          shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
        ),
        buttonStyle: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.yellow,
        ),
        cardTheme: CardTheme(
          color: Colors.yellow.shade100,
          elevation: 5,
          margin: EdgeInsets.only(top: 50),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.purple.withOpacity(.1),
          contentPadding: EdgeInsets.zero,
          errorStyle: TextStyle(
            backgroundColor: Colors.orange,
            color: Colors.white,
          ),
          labelStyle: TextStyle(fontSize: 12),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
            borderRadius: inputBorder,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
            borderRadius: inputBorder,
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700, width: 7),
            borderRadius: inputBorder,
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade400, width: 8),
            borderRadius: inputBorder,
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 5),
            borderRadius: inputBorder,
          ),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Colors.purple,
          backgroundColor: Colors.pinkAccent,
          highlightColor: Colors.lightGreen,
          elevation: 9.0,
          highlightElevation: 6.0,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          // shape: CircleBorder(side: BorderSide(color: Colors.green)),
          // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
        ),
      ),
    );
  }
}