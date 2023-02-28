import 'package:arush/profile/profile.dart';
import 'package:arush/track_order.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'homePage.dart';
import 'profile/accountSettings.dart';
import 'profile/addressMasterFile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'create_account_signin.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final db = RapidA();
  final picker = ImagePicker();
  File _image;

  List listCounter;
  List listProfile = [];

  var cartCount;
  var isLoading = true;
  var cartLoading = true;
  var firstName = "";
  var profilePicture = "";
  var lastName = "";

  String newFileName;
  String dateJoined;
  String date;
  String date2;



  Future loadProfile() async{
    var res = await db.loadProfile();
    if (!mounted) return;
    setState(() {
      listProfile = res['user_details'];
      profilePicture =  listProfile[0]['d_photo'];
      firstName = listProfile[0]['d_fname'];
      lastName = listProfile[0]['d_lname'];
      dateJoined = listProfile[0]['date_joined'];

      DateTime tag = DateFormat('yyyy-MM-dd hh:mm:ss').parse(dateJoined);
      date = DateFormat.yMMMMd().format(tag);
      isLoading = false;
      print(date);
    });
  }

  Future listenCartCount() async{
    var res = await db.getCounter();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      cartLoading = false;
      listCounter = res['user_details'];
      cartCount = listCounter[0]['num'];
    });
  }

  camera() async{
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        newFileName = _image.toString().split('/').last;
        print("picname: "+ newFileName);
        uploadId();
        Navigator.pop(context);
      }
    });
  }

  browseGallery() async{
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        newFileName = _image.toString();
        uploadId();
        Navigator.pop(context);
      }
    });
  }

  Future uploadId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
    }else{
      loading();
      String base64Image = base64Encode(_image.readAsBytesSync());
      await db.uploadProfilePic(base64Image);
      Navigator.of(context).pop();
      successMessage();
      loadProfile();
    }
  }

  successMessage(){
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Your profile picture has been changed successfully",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      onConfirmBtnTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String username = prefs.getString('s_customerId');
        if (username == null) {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
          // Navigator.of(context).push(_signIn());
        }
        if (username != null) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  loading(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height:50.0, // Change as per your requirement
            width: 10.0, // Change as per your requirement
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            ),
          ),
        );
      },
    );
  }

  void changeProfile(BuildContext context) async{
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height/7.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[

              Expanded(
                child:Container(
                  height: 400.0, // Change as per your requirement
                  // width: 300.0, // Change as per your requirement
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      InkWell(
                        onTap: (){
                          browseGallery();
                        },
                        child: Row(
                          children: [

                            Padding(
                                padding: EdgeInsets.fromLTRB(15, 15, 10, 15),
                                child: Text("Gallery",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),)
                            ),
                          ],
                        ),
                      ),

                      InkWell(
                        onTap: (){
                          camera();
                        },
                        child: Row(
                          children: [

                            Padding(
                                padding: EdgeInsets.fromLTRB(15, 15, 10, 15),
                                child: Text("Camera",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Future onRefresh() async {

    loadProfile();
  }

  @override
  void initState() {
    onRefresh();
    loadProfile();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, () {
          setState(() {});
        });
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.deepOrangeAccent[200], // Status bar
          ),
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Account Profile",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0),),
        ),
        body: isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) :
        ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage('https://alturush.com/images/ALTURUSH/Alturush%20no%20express.png',),
                        fit:BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        colorFilter: ColorFilter.mode(Colors.black54.withOpacity(0.6), BlendMode.dstATop),
                      ),
                    ),
                    child: Card(
                      margin: const EdgeInsets.all(0),
                      elevation: 0.0,
                      color: Colors.grey.withOpacity(.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      shadowColor: Colors.grey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: new Stack(
                              fit: StackFit.loose,
                              children: <Widget>[

                                new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[

                                    CachedNetworkImage(
                                      imageUrl: profilePicture,
                                      imageBuilder: (context, imageProvider) => Container(
                                        height: 130,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          color: Colors.white,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) => const CircularProgressIndicator(color: Colors.deepOrangeAccent,),
                                      errorWidget: (context, url, error) => Container(
                                        height: 130,
                                        width: 130,
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
                                  ],
                                ),

                                Padding(
                                  padding: EdgeInsets.only(top: 90.0, right: 95.0),
                                  child: new Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          changeProfile(context);
                                        },
                                        child: new CircleAvatar(
                                          backgroundColor: Colors.white70,
                                          radius: 20.0,
                                          child: new Icon(
                                            Icons.edit_outlined,
                                            color: Colors.black87,
                                          ),
                                        )
                                      ),
                                    ],
                                  )
                                ),
                              ]
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 0.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text('$firstName $lastName', style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 18.0),),
                                Text('Joined $date', style: GoogleFonts.openSans(fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal, fontSize: 16.0),),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.0),

                        ],
                      ),
                    )
                  )
                ),

                Divider(thickness: 1, color: Colors.deepOrangeAccent),

                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 0.0),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(_trackOrder());
                    },
                    child: Card(
                      elevation: 0.0,
                      child: Padding(
                        padding: EdgeInsets.all(17),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.bag),
                            Text(" Orders History",style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 0.0),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(profileSettings());
                    },
                    child: Card(
                      elevation: 0.0,
                      child: Padding(
                        padding: EdgeInsets.all(17),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.person),
                            Text(" Profile",style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 0.0),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(addressMasterFileRoute());
                    },
                    child: Card(
                      elevation: 0.0,
                      child: Padding(
                        padding: EdgeInsets.all(17),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.map),
                            Text(" Addresses",style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 0.0),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(accountSettings());
                    },
                    child: Card(
                      elevation: 0.0,
                      child: Padding(
                        padding: EdgeInsets.all(17),
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined),
                            Text(" Account Settings",style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 10.0),
                  child: InkWell(
                    onTap: () async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.clear();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).push(_homepage());
                    },
                    child: Card(
                      elevation: 0.0,
                      child: Padding(
                        padding: EdgeInsets.all(17),
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            Text(" Log out",style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Route _homepage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
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

Route profileSettings() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ProfileSettings(),
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

Route accountSettings() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AccountSettings(),
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

Route addressMasterFileRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AddressMasterFile(),
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

Route _trackOrder() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TrackOrder(),
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
      var begin = Offset(0.0, 1.0);
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

