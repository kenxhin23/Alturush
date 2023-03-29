// import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';
import 'db_helper.dart';
// import 'package:flutter_map/flutter_map.dart';
// import "package:latlong/latlong.dart" as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:arush/chat/chat.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewOrderStatus extends StatefulWidget {
  final ticketId;
  ViewOrderStatus({Key key, @required this.ticketId}) : super(key: key);
  @override
  _ViewOrderStatus createState() => _ViewOrderStatus();
}

class _ViewOrderStatus extends State<ViewOrderStatus>{
  final db = RapidA();
  List riderList = [];
  Position position;
  var lat;
  var long;
  bool _isGettingLocation = true;
  double currentZoom = 13.0;
  // MapController mapController = MapController();
  String firstName = "";
  String lastName = "";
  String motorBrand = "";
  String motorDesc = "";
  String riderPhoto = "";
  String riderVehiclePhoto = "";
  String riderPlateNo = "";
  String riderMobileNo = "";
  String riderId = "";
  String deliveredStatus ="";

  //FOR EMAIL


  //FOR ANY URL.. YOU CAN PASS DIRECT URL..


  Future loadRiderPage() async{
    _isGettingLocation = true;
    var res = await db.loadRiderPage(widget.ticketId);
    if (!mounted) return;
    setState(() {
      _isGettingLocation = false;
      riderList = res['user_details'];
      firstName = riderList[0]['r_firstname'];
      lastName = riderList[0]['r_lastname'];
      motorBrand = riderList[0]['rm_brand'];
      motorDesc = riderList[0]['rm_color'];
      riderPhoto = riderList[0]['r_picture'];
      riderVehiclePhoto = riderList[0]['rm_picture'];
      riderPlateNo = riderList[0]['rm_plate_no'];
      riderMobileNo = riderList[0]['rm_mobile_no'];
      riderId = riderList[0]['rm_id'];
      deliveredStatus = riderList[0]['delivered_status'];

      print(widget.ticketId);

    });
  }

