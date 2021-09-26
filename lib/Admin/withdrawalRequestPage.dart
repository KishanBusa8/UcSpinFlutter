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
import 'package:ucspin/Admin/userRequests.dart';
import 'package:ucspin/Auth/login.dart';
import 'package:ucspin/demo_screen.dart';
import 'package:ucspin/env.dart';


class WDRequestPage extends StatefulWidget {
  WDRequestPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _WDRequestPageState createState() => _WDRequestPageState();
}

class _WDRequestPageState extends State<WDRequestPage> {
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
          title: Text('Withdrawal Requests'),
        ),
        body: Container(
          child: Column(
            children: [
              Flexible(child: FirestoreAnimatedList(
                query: FirebaseFirestore.instance
                    .collection('Users').where('status',isEqualTo: 1).orderBy('createdAt',descending: true),
                filter: (DocumentSnapshot snapshot) {
                  return snapshot.data()!['requests'] == 0;
                },
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserRequestPage(pubgId: snapshot!.data()!['pubgId'],)),
                        );
                      },
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
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red
                              ),
                              child: Text(snapshot.data()!['requests'].toString(),style: TextStyle(color: Colors.white,fontSize: 12),)
                          ),
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
