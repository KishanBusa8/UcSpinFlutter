// import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:ucspin/initial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /// Make sure you add this line here, so the plugin can access the native side

  /// Make sure to initialize the MobileAds sdk. It returns a future
  /// that will be completed as soon as it initializes
  await MobileAds.initialize();
  // Admob.initialize();

  // var deviceInfo = DeviceInfoPlugin();
  // var androidDeviceInfo = await deviceInfo.androidInfo;
  // print("881D2952974C62FE3AE532A64667B30C ${androidDeviceInfo.}");
  // This is my device id. Ad yours here
  MobileAds.setTestDeviceIds(["881D2952974C62FE3AE532A64667B30C"]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FortuneWheel Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: "WorkSans",
      ),
      home: InitialPage()
    );
  }
}