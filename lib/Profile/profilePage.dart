import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:ucspin/Admin/adminLogin.dart';
import 'package:ucspin/Auth/loginPage.dart';
import 'package:ucspin/Profile/redeem.dart';
import 'package:ucspin/components/Admob.dart';
import 'package:ucspin/components/customWidgets.dart';
import 'package:ucspin/env.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart' as fb;



class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  TextEditingController?  _passwordController =  TextEditingController();
  TextEditingController?  _nameController =  TextEditingController();
  TextEditingController?  _emailController =  TextEditingController();
  TextEditingController?  _checkPasswordController =  TextEditingController();
  AdMob adMob = AdMob();
  bool admobBanner = false;
  final bannerController = BannerAdController();

  String? pubgId;
  @override
  void initState() {
    bannerController.onEvent.listen((e) {
      final event = e.keys.first;
      // final info = e.values.first;
      switch (event) {
        case BannerAdEvent.loaded:
          admobBanner = true;
          setState(() {
          });
          break;
        case BannerAdEvent.loadFailed:
          admobBanner = false;
          setState(() {
          });
          break;
        default:
          admobBanner = false;
          setState(() {
          });
          break;
      }
    });
    bannerController.load();
    getId();
    super.initState();
  }

  getId() async {
    var user = await secureStorage.read(key: 'user');
    print(user);
    pubgId = jsonDecode(user!)['pubgId'];
    setState(() {
    });
  }


  @override
  void dispose() {
    bannerController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        bottomNavigationBar: admobBanner ? Container(child:BannerAd(
          unitId: AdMob().getBannerAdUnitId(),
          controller: bannerController,
          builder: (context, child) {
            return Container(
              color: Colors.black,
              child: child,
            );
          },
          loading: Text('loading'),
          error: Text('error'),
          size: BannerSize.ADAPTIVE,
        ),) :  fb.FacebookBannerAd(
          placementId: AdMob().getFacebookBannerAd(),
          bannerSize: fb.BannerSize.MEDIUM_RECTANGLE,
          listener: (result, value) {
            switch (result) {
              case fb.BannerAdResult.ERROR:
                print("Error: $value");
                break;
              case fb.BannerAdResult.LOADED:
                print("Loaded: $value");
                break;
              case fb.BannerAdResult.CLICKED:
                print("Clicked: $value");
                break;
              case fb.BannerAdResult.LOGGING_IMPRESSION:
                print("Logging Impression: $value");
                break;
            }
          },
        ),
        body: SafeArea(
            child:Container(
              margin: EdgeInsets.only(top: 30),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Text(
                          'Account Info',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 25
                          ),
                        ),
                      ),
                      Container(
                          child: PopupMenuButton(
                              padding: EdgeInsets.zero,
                              color: Colors.white,
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 30,
                              ),
                              onSelected: (value) async {
                                if (value == 1) {
                                  _changePasswordDialog();
                                } else if (value ==2){
                                  CustomWidgets.confirmationDialog(() {
                                    Navigator.pop(context);
                                  }, () async {
                                    CustomWidgets.loader(context, show: true);
                                    await secureStorage.delete(key: 'user');
                                    var documentReference = FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(pubgId);
                                    FirebaseFirestore.instance.runTransaction((transaction) async {
                                      transaction.delete(documentReference);
                                    }).then((value) {
                                      CustomWidgets.loader(context, show: false);
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginScreen()),
                                              (route) => false
                                      );
                                    });
                                  }, context,firstButtonText: 'No',secondButtonText: 'Yes',height: 110,title: 'Are you sure you want to delete your account?');
                                } else if (value ==3) {
                                  await secureStorage.delete(key: 'user');
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => appMode == AppMode.app ? LoginScreen() : AdminLoginPage()),
                                    (route) => false
                                  );
                                } else if (value == 4) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RedeemPage()),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                    value: 4,
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Redeem your UC',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    )),
                                PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                         'Change password',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    )),
                                PopupMenuItem(
                                    value: 2,
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Delete account',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    )),
                                PopupMenuItem(
                                    value: 3,
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Logout',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ))


                              ])),
                    ],
                  ),

                 pubgId != null ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(pubgId)
                          .snapshots(),
                      builder: (context, snap) {
                        var data;
                        if (snap.hasData) {
                          data = snap.data;
                        }
                        return snap.hasData
                            ?
                        Container(
                          margin: EdgeInsets.only(left: 20,top: 30),
                          child:Column(children:[
                            Container(
                              margin: EdgeInsets.only(bottom: 30),
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(16)
                              ),
                              child: Text(
                                'Current balance: ${data['currentUC']} Coins',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text('PubgId',style: TextStyle(fontSize: 18,color: Colors.white),),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        child: Text('Name',style: TextStyle(fontSize: 18,color: Colors.white),),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        child: Text('Email',style: TextStyle(fontSize: 18,color: Colors.white),),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            child: Text('${data['pubgId']}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            child: Text(data['status'] == 0 ? 'Pending' : 'Verified',style: TextStyle(fontWeight: FontWeight.bold,color: data['status'] == 0 ? Colors.red : Colors.green),),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        child: Text('${data['name']}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        child: Text('${data['email']}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: TextButton(
                                onPressed: () async{
                                  _nameController!.text  = data['name'];
                                  _emailController!.text  = data['email'];
                                  _editProfileDialog();
                                },
                                child: Text('Edit Profile',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold,),),
                              ),
                            ),

                          ])
                        ) : Container();}) : Container(),


                  // Flexible(child: Container(
                  //   alignment: Alignment.bottomCenter,
                  //   child:BannerAd(
                  //   unitId: AdMob().getBannerAdUnitId(),
                  //   builder: (context, child) {
                  //     return Container(
                  //       color: Colors.black,
                  //       child: child,
                  //     );
                  //   },
                  //   loading: Text('loading'),
                  //   error: Text('error'),
                  //   size: BannerSize.ADAPTIVE,
                  // ),))

                ],
              ),
            )
        )
    );
  }
  void _editProfileDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10, right: 5, left: 5),
                  child: Form(
                    key: _formKey2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "Change your Info",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 100,
                          padding: EdgeInsets.only(left:2,bottom:5),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Name",
                            ),
                            controller: _nameController,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return "please enter your name";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 100,
                          padding: EdgeInsets.only(left:2,bottom:5),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Email",
                            ),
                            controller: _emailController,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return "please enter email";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey2.currentState!.validate()) {
                                CustomWidgets.loader(context, show: true);
                                var documentReference = FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(pubgId);
                                FirebaseFirestore.instance.runTransaction((transaction) async {
                                  transaction.update(documentReference, {
                                    'email' : _emailController?.text,
                                    'name' : _nameController?.text,
                                  });
                                }).then((value) {
                                  CustomWidgets.loader(context, show: false);
                                  Navigator.pop(context);
                                });
                              }


                            },
                            child: Text('Submit'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  child: Container(
                    child: GestureDetector(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.black,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  right: 0,
                  top: 0,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          );
        });
  }



  void _changePasswordDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10, right: 5, left: 5),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "Change your password",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 100,
                          padding: EdgeInsets.only(left:2,bottom:5),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "New password",
                            ),
                            controller: _passwordController,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return "please enter password";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 100,
                          padding: EdgeInsets.only(left:2,bottom:5),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Confirm password",
                            ),
                            controller: _checkPasswordController,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return "please enter confirm password";
                              }
                              if (value.trim() != _passwordController?.text) {
                                return "Password does not match";

                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                CustomWidgets.loader(context, show: true);
                                var documentReference = FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(pubgId);
                                FirebaseFirestore.instance.runTransaction((transaction) async {
                                  transaction.update(documentReference, {
                                    'password' : _passwordController?.text,
                                  });
                                }).then((value) {
                                  CustomWidgets.loader(context, show: false);
                                  Navigator.pop(context);
                                });
                              }


                            },
                            child: Text('Submit'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  child: Container(
                    child: GestureDetector(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.black,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  right: 0,
                  top: 0,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          );
        });
  }


}
