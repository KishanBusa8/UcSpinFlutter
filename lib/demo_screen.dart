import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
// import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:ntp/ntp.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:ucspin/Profile/profilePage.dart';
import 'package:ucspin/components/Admob.dart';
import 'package:ucspin/components/customWidgets.dart';

class DemoScreen extends StatefulWidget {
  @override
  _DemoScreenState createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  FlutterSecureStorage secureStorage = FlutterSecureStorage();

  int currentBalance = 0;
  StreamController<int> selected = StreamController<int>.broadcast();
  late int random = 9999999999;
  bool showResult = false;
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  TextEditingController?  _nameController =  TextEditingController();
  TextEditingController?  _emailController =  TextEditingController();
  late ConfettiController _controllerCenter;
  final interstitialAd = InterstitialAd(unitId: AdMob().getInterstitialAdUnitId());
  final interstitialVideoAd = InterstitialAd()
    ..load(unitId: AdMob().getVideoAdUnitId());

  final rewardedAd = RewardedAd(unitId: AdMob().getRewardBasedVideoAdUnitId())..load();

  final AppOpenAd appOpenAd = AppOpenAd()..load();
  final rewardedInterstitial = RewardedInterstitialAd(unitId: AdMob().getRewardBasedVideoAdUnitId())..load();
  var pubgId;
  int totalSpin = 0;
  AdMob adMob = AdMob();


   double height = 20.0;
   double width = 20.0;
   bool getFreeUc = false;
   bool dailyReward = false;
   bool isSpin = false;



  @override
  void dispose() {
    // bannerController.dispose();
    _controllerCenter.dispose();
    selected.close();
    super.dispose();
  }

