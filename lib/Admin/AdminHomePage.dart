import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ucspin/Admin/adminLogin.dart';
import 'package:ucspin/Admin/withdrawalRequestPage.dart';
import 'package:ucspin/Auth/login.dart';
import 'package:ucspin/demo_screen.dart';
import 'package:ucspin/env.dart';


class AdminHomePage extends StatefulWidget {
  AdminHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Requests'),
          actions: [
            IconButton(onPressed: () async  {
              await secureStorage.deleteAll();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AdminLoginPage()),
                      (route) => false
              );
            }, icon: Icon(Icons.logout,color: Colors.white,))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WDRequestPage()),
            );
          },
          child: Icon(Icons.request_page_outlined,color: Colors.white,),
        ),
        body: Container(
          child: Column(
            children: [
              Flexible(child: FirestoreAnimatedList(
                query: FirebaseFirestore.instance
                    .collection('Users').where('status',isEqualTo: 0).orderBy('createdAt',descending: true),
                emptyChild: Container(
                  child: Center(
                    child: Text('No more request available'),
                  ),
                ),
                itemBuilder: (
                    BuildContext context,
                    DocumentSnapshot? snapshot,
                    Animation<double> animation,
                    int index,
                    ) => FadeTransition(
                  opacity: animation,
                  child: ListTile(
                  title : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: Text(snapshot!.data()!['pubgId'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: Text(snapshot.data()!['name'],style: TextStyle(fontSize: 12),),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: Text(snapshot.data()!['email'],style: TextStyle(fontSize: 12),),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              TextButton(onPressed: () {
                                var documentReference = FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(snapshot.data()!['pubgId'].toString());
                                FirebaseFirestore.instance.runTransaction((transaction) async {
                                  transaction.update(documentReference, {
                                    'status' : 1,
                                  });
                                });
                              }, child: Text('Verify'))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ),
              ))
            ],
          ),
        )
    );
  }
}
