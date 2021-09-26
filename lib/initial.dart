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
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:ntp/ntp.dart';
import 'package:ucspin/Admin/AdminHomePage.dart';
import 'package:ucspin/Admin/adminLogin.dart';
import 'package:ucspin/Auth/login.dart';
import 'package:ucspin/Auth/loginPage.dart';
import 'package:ucspin/demo_screen.dart';
import 'package:ucspin/env.dart';


final bannerController = BannerAdController();


class InitialPage extends StatefulWidget {
  InitialPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    bannerController.load();
    super.initState();
    initializeDefault();
  }

  Future<void> initializeDefault() async {


    FirebaseApp app = await Firebase.initializeApp();
    print('Initialized default app $app');
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
        email: "UcSpin3@gmail.com", password: "Ucspin3")
        .then((value) async  {
          print('app initialized.......');
          if (appMode == AppMode.app) {
            loadInitialPage();
          } else {
            loadAdminPage ();
          }
    }).catchError((e) async {
      print('error $e');
    });
  }

 String? pubgId;
  setSpin() async {
    var user = await secureStorage.read(key: 'user');
    print(user);
    pubgId = jsonDecode(user!)['pubgId'];

    var documentReference = FirebaseFirestore.instance
        .collection('Users')
        .doc(pubgId);

    DocumentSnapshot documentSnapshot = await documentReference.get();
    var data = documentSnapshot.data();

    if (data!['spinUpdatedTime'] != null) {
      DateTime lastTime =  DateTime.fromMillisecondsSinceEpoch(int.parse(data['spinUpdatedTime']));
      DateTime startDate = await NTP.now();
      var dif = startDate.difference(lastTime).inDays;
      if (dif != 0) {
        await secureStorage.write(key: 'totalSpin', value: '10');
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(
            documentReference,
            {
              'dailySpin' : 10,
              'spinUpdatedTime': startDate.millisecondsSinceEpoch.toString(),
            },
          );
        });
      }
    } else {
      DateTime startDate = await NTP.now();
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
          documentReference,
          {
            'dailySpin' : 10,
            'spinUpdatedTime': startDate.millisecondsSinceEpoch.toString(),
          },
        );
      });
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DemoScreen()),
    );
  }


  loadAdminPage () async  {
    if (await secureStorage.read(key: 'user') != null) {

      if (    await secureStorage.read(key: 'app') != null) {
        setSpin();

      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
      }



    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminLoginPage()),
      );
    }
  }


  loadInitialPage() async {
    print('loading......');
    if (await secureStorage.read(key: 'user') != null) {
      setSpin();
    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(child: Text('UCspin',style: TextStyle(color: Colors.amber,fontSize: 25,fontWeight: FontWeight.bold),),)
            ],
          ),
        )
    );
  }
}