  @override
  void initState() {
    if (!interstitialVideoAd.isLoaded) interstitialVideoAd.load();
    interstitialVideoAd.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case FullScreenAdEvent.closed:
          if (getFreeUc) {
            getFreeUcSPin();
          }
          if (dailyReward) {
            getDailyReward();
          }
          if (isSpin) {
            onSpin();
          }
        // Here is a handy place to load a new interstitial after displaying the previous one
          interstitialVideoAd.load();
          // Do not show an ad here
          break;
        default:
          break;
      }
    });
    appOpenAd.onEvent.listen((e) => print(e));

    rewardedAd.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case RewardedAdEvent.closed:
        // Here is a handy place to load a new interstitial after displaying the previous one
          rewardedAd.load();
          // Do not show an ad here
          break;
        default:
          break;
      }    });
    rewardedInterstitial.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case RewardedAdEvent.closed:
        // Here is a handy place to load a new interstitial after displaying the previous one
          if (getFreeUc) {
            getFreeUcSPin();
          }
          if (dailyReward) {
            getDailyReward();
          }
          if (isSpin) {
            onSpin();
          }
          rewardedInterstitial.load();
          // Do not show an ad here
          break;
        default:
          break;
      }
    });

    _controllerCenter = ConfettiController(duration: const Duration(seconds: 2));
    Future.delayed(Duration(milliseconds: 200) , () {
      height = 300;
      width = 300;
      setState(() {

      });
    });
    getData();
    super.initState();
  }

  getData() async {
    await secureStorage.write(key: 'app', value: 'user');
    var user = await secureStorage.read(key: 'user');
      pubgId = jsonDecode(user!)['pubgId'];
    var documentReference = FirebaseFirestore.instance
        .collection('Users')
        .doc(pubgId);
    DocumentSnapshot documentSnapshot = await documentReference.get();

    var data2 = documentSnapshot.data();
    if (data2!['dailySpin'] != null) {
      totalSpin = data2['dailySpin'];
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
      totalSpin = 10;
    }
    setState(() {
    });
    if (data2['name'] == '') {
      _editProfileDialog();
    }
  }
  void _editProfileDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child:  AlertDialog(
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
                            "Please add your Info",
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
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ));
        });
  }


  List items = [
    {'text' : 'egg' , 'color' : Colors.black45},
    {'text' : '1' , 'color' : Colors.red},
    {'text' : '3' , 'color' : Colors.green},
    {'text' : 'egg' , 'color' : Colors.black45},
    {'text' : '5' , 'color' : Colors.blue},
    {'text' : '7' , 'color' : Colors.red},
    {'text' : 'egg' , 'color' : Colors.black45},
    {'text' : '9' , 'color' : Colors.green},
    {'text' : '10' , 'color' : Colors.blue},

  ];





  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: Container(child:BannerAd(
          unitId: adMob.getBannerAdUnitId(),
          builder: (context, child) {
            return Container(
              color: Colors.black,
              child: child,
            );
          },
          loading: Text('loading'),
          error: Text('error'),
          size: BannerSize.ADAPTIVE,
        ),),
        body: Container(
          color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
            ShowUpAnimation(
            delayStart: Duration(milliseconds: 100),
          animationDuration: Duration(milliseconds: 800),
          curve: Curves.decelerate,
          direction: Direction.vertical,
          offset: -0.9,
          child: Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 20,bottom: 30),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    icon: Icon(Icons.account_circle,size: 40,),
                    color: Colors.white,
                  ),
                ),
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
                      ShowUpAnimation(
                          delayStart: Duration(milliseconds: 100),
                          animationDuration: Duration(milliseconds: 800),
                          curve: Curves.decelerate,
                          direction: Direction.horizontal,
                          offset: -0.9,
                          child:  Container(
                          margin: EdgeInsets.only(left: 20,top: 0),
                          child:Column(children:[
                            Container(
                              margin: EdgeInsets.only(bottom: 0),
                              child: Text(
                                'Current balance: ${data['currentUC']} Coins',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 22
                                ),
                              ),
                            ),
                          ])
                      )) : Container();}) : Container(),
          ShowUpAnimation(
            delayStart: Duration(milliseconds: 100),
            animationDuration: Duration(milliseconds: 800),
            curve: Curves.decelerate,
            direction: Direction.horizontal,
            offset: 0.9,
            child:
                Container(
                    margin: EdgeInsets.only(top: 10,right: 30),
                    width: MediaQuery.of(context).size.width,
                    child:Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children:[
                      Container(
                        margin: EdgeInsets.only(bottom: 0),
                        child: Text(
                          'spin left : $totalSpin',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16
                          ),
                        ),
                      ),
                    ])
                ),
                ),
                SizedBox(height: 5,),
                Divider(color: Colors.white,),
                ShowUpAnimation(
                  delayStart: Duration(milliseconds: 500),
                  animationDuration: Duration(milliseconds: 800),
                  curve: Curves.decelerate,
                  direction: Direction.horizontal,
                  offset: 0.9,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: ElevatedButton(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.celebration,color: Colors.black,),
                                  SizedBox(width: 10,),
                                  Text('Get Free Spin',style: TextStyle(color: Colors.black),)
                                ],
                              ),
                              onPressed: () async {
                                getFreeUc = true;
                                if (!interstitialVideoAd.isAvailable)
                                  await interstitialVideoAd.load(
                                    unitId: AdMob().getVideoAdUnitId(),
                                  );
                                if (interstitialVideoAd.isAvailable) {
                                  await interstitialVideoAd.show();
                                  interstitialVideoAd.load(
                                    unitId: AdMob().getVideoAdUnitId(),
                                  );
                                }
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
                        ),
                        ElevatedButton(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.celebration,color: Colors.black,),
                                SizedBox(width: 10,),
                                Text('DAILY REWARD',style: TextStyle(color: Colors.black),)
                              ],
                            ),
                            onPressed: () async {
                              dailyReward = true;
                              if (!rewardedInterstitial.isAvailable)
                                await rewardedInterstitial.load();
                              await rewardedInterstitial.show();
                              rewardedInterstitial.load();
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

                SizedBox(height: 80,),
                    GestureDetector(
                      onTap: () async {

                          isSpin = true;
                          if (!interstitialVideoAd.isAvailable)
                            await interstitialVideoAd.load(
                              unitId: MobileAds.interstitialAdVideoTestUnitId,
                            );
                          if (interstitialVideoAd.isAvailable) {
                            await interstitialVideoAd.show();
                            interstitialVideoAd.load(
                              unitId: MobileAds.interstitialAdVideoTestUnitId,
                            );
                          }



                      },
                      onHorizontalDragEnd: (details) async {

                          isSpin = true;
                          if (!interstitialVideoAd.isAvailable)
                            await interstitialVideoAd.load(
                              unitId: MobileAds.interstitialAdVideoTestUnitId,
                            );
                          if (interstitialVideoAd.isAvailable) {
                            await interstitialVideoAd.show();
                            interstitialVideoAd.load(
                              unitId: MobileAds.interstitialAdVideoTestUnitId,
                            );
                          }

                    },
                      onVerticalDragEnd: (details) async {

                          isSpin = true;
                          if (!interstitialVideoAd.isAvailable)
                            await interstitialVideoAd.load(
                              unitId: MobileAds.interstitialAdVideoTestUnitId,
                            );
                          if (interstitialVideoAd.isAvailable) {
                            await interstitialVideoAd.show();
                            interstitialVideoAd.load(
                              unitId: MobileAds.interstitialAdVideoTestUnitId,
                            );
                          }

                      },
                      behavior: HitTestBehavior.translucent,
                      child:
                      AnimatedContainer(
                        padding: EdgeInsets.all(5),
                        duration: Duration(milliseconds: 500),
                        decoration :BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amberAccent.withOpacity(0.7),
                              spreadRadius: 5,
                              blurRadius: 100,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        width: width,
                        height: height,
                        child: FortuneWheel(
                          selected: selected.stream,
                          duration: Duration(seconds: 8),
                          onFling: () {},
                          animateFirst: false,
                          curve: Curves.linearToEaseOut,
                          rotationCount: 18,
                          styleStrategy: AlternatingStyleStrategy(),
                          onAnimationEnd: () async {
                           showResult = true;
                           totalSpin = totalSpin - 1;
                           DateTime startDate = await NTP.now();
                           var documentReference = FirebaseFirestore.instance
                               .collection('Users')
                               .doc(pubgId);
                           FirebaseFirestore.instance.runTransaction((transaction) async {
                             transaction.update(
                               documentReference,
                               {
                                 'dailySpin' : totalSpin,
                                 'spinUpdatedTime': startDate.millisecondsSinceEpoch.toString(),
                               },
                             );
                           });
                           if (items[random]['text'] != 'egg') {
                             _controllerCenter.play();
                             DocumentSnapshot documentSnapshot = await documentReference.get();
                             var data = documentSnapshot.data();
                             var uc =  data!['currentUC'] + int.parse(items[random]['text']);
                             FirebaseFirestore.instance.runTransaction((transaction) async {
                               transaction.update(documentReference, {
                                 'currentUC' : uc,
                               });
                             });
                           }
                           isSpin = false;
                           setState(() {});                            },

                          indicators: [
                            FortuneIndicator(
                                child: Image.asset(
                                  'assets/indicator.png',
                                  height: 50,
                                  color: Colors.black,
                                )),
                          ],
                          items: List.generate(items.length, (index) => FortuneItem(

                              child: items[index]['text'] == 'egg' ? Container(
                                height: 50,
                                width: 50,
                                margin: EdgeInsets.only(left: 30),
                                alignment: Alignment.center,
                                child: Image.asset('assets/egg.png'),
                              ) :  Container(
                                margin: EdgeInsets.only(left: 30),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white,width: 5),
                                    color: Colors.red.withOpacity(0.5)),

                                child: Text(
                                  items[index]['text'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              style: FortuneItemStyle(color: items[index]['color'],borderColor: Colors.white,)
                          ),),
                        ),
                      ),
                    ),

                SizedBox(height: 70),
                showResult ? items[random]['text'] == 'egg' ? Container(child: Text('Opps! Try Again',style:TextStyle(
                  fontSize: 22.0,
                  color: Colors.white,
                  fontFamily: 'Horizon',
                ),),) :  AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                   "Congrats, You have won ${items[random]['text'].toString()} Coins!",
                      textStyle: TextStyle(
                        fontSize: 22.0,
                        fontFamily: 'Horizon',
                      ),
                      colors: [
                        Colors.purple,
                        Colors.blue,
                        Colors.yellow,
                        Colors.red,
                      ],
                    ),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                  onTap: () {
                    print("Tap Event");
                  },
                ) : Container(),

                Align(
                  alignment: Alignment.bottomCenter,
                  child:  ConfettiWidget(
                    confettiController: _controllerCenter,
                    blastDirectionality: BlastDirectionality.directional,
                    blastDirection: -pi / 2,
                    particleDrag: 0.03,
                    emissionFrequency: 0.03,
                    numberOfParticles: 50,
                    gravity: 0.03,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ], // manually specify the colors to be used
                  ),
                ),


              ],
          ),
        ),
      ),
    );
  }


  getFreeUcSPin() async  {
    getFreeUc = true;
    var documentReference = FirebaseFirestore.instance
        .collection('Users')
        .doc(pubgId);
    DateTime startDate = await NTP.now();
    DocumentSnapshot documentSnapshot = await documentReference.get();
    var data = documentSnapshot.data();
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(
        documentReference,
        {
          'dailySpin' : data!['dailySpin'] + 1,
          'spinUpdatedTime': startDate.millisecondsSinceEpoch.toString(),
        },
      );
    }).then((value) {
      totalSpin = totalSpin + 1;
      getFreeUc = false;
      setState(() {
      });
    });
  }

  getDailyReward() async {
    DateTime startDate = await NTP.now();

    if (await secureStorage.read(key: 'bonusTime') != null) {
      var last = await secureStorage.read(key: 'bonusTime');
      DateTime lastTime =  DateTime.parse(last!);
      await secureStorage.write(key: 'currentTime', value: startDate.toString());
      var dif = startDate.difference(lastTime).inDays;
      if (dif > 0) {
        await secureStorage.write(key: 'bonusTime', value: startDate.toString());
        showAnimatedDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return CustomDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // <-- Radius
              ),
              child: Container(
                height: 220,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Image.asset('assets/giphy.gif'),
                      height: 150,
                      width: 150,
                    ),
                    Container(
                      child: Text('Congratulations\nYou have won 10 Coins' ,textAlign: TextAlign.center,style: TextStyle(color: Colors.deepOrange,fontSize: 18,fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ),
            );
          },
          animationType: DialogTransitionType.scale,
          curve: Curves.fastOutSlowIn,
          duration: Duration(seconds: 1),
        );
        var documentReference = FirebaseFirestore.instance
            .collection('Users')
            .doc(pubgId);
        DocumentSnapshot documentSnapshot = await documentReference.get();
        var data = documentSnapshot.data();
        var uc =  data!['currentUC'] + 10;
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(documentReference, {
            'currentUC' : uc,
          });
        });
        dailyReward= false;
      } else {
        dailyReward= false;
        Fluttertoast.showToast(msg: 'Opps! sorry come tomorrow');
      }
    } else {
      await secureStorage.write(key: 'bonusTime', value: startDate.toString());
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CustomDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // <-- Radius
            ),
            child: Container(
              height: 220,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Image.asset('assets/giphy.gif'),
                    height: 150,
                    width: 150,
                  ),
                  Container(
                    child: Text('Congratulations\nYou have won 10 Coins' ,textAlign: TextAlign.center,style: TextStyle(color: Colors.deepOrange,fontSize: 18,fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ),
          );

        },
        animationType: DialogTransitionType.scale,
        curve: Curves.fastOutSlowIn,
        duration: Duration(seconds: 1),
      );
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(pubgId);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      var data = documentSnapshot.data();
      var uc =  data!['currentUC'] + 10;
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(documentReference, {
          'currentUC' : uc,
        });
      });
      dailyReward= false;
    }
  }

  onSpin() async {
    if (totalSpin > 0) {
      showResult = false;
      random = Random().nextInt(totalSpin < 4 ? items.length : totalSpin < 7 ? 8 : 7);
      setState(() {
        selected.add(random);
      });
    }
    if (totalSpin == 0) {
      Fluttertoast.showToast(msg: "Opps! You don't have any other spin left");
    }
  }

  Container _getWheelContentCircle(Color backgroundColor, String text) {
    return Container(
      width: 72,
      height: 72,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 4
          )
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}