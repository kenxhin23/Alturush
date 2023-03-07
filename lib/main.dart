import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'db_helper.dart';
import 'splashScreen.dart';

void main(){
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp>{

  final db = RapidA();
  List getVersion;
  String currentVersion;
  Timer _timerSession;
  void handleUserInteraction([_]) {
    _initializeTimer();
    _checkInternet(context);
  }

  _checkInternet(context) async{
    bool isConnected = await SimpleConnectionChecker.isConnectedToInternet();
    if(!isConnected){
      Fluttertoast.showToast(
          msg: "Please check your internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
      );
    }
  }

  _logOutUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _initializeTimer() {
    if (_timerSession != null) {
      _timerSession.cancel();
    }
   _timerSession = Timer(const Duration(minutes: 30), _logOutUser);
    // print(_timerSession);
  }

  Future checkVersion() async {
    var res = await db.checkVersion('alturush');
    if(!mounted) return;
    setState(() {
      getVersion = res['user_details'];
    });
  }

  @override
  void initState(){
    // _logOutUser();
    _initializeTimer();
    currentVersion = '1.0.4';
    checkVersion();
    // print(_timerSession);
    // print('timer on');
    super.initState();
  }

  @override
  void dispose(){
    _logOutUser();
    print('logout');
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: handleUserInteraction,
      onPanDown: handleUserInteraction,
      onScaleStart: handleUserInteraction,
      child: MaterialApp(
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          final scale = mediaQueryData.textScaleFactor.clamp(0.8, 1.0);
          return MediaQuery(
            child: child,
            data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
          );
        },

          debugShowCheckedModeBanner: false,
          theme: ThemeData(

          // Define the default brightness and colors.
//        brightness: Brightness.dark,
//        primaryColor: Colors.lightBlue[800],
          accentColor: Colors.grey.withOpacity(0.2),
          ),

        title: 'Alturush',
        home: Splash(),
      ),
    );

  }
}





