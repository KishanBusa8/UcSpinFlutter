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
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ucspin/Admin/adminLogin.dart';
import 'package:ucspin/Auth/login.dart';
import 'package:ucspin/demo_screen.dart';
import 'package:ucspin/env.dart';


class UserRequestPage extends StatefulWidget {
  UserRequestPage({Key? key, this.pubgId, this.title}) : super(key: key);

  final String? title;
  final String? pubgId;

  @override
  _UserRequestPageState createState() => _UserRequestPageState();
}

class _UserRequestPageState extends State<UserRequestPage> {
  FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController? _voucherController =  TextEditingController();

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
          title: Text('Users all withdrawal Requests'),

        ),
        body: Container(
          child: Column(
            children: [
              Flexible(child: FirestoreAnimatedList(
                query: FirebaseFirestore.instance
                    .collection('Requests').doc(widget.pubgId).collection("${widget.pubgId}").where('status',isEqualTo: 0),
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
                      onTap: () {},
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
                                  child: Text(snapshot!.data()!['requestedUc'].toString(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                TextButton(onPressed: () {
                                  _voucherController!.clear();
                                  showAnimatedDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return CustomDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20), // <-- Radius
                                        ),
                                        child: Container(
                                          height: 200,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 20,),
                                              Container(
                                                child: Text('Add Voucher Code' ,textAlign: TextAlign.center,style: TextStyle(color: Colors.deepOrange,fontSize: 20,fontWeight: FontWeight.bold),),
                                              ),
                                              SizedBox(height: 20,),
                                              Form(
                                                key: _formKey,
                                                child: Container(
                                                  margin: EdgeInsets.only(left: 15,right: 15),
                                                  child: TextFormField(
                                                    autofocus: false,
                                                    controller: _voucherController,
                                                    validator: (v) {
                                                       if(v == "") {
                                                        return "Please enter a voucher code";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText: 'Voucher Code',
                                                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20,),
                                              Container(
                                               child: Row(
                                                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                 children: [
                                                   Container(
                                                     child: TextButton(
                                                       child: Text('Cancel',style: TextStyle(color: Colors.black),),
                                                       onPressed: () {
                                                         Navigator.pop(context);
                                                       },
                                                     ),
                                                   ),
                                                   Container(
                                                     child: TextButton(
                                                       child: Text('Submit',style : TextStyle(color: Colors.red)),
                                                       onPressed: () {
                                                         if (_formKey.currentState!.validate()) {
                                                           Navigator.pop(context);
                                                           var documentReference = FirebaseFirestore.instance
                                                               .collection('Requests').doc(widget.pubgId).collection("${widget.pubgId}").doc(snapshot.id);
                                                           FirebaseFirestore.instance.runTransaction((transaction) async {
                                                             transaction.update(documentReference, {
                                                               'status' : 1,
                                                               'voucherCode' : _voucherController!.text.trim(),
                                                             });
                                                           }).then((value) async {
                                                             var documentReference = FirebaseFirestore.instance
                                                                 .collection('Users')
                                                                 .doc(widget.pubgId.toString());
                                                             DocumentSnapshot doc = await documentReference.get();
                                                             var data = doc.data();
                                                             FirebaseFirestore.instance.runTransaction((transaction) async {
                                                               transaction.update(documentReference, {
                                                                 'requests' : data!['requests'] > 0 ? data['requests'] - 1 : 0,
                                                               });
                                                             });
                                                           });
                                                         }
                                                       },
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                             )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    animationType: DialogTransitionType.scale,
                                    curve: Curves.fastOutSlowIn,
                                    duration: Duration(seconds: 1),
                                  );




                                }, child: Text('PayUC'))
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
