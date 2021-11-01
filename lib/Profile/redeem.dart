import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:facebook_audience_network/ad/ad_rewarded.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:ucspin/components/Admob.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart' as fb;


class RedeemPage extends StatefulWidget {
  RedeemPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _RedeemPageState createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
 int totalUc = 0;
 int requests = 0;
  String? pubgId;
  List withdrawalList = [60,300,360,600,960,1500,3000,6000];
  int? selectIndex;
  final bannerController = BannerAdController();

  final AppOpenAd appOpenAd = AppOpenAd()..load();
  final interstitialVideoAd = InterstitialAd()
    ..load(unitId: AdMob().getVideoAdUnitId());
  bool admobBanner = false;
  bool _isInterstitialAdLoaded = false;

  @override
  void initState() {
    _loadInterstitialAd();
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
    if (!interstitialVideoAd.isLoaded) interstitialVideoAd.load();
    interstitialVideoAd.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case FullScreenAdEvent.closed:
        // Here is a handy place to load a new interstitial after displaying the previous one

          interstitialVideoAd.load();
          // Do not show an ad here
          break;
        default:
          break;
      }
    });
    getData();
    super.initState();
  }

  getData () async {
    var rng = new Random();
    if (rng.nextInt(100) % 2 == 0) {
      if (!interstitialVideoAd.isAvailable) {
        await interstitialVideoAd.load(
          unitId: AdMob().getVideoAdUnitId(),
        );
        _showInterstitialAd();
      } else if (interstitialVideoAd.isAvailable){
        await interstitialVideoAd.show();
        interstitialVideoAd.load(
          unitId: AdMob().getVideoAdUnitId(),
        );
      }
    }
    var user = await secureStorage.read(key: 'user');
    print(user);
     pubgId = jsonDecode(user!)['pubgId'];
    DocumentSnapshot documentReference = await FirebaseFirestore.instance
        .collection('Users')
        .doc(pubgId).get();
    var document = documentReference.data();
    totalUc = document!['currentUC'];
    requests = document['requests'];
    setState(() {
    });
  }
  _showInterstitialAd() {
    if (_isInterstitialAdLoaded == true)
      FacebookRewardedVideoAd.showRewardedVideoAd();
    else
      print("Interstial Ad not yet loaded!");
  }

  void _loadInterstitialAd() {
    FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: AdMob().getPlacementId(), //"IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617" YOUR_PLACEMENT_ID
      listener: (result, value) {
        print(">> FAN > Interstitial Ad: $result --> $value");
        if (result == RewardedVideoAdResult.LOADED)
          _isInterstitialAdLoaded = true;

        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == RewardedVideoAdResult.VIDEO_CLOSED ||
            result == RewardedVideoAdResult.VIDEO_COMPLETE) {
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
        }
      },
    );
  }
  int convertCoinsIntoUc(int coins) {
     return coins * 750 ~/ 60;
  }
  int convertUcIntoCoins(int coins) {
    return coins * 60 ~/ 750;
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!interstitialVideoAd.isAvailable) {
              await interstitialVideoAd.load(
                unitId: AdMob().getVideoAdUnitId(),
              );
              _showInterstitialAd();
            } else if (interstitialVideoAd.isAvailable){
              await interstitialVideoAd.show();
              interstitialVideoAd.load(
                unitId: AdMob().getVideoAdUnitId(),
              );
            }
            int? index = await   showAnimatedDialog<int>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return ClassicListDialogWidget(
                  titleText: 'Choose your pack!',
                  listType: ListType.singleSelect,
                  dataList: List.generate(
                    withdrawalList.length,
                        (index) {
                      return ListDataModel(
                          name: '${int.parse(convertCoinsIntoUc(withdrawalList[index]).toString())} coins = ${withdrawalList[index]} UC', value: '$index');
                    },
                  ),
                  selectedIndex: selectIndex,
                );
              },
              animationType: DialogTransitionType.scale,
              curve: Curves.fastOutSlowIn,
              duration: Duration(seconds: 1),
            );
            selectIndex = index;


            if (selectIndex != null) {
              if (convertCoinsIntoUc(withdrawalList[index]) > totalUc) {
                Fluttertoast.showToast(msg: 'Insufficient balance!');
              } else {
                totalUc = totalUc - convertCoinsIntoUc(withdrawalList[index]);
                var documentReference = FirebaseFirestore.instance
                    .collection('Requests').doc(pubgId).collection(pubgId!).doc();
                FirebaseFirestore.instance.runTransaction((transaction) async {
                  transaction.set(documentReference, {
                    'requestedUc' : convertCoinsIntoUc(withdrawalList[index]),
                    'status' :  0,
                    'timeStamp' : DateTime.now().millisecondsSinceEpoch
                  });
                });
                var documentReference2 = FirebaseFirestore.instance
                    .collection('Users')
                    .doc(pubgId);
                FirebaseFirestore.instance.runTransaction((transaction) async {
                  transaction.update(documentReference2, {
                    'currentUC' : totalUc,
                    'requests' : requests + 1
                  });
                });
              }
            }
            
            print(withdrawalList[index]);
            setState(() {
            });
          },
          child: Icon(Icons.add,color: Colors.black,),
          backgroundColor: Colors.amberAccent,
        ),
        backgroundColor: Colors.black,
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 50),
                child: Text("Available Coins : $totalUc",style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.bold),),
              ),
              Flexible(child: pubgId == null ? Container() : FirestoreAnimatedList(
                query: FirebaseFirestore.instance
                    .collection('Requests').doc(pubgId).collection(pubgId!).orderBy('timeStamp',descending: true),
                emptyChild: Container(
                  child: Center(
                    child: Text('No more request available',style: TextStyle(color: Colors.white),),
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
                      contentPadding: EdgeInsets.only(top: 10,left: 20,right: 20),
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
                                  width: MediaQuery.of(context).size.width / 1.2,
                                  child: Text("Requested Coins : "+snapshot!.data()!['requestedUc'].toString() + " (${convertUcIntoCoins(snapshot.data()!['requestedUc'])} UC)",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.white),),
                                ),
                                snapshot.data()!['status'] == 1 ? Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text(snapshot.data()!['voucherCode'].toString(),style: TextStyle(color: Colors.white),),
                                      width: MediaQuery.of(context).size.width / 1.8,
                                      ),
                                     GestureDetector(
                                       onTap: () {
                                         Clipboard.setData(ClipboardData(text: snapshot.data()!['voucherCode'].toString()));
                                         Fluttertoast.showToast(msg: 'Copied');
                                       },
                                       behavior: HitTestBehavior.translucent,
                                       child:  Container(
                                         margin: EdgeInsets.only(left: 10),
                                         child: Icon(Icons.copy,color: Colors.teal,),
                                       ),
                                     ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text("Accepted",style: TextStyle(color: Colors.green),),
                                      )
                                    ],
                                  ),
                                ) : Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Text('Pending',style: TextStyle(color: Colors.red),),
                                )
                              ],
                            ),
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


class ListDataModel {
  ///Name
  String name;

  ///Value
  String value;

  ListDataModel({required this.name, required this.value});

  @override
  String toString() {
    return name;
  }
}