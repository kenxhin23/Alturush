import 'package:arush/homePage.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'electronicsAppliances.dart';
import 'grocery/groceryMain.dart';
import 'load_bu.dart';
import 'package:root_check/root_check.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Splash extends StatefulWidget {
  @override
  _Splash createState() => _Splash();
}

class _Splash extends State<Splash> with SingleTickerProviderStateMixin{
  final db = RapidA();
  List globalCat;
  List loadProfileData;
  List getVersion;

  var isLoading = true;
  var isVisible = true;
  var locationString;

  String firstName      ="";
  String profilePhoto   ="";
  String currentVersion ="";
  String dbVersion      ="";
  String changelog      ="";
  String version        ="";

  // void selectType(BuildContext context ,width ,height) async{
  //   getGlobalCat();
  //   showModalBottomSheet(
  //       isScrollControlled: true,
  //       isDismissible: true,
  //       context: context,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
  //       ),
  //       builder: (ctx) {
  //         return Container(
  //           height: MediaQuery.of(context).size.height/2.0,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children:[
  //               Padding(
  //                   padding: EdgeInsets.fromLTRB(12, 10, 10, 5),
  //                   child: Text("Please select",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),)
  //               ),
  //               Expanded(
  //                 child:Container(
  //                   height: 400.0, // Change as per your requirement
  //                   // width: 300.0, // Change as per your requirement
  //                   child: Scrollbar(
  //                     child: ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount:  globalCat == null ? 0 : globalCat.length,
  //                       itemBuilder: (BuildContext context, int index) {
  //                         return InkWell(
  //                           onTap: () {
  //                             Navigator.pop(context);
  //                             if(globalCat[index]['id'] == '1'){
  //                               Navigator.of(context).push(_foodRoute(globalCat[index]['id']));
  //                             }if(globalCat[index]['id'] == '2'){
  //                               Navigator.of(context).push(_groceryRoute(globalCat[index]['id']));
  //                             }if(globalCat[index]['id'] == '3'){
  //                               Navigator.of(context).push(_electronicsRoute(globalCat[index]['id']));
  //                             }if(globalCat[index]['id'] == '4') {
  //                               Navigator.of(context).push(_groceryRoute(globalCat[index]['id']));
  //                             }
  //                           },
  //                           child: ListTile(
  //                             leading: CircleAvatar(
  //                               backgroundColor: Colors.transparent,
  //                               child: Image.network(globalCat[index]['cat_picture']),
  //                             ),
  //                             title: Text(globalCat[index]['category'],style: TextStyle(color: Colors.black87,fontSize: 17,fontWeight: FontWeight.bold),),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

  Future initPlatformState() async {
    bool isRooted = await RootCheck.isRooted;
    if(isRooted == true){
      setState(() {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: (){
                return null;
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                ),
                title: Text("Notice"),
                contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                content: Container(
                  height:50.0, // Change as per your requirement
                  width: 100.0, // Change as per your requirement
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 13.0, 5.0),
                    child: Text("Sorry, Alturush will not work in rooted devices."),
                  )
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () async{
                      // Navigator.of(context).pop();
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      });
    }
  }

  // Future getGlobalCat() async{
  //   var res = await db.getGlobalCat();
  //   if (!mounted) return;
  //   setState(() {
  //     globalCat = res['user_details'];
  //   });
  // }

  Future getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;

    print("ang version kay $version");
  }

  Future loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status  = prefs.getString('s_status');
    if(status != null) {
      var res = await db.loadProfile();
      if (!mounted) return;
      setState(() {
        loadProfileData = res['user_details'];
        firstName = loadProfileData[0]['d_fname'];
        isLoading = false;
        isVisible = true;
      });
    } else {
      locationString = "Location";
      firstName = "";
      profilePhoto = "";
      isVisible = false;
      isLoading = false;
    }
  }

  Future checkVersion() async {
    var res = await db.checkVersion('alturush');
    if(!mounted) return;
    setState(() {
      getVersion = res['user_details'];
      dbVersion = getVersion[0]['version_code'];
      changelog = getVersion[0]['changelog'];
      print('ang db app version kay $dbVersion');
      print('Changelog: $changelog');
      isLoading = false;

      if (res != null) {
        if (dbVersion != version) {
          print('need update');
          CoolAlert.show(
            context: context,
            type: CoolAlertType.info,
            text: "New update: ver.$dbVersion \nChangelog: $changelog",
            confirmBtnColor: Colors.deepOrangeAccent,
            backgroundColor: Colors.deepOrangeAccent,
            barrierDismissible: false,
            showCancelBtn: true,
            confirmBtnText: "Update",
            onConfirmBtnTap: () async {
              Navigator.of(context).pop();
              print('go to update');
              _launchURL();
            },
            onCancelBtnTap: () async {
              print('no update');
              Navigator.of(context).pop();
            }
          );
        }
      }
    });
  }

  _launchURL() async {
    const url = 'https://play.google.com/store/apps/details?id=com.niones.arush&hl=en';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // getGlobalCat();
    loadProfile();
    initPlatformState();
    currentVersion = '1.0.4';
    checkVersion();
    getAppVersion();
    super.initState();
  }
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrange[400], // Status bar
          statusBarIconBrightness: Brightness.light ,  // Only honored in Android M and above
        ),
        iconTheme: new IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Colors.deepOrange, Colors.deepOrangeAccent]),
          ),
        ),
        elevation: 0,
      ),
      body:isLoading ?
      Center(
        child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange)),
      ) : 
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepOrange,
              Colors.deepOrange[200],
            ],
          ),
          color: Colors.white,
          image: DecorationImage(
            alignment: Alignment(1, -0.5),
            image: AssetImage("assets/png/logo_raider8.png"),
            fit: BoxFit.contain
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                // shrinkWrap: true,
                children: <Widget>[
                SizedBox(height: height-400),

                  SizedBox(
                    height: 200,
                    width: 30.0,
                    child: Carousel(
                      images: [

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            SizedBox(height: 40.0),
                            Text("Welcome to Alturush",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            SizedBox(height: 40.0),
                            Text("Choose a restaurant",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            SizedBox(height: 40.0),
                            Text("Order online",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            SizedBox(height: 40.0),
                            Text("Multi store for fixed delivery fee",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            SizedBox(height: 40.0),
                            Text("Fast delivery",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                      dotSize: 4.0,
                      dotSpacing: 15.0,
                      showIndicator: false,
                      dotColor: Colors.white,
                      indicatorBgPadding: 5.0,
                      dotBgColor: Colors.white,
                      borderRadius: true,
                    ),
                  ),
                ],
              ),
            ),

            Center(
              child:Padding(
                padding: EdgeInsets.fromLTRB(15.0,0.0, 15.0,10.0),
                child: SizedBox(
                  width: width-10,
                  height: 50.0,
                  child:  OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                      backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                      overlayColor: MaterialStateProperty.all(Colors.black12),
                      side: MaterialStateProperty.all(BorderSide(
                        color: Colors.deepOrange,
                        width: 1.0,
                        style: BorderStyle.solid),
                      ),
                    ),
                    onPressed: () async {
                       // selectType(context ,width, height);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Text("Get started",
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 20.0,
                        shadows: [
                          Shadow(
                            blurRadius: 1.0,
                            color: Colors.black54,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Route _foodRoute(_globalCatID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MyHomePage(globalCatID:_globalCatID),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route _groceryRoute(_groceryRoute) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GroceryMain(groceryRoute:_groceryRoute),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
Route _electronicsRoute(_electronicsRoute) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ElectronicsApp(electronicsRoute:_electronicsRoute),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
