
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class CustomWidgets {


  static showInSnackBar(String value,String type,scaffoldKey) {
    scaffoldKey.currentState
        .showSnackBar(
        new SnackBar(
//              elevation: 6.0,
          backgroundColor: type == 'success' ? Colors.green : Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          duration: const Duration(milliseconds: 3000),
          content: new Text(value , style: TextStyle( fontSize: 15),),
          action: SnackBarAction(
            label: 'Ok',
            textColor: Colors.white,
            onPressed: () {
              scaffoldKey.currentState.hideCurrentSnackBar();
            },
          ),
        )
    );
  }
  static confirmationDialog(VoidCallback onPressedFirstButton,
      VoidCallback onPressedSecondButton, context,
      {String? title,
        String? firstButtonText,
        String? secondButtonText,
        double height = 90}) {
    showDialog(
        context: context,
        barrierColor: Colors.black26,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            content: WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      height: height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              title!,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    firstButtonText!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: onPressedFirstButton,
                                  color: Colors.red,
                                ),
                                margin: EdgeInsets.only(top: 10),
                              ),
                              Container(
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    secondButtonText!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: onPressedSecondButton,
                                  color: Colors.green,
                                ),
                                margin: EdgeInsets.only(top: 10),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          );
        });
  }

  static loader(contexts,{required bool show}) {

    if(show) {
      return showDialog(context: contexts,
        barrierColor: Colors.white54,
        builder: (BuildContext context) {
          return SpinKitDoubleBounce(duration: Duration(milliseconds: 800),color: Colors.red,);
        },
        barrierDismissible: false,
      );
    } else {
      return Navigator.pop(contexts);
    }


  }

}