  _launchURL() async {
    const url = 'https://www.messenger.com/t/101910838142904';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makeSocialMediaRequest(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // void _zoomOut() async{
  //   try {
  //     Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     lat = position.latitude;
  //     long = position.longitude;
  //     var newLatLang = latLng.LatLng(lat,long);
  //     currentZoom = currentZoom - 1;
  //     mapController.move(newLatLang, currentZoom);
  //   }
  //   on PlatformException catch (e) {
  //       print(e);
  //   }
  // }

  // void _zoomIn() async{
  //   try {
  //     Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     lat = position.latitude;
  //     long = position.longitude;
  //     var newLatLang = latLng.LatLng(lat,long);
  //     currentZoom = currentZoom + 1;
  //     mapController.move(newLatLang, currentZoom);
  //   }
  //   on PlatformException catch (e) {
  //     print(e);
  //   }
  // }

  // void locateYourLocation() async{
  //   try {
  //     Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //     if (!mounted) return;
  //     setState(() {
  //       lat = position.latitude;
  //       long = position.longitude;
  //       var newLatLang = latLng.LatLng(lat,long);
  //       double zoom = 15.0; //the zoom you want
  //       mapController.move(newLatLang,zoom);
  //     });
  //   } on PlatformException catch (e) {
  //     print(e);
  //   }
  //
  // }

//   void locateRiderLocation() async{
//     try {
//       if (!mounted) return;
//       setState(() {
// //        lat = position.latitude;
// //        long = position.longitude;
//         //get
//         var newLatLang = latLng.LatLng(9.647111411110227, 123.86350931891319);
//         double zoom = 15.0; //the zoom you want
//         mapController.move(newLatLang,zoom);
//       });
//     }
//     on PlatformException catch (e) {
//       print(e);
//     }
//
//   }

//  void getUserLocation() async{
//    try {
//      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
//      position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
//      if (!mounted) return;
//      setState(() {
//        lat = position.latitude;
//        long = position.longitude;
//        _isGettingLocation = false;
//      });
//    } on PlatformException catch (e) {
//      print(e);
////      return null;
//    }
//  }

  Future onRefresh() async {
    loadRiderPage();
  }

  @override
  void initState() {
//    getUserLocation();
    onRefresh();
    loadRiderPage();
    super.initState();
  }
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrangeAccent, // Status bar
          statusBarIconBrightness: Brightness.light ,  // Only honored in Android M and above
        ),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.white, size: 20,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Rider detail",
          style: GoogleFonts.openSans(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        // actions: [
        //   IconButton(
        //       icon: Icon(Icons.chat_bubble, color: Colors.black54),
        //       onPressed: () {
        //
        //       }
        //   ),
        // ],
      ),
      body:_isGettingLocation ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ) : RefreshIndicator(
        onRefresh: onRefresh,
        child: Scrollbar(
          child: ListView(
            children: [

              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: Column(
                  crossAxisAlignment:CrossAxisAlignment.start,
                    children: [

                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: CachedNetworkImage(
                            imageUrl: riderPhoto,
                            imageBuilder: (context, imageProvider) => Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const CircularProgressIndicator(color: Colors.grey),
                            errorWidget: (context, url, error) => Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage("assets/jpg/no_photo.jpg"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Center(
                        child: Text("$firstName $lastName",
                          style: GoogleFonts.openSans(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 16.0),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
                            child:OutlinedButton.icon(
                              icon: Icon(Icons.phone,color: Colors.green,),
                              style: TextButton.styleFrom(
                                primary: Colors.black,
                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                              ),
                              onPressed: () async {

                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                String username = prefs.getString('s_customerId');
                                if(username == null){
                                  await Navigator.of(context).push(_signIn());
                                } else {
                                  launch("tel://$riderMobileNo");
                                }

                              },
                              label:Text("Call rider",
                                style: GoogleFonts.openSans(color:Colors.black87, fontWeight: FontWeight.bold, fontSize: 15.0),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 15, 5),
                            child:OutlinedButton.icon(
                              icon: Icon(Icons.chat_bubble,color: Colors.blueAccent,),
                              style: TextButton.styleFrom(
                                primary: Colors.black,
                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                              ),
                              onPressed: () async {

                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                String username = prefs.getString('s_customerId');
                                if(username == null){
                                  await Navigator.of(context).push(_signIn());
                                } else {
                                  if (deliveredStatus == '1') {

                                  } else {
                                    Navigator.of(context).push(chatRoute(firstName,lastName,riderId,widget.ticketId));
                                  }
                                }
                              },
                              label:Text("Chat rider",
                                style: GoogleFonts.openSans(color:Colors.black87, fontWeight: FontWeight.bold, fontSize: 15.0),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Container(
                        height: 40,
                        color: Colors.grey[200],
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Text('Mobile Number(s)',
                              style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54),
                            ),
                          ),
                        ),
                      ),

                      Scrollbar(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: riderList == null ? 0 : riderList.length,
                          itemBuilder: (BuildContext context, int index) {
                            print(riderList[index]['rm_id']);
                            String number;
                            String status;
                            if (riderList[index]['rider_stat'] == '0') {
                              status = 'Sub-Rider :';
                              number = riderList[index]['rm_mobile_no'];
                            } else {
                              status = 'Main Rider :';
                              number = riderList[index]['rm_mobile_no'];
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('$status',
                                        style: GoogleFonts.openSans(color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 14.0),
                                      ),
                                      Text('$number',
                                        style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 14.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 5, bottom: 10),
                        child: SizedBox(
                          height: 30,
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Messenger link: ',
                                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14.0),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.white,
                                ),
                                onPressed: (){
                                  // _makeSocialMediaRequest("http://pratikbutani.com");
                                  _launchURL();
                                },
                                child: Text("m.me/alturush",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20, 10.0, 20, 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 0.0,
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.center,
                    children: [

                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: CachedNetworkImage(
                            imageUrl: riderVehiclePhoto,
                            imageBuilder: (context, imageProvider) => Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const CircularProgressIndicator(color: Colors.grey),
                            errorWidget: (context, url, error) => Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage("assets/png/No_image_available.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                            child: Text("Vehicle",
                              style: GoogleFonts.openSans(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 15.0),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                            child: Text("$motorBrand",
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                            child: Text("Plate No.",
                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 15.0),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                            child: Text("$riderPlateNo",
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            child:Text("Vehicle description",
                              style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 15.0),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            child:Text("$motorDesc",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 15.0),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Route chatRoute(firstName,lastName,riderId,ticketId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Chat(firstName:firstName,lastName:lastName,riderId:riderId,ticketId:ticketId),
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

Route _signIn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => CreateAccountSignIn(),
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