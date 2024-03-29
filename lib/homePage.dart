import 'dart:async';
import 'package:arush/profile_page.dart';
import 'package:arush/showDpn2.dart';
import 'package:arush/appQrCode.dart';
import 'package:arush/timerSample.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';
import 'db_helper.dart';
import 'discountManager.dart';
import 'global_cat.dart';
import 'load_cart.dart';
// import 'load_tenants.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = RapidA();
  final _formKey = GlobalKey<FormState>();
  List bUnits;
  List globalCat;

  final oCcy = new NumberFormat("#,##0.00", "en_US");

  final province = TextEditingController();
  final town = TextEditingController();
  List listCounter;
  List buData;
  List loadProfileData;
  List listSubtotal;
  List loadLocationData;
  List loadQuotesData;
  List listProfile;
  var isLoading = true;
  var isVisible = true;
  var login = true;
  var logout = true;
  var cartCount;
  var subtotal;
  var locationString;
  var cartLoading = true;
  var profileLoading = true;
  var profilePicture = "";
  String firstName ="";
  String lastName ="";
  String profilePhoto;
  String placeRemark;
  String quotes ="";
  String author ="";
  String status;
  int counter;
  int provinceId;
  int townID;

  bool showBadge;

  Future onRefresh() async {
    print('ni refresh na');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String username = prefs.getString('s_customerId');
    // if(username == null){
    //   Navigator.of(context).push(_signIn());
    // }
    loadProfile();
    loadProfilePic();
    futureLoadQuotes();
    listenCartCount();
    // getGlobalCat();
    // loadBu();
  }

  ///Get the list of Business Units
  Future loadBu() async{
    var res = await db.getBusinessUnits(unitGroupId.toString());
    if (!mounted) return;
    setState(() {
      buData = res['user_details'];
      print(buData);
    });
  }

  ///Get the global categories
  Future getGlobalCat() async{
    var res = await db.getGlobalCat();
    if (!mounted) return;
    setState(() {
      globalCat = res['user_details'];
    });
  }
  ///Load profile pic if uploaded
  Future loadProfilePic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
    if(status != null) {
      var res = await db.loadProfile();
      if (!mounted) return;
      setState(() {
        listProfile = res['user_details'];
        profilePicture = listProfile[0]['d_photo'];
        profileLoading = false;
      });
    }
  }

  ///Load qoutes
  Future futureLoadQuotes() async{
    var res = await db.futureLoadQuotes();
    if (!mounted) return;
    setState(() {
      quotes = res["content"];
      author = "-"+res["author"];
    });
  }

  ///Load profile
  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
    if(status != null) {
      var res = await db.loadProfile();
      if (!mounted) return;
      setState(() {
        loadProfileData = res['user_details'];
        firstName = loadProfileData[0]['d_fname'];
        lastName = loadProfileData[0]['d_lname'];
        isLoading = false;
        isVisible = true;
        logout = true;
      });
    } else {
      locationString = "Location";
      firstName = "";
      profilePhoto = "";
      isVisible = false;
      isLoading = false;
      logout = false;
    }
  }

  ///Get cart counter
  Future getCounter() async {
    var res = await db.getCounter();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      listCounter = res['user_details'];
    });
  }

  ///
  Future listenCartCount() async{
    var res = await db.getCounter();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      cartLoading = false;
      listCounter = res['user_details'];
      cartCount = listCounter[0]['num'];
      if (cartCount == 0) {
        showBadge = false;
      } else {
        showBadge = true;
      }
      // print(cartCount);
    });
  }

  ///Dialog for province list
  List getProvinceData;
  selectProvince() async{
    var res = await db.getProvince();
    if (!mounted) return;
    setState(() {
      getProvinceData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());

    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                ),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  padding: EdgeInsets.zero,
                  height: 165.0,
                  width: 300.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange[400],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15), topLeft: Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                              child: Text('Select Province',style: GoogleFonts.openSans(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            padding: EdgeInsets.all(0),
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: getProvinceData == null ? 0 : getProvinceData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap:(){
                                  province.text = getProvinceData[index]['prov_name'];
                                  provinceId = int.parse(getProvinceData[index]['prov_id']);
                                  town.clear();
                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15, top: 5),
                                      child: SizedBox(
                                        height: 30,
                                        child: Text(getProvinceData[index]['prov_name'],
                                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                        ),
                                      ),
                                    ),
                                    Divider(thickness: 2, color: Colors.grey[200]),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[

                  // Divider(thickness: 2, color: Colors.grey[200]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: SizedBox(
                          width: 100,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(color: Colors.deepOrangeAccent),
                                ),
                              ),
                            ),
                            child: Text('Close',
                              style: GoogleFonts.openSans(
                                color: Colors.deepOrange[400],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: SizedBox(
                          width: 100,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.deepOrange[400]),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(color: Colors.deepOrange[400]),
                                ),
                              ),
                            ),
                            child: Text(
                              'Clear',
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              province.clear();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {}) ;

  }

  ///Dialog for town list
  List getTownData;
  selectTown() async{
    var res = await db.selectTown(provinceId.toString());
    if (!mounted) return;
    setState(() {
      getTownData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());

    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))
              ),
              contentPadding: EdgeInsets.all(0),
              content: Container(
                height: 350.0,
                width: 300.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange[400],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15), topLeft: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                            child: Text('Select Town',style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),

                    Expanded(
                      child: Scrollbar(
                        child:ListView.builder(
                          padding: EdgeInsets.all(0),
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: getTownData == null ? 0 : getTownData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap:(){
                                town.text = getTownData[index]['town_name'];
                                townID = int.parse(getTownData[index]['town_id']);
                                unitGroupId = int.parse(getTownData[index]['bunit_group_id']);
                                print(unitGroupId);
                                Navigator.of(context).pop();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15, top: 10),
                                    child: SizedBox(
                                      height: 30,
                                      child: Text(getTownData[index]['town_name'],
                                        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    ),
                                  ),

                                  Divider(thickness: 2, color: Colors.grey[200]),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: 100,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(color: Colors.deepOrange[400]),
                              ),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange[400],
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: SizedBox(
                        width: 100,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.deepOrange[400]),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(color: Colors.deepOrange[400]),
                              ),
                            ),
                          ),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            town.clear();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {}
    );
  }

  @override
  void initState(){
    super.initState();
    print('dili mo load');
    loadProfilePic();
    loadProfile();
    onRefresh();
    futureLoadQuotes();
    listenCartCount();
  }



  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // getGlobalCat();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrangeAccent, // Status bar
          statusBarIconBrightness: Brightness.light ,  // Only honored in Android M and above
        ),
        backgroundColor: Colors.deepOrange[400],
        elevation: 0.1,
        iconTheme: new IconThemeData(color: Colors.white, size: 25,
          shadows: [
            Shadow(
              blurRadius: 1.0,
              color: Colors.black54,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
        ///Action buttons or menu on Appbar
        actions: <Widget>[
          status == null ? TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, disabledForegroundColor: Colors.red.withOpacity(0.38),
            ),
            onPressed: () async {
              // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
              await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
              listenCartCount();
              loadProfile();
              loadProfilePic();
            },
            child: Text("Login",style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 16.0),),
          ) :
          Padding(
            padding: EdgeInsets.all(0),
            child: InkWell(
              customBorder: CircleBorder(
              ),
              onTap: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString('s_customerId');
                if(username == null){
                  // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                  await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                  listenCartCount();
                  loadProfile();
                  loadProfilePic();
                }else{
                  // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new ProfilePage())).then((val)=>{onRefresh()});
                  await Navigator.of(context).push(profile()).then((val)=>{onRefresh()});
                  listenCartCount();
                  loadProfile();
                  loadProfilePic();
                }
              },
              child: Container(
                width: 50.0,
                height: 50.0,
                child: Padding(
                  padding:EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: profileLoading ? CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ) : CachedNetworkImage(
                    imageUrl: profilePicture,
                    imageBuilder: (context, imageProvider) => Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                    errorWidget: (context, url, error) => Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(30),
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
            )
          ),
          cartLoading
              ? Center(
            child:Container(
              height:16.0 ,
              width: 16.0,
              child: CircularProgressIndicator(
//                                          strokeWidth: 1,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ) :
          Badge(
            badgeColor: Colors.white,
            position: BadgePosition.topEnd(top: 5, end: 10),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.slide,
            showBadge: showBadge,
            badgeContent: Text('${cartCount.toString()}',
              style: TextStyle(color: Colors.deepOrange[300], fontSize: 11, fontWeight: FontWeight.bold),
            ),
            child: Padding(
              padding: EdgeInsets.only(right: 25),
              child: SizedBox(width: 25,
                child: IconButton(
                  icon: Icon(CupertinoIcons.cart),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String username = prefs.getString('s_customerId');
                    if(username == null){
                      // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                      await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                      getCounter();
                      listenCartCount();
                    }else{
                      await Navigator.of(context).push(_loadCart()).then((val)=>{onRefresh()});
                      getCounter();
                      listenCartCount();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
        // title: Text("Order Food",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   children: [
        //     Image.asset(
        //       'assets/png/alturush_text_logo.png',
        //       fit: BoxFit.contain,
        //       height: 30,
        //     ),
        //   ],
        // ),
      ),

      ///Navigation bar or drawer
      drawer: Container(
        width: 280,
        child: Drawer(
          child: Container(
            color: Colors.white,
            child:ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  child:Column(
                    children: <Widget>[
                      Container(
                        height: 200,
                        width: 280,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange[400],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            status == null ? Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 10, bottom: 10),
                                  child: Text("WELCOME",
                                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                                  ),
                                ),
                              ],
                            ) : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Center(
                                  child: CachedNetworkImage(
                                    imageUrl: profilePicture,
                                    imageBuilder: (context, imageProvider) => Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(100),
                                        color: Colors.white,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white,),
                                    errorWidget: (context, url, error) => Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
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
                                Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text("${firstName} ${lastName}",
                                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Column(
                      //  crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Image.asset(
                      //       'assets/png/alturush_text_logo.png',
                      //       fit: BoxFit.contain,
                      //       height: 50,
                      //     ),
                      //   ],
                      // ),


                      // Center(
                      //   child:Image.asset('assets/png/alturush_text_logo.png',height: 100.0,width: 100.0,),
                      // ),
                      // ListView.builder(
                      //
                      //     shrinkWrap: true,
                      //     physics: BouncingScrollPhysics(),
                      //     itemCount:  globalCat == null ? 0 : globalCat.length,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       return ListTile(
                      //
                      //           leading: CircleAvatar(
                      //             backgroundColor: Colors.transparent,
                      //             child: Image.network(globalCat[index]['cat_picture']),
                      //           ),
                      //           title: Text(globalCat[index]['category'],style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 16.0),),
                      //           onTap: () async{
                      //             Navigator.pop(context);
                      //             if(globalCat[index]['id'] == '1'){
                      //               Navigator.of(context).push(_foodRoute(globalCat[index]['id']));
                      //             }if(globalCat[index]['id'] == '2'){
                      //               Navigator.of(context).push(_groceryRoute(globalCat[index]['id']));
                      //             }if(globalCat[index]['id'] == '3'){
                      //               Navigator.of(context).push(_foodRoute(globalCat[index]['id']));
                      //             }
                      //           }
                      //       );
                      //     }
                      // ),


                      ListTile(
                          contentPadding: EdgeInsets.only(left: 10, top: 10),
                          leading: Icon(Icons.person,size: 30.0, color: Colors.deepOrange[400]),
                          title: Padding(
                            padding: EdgeInsets.all(0),
                            child: Text('Profile',
                              style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 16.0),
                            ),
                          ),
                          onTap: () async {

                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String status  = prefs.getString('s_status');

                            status != null ? await Navigator.of(context).push(profile()).then((val)=>{onRefresh()}) :  await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                            // await Navigator.of(context).push(_loadCart()).then((val)=>{onRefresh()});
                            getCounter();
                            listenCartCount();
                          }
                      ),

                      // Divider(color: Colors.black54),

                      ListTile(
                        contentPadding: EdgeInsets.only(left: 10, top: 10),
                        leading: Image.asset('assets/png/img_552316.png', color: Colors.deepOrange[400],
                        fit: BoxFit.contain,
                        height: 30,
                        width: 30,
                      ),
                        title: Text('Manage Discount',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 16.0),
                        ),
                        onTap: () async {

                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String username = prefs.getString('s_customerId');
                          if(username == null){
                            await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                            // await Navigator.of(context).push(_signIn());
                            getCounter();
                            listenCartCount();
                            loadProfile();
                            loadProfilePic();
                          }else{
                            await Navigator.of(context).push(_showDiscountPerson()).then((val)=>{onRefresh()});
                            getCounter();
                            listenCartCount();
                            loadProfile();
                            loadProfilePic();
                          }
                        }
                      ),

                      // Divider(color: Colors.black54),
                      //
                      // ListTile(
                      //   contentPadding: EdgeInsets.only(left: 10),
                      //   leading: Icon(Icons.mobile_screen_share,size: 30.0, color: Colors.deepOrange),
                      //   title: Padding(
                      //     padding: EdgeInsets.all(0),
                      //     child: Text('Share the app',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 16.0)),
                      //   ),
                      //   onTap: () async {
                      //     SharedPreferences prefs = await SharedPreferences.getInstance();
                      //     String username = prefs.getString('s_customerId');
                      //     if(username == null){
                      //       await Navigator.of(context).push(_signIn());
                      //       getCounter();
                      //       listenCartCount();
                      //       loadProfile();
                      //       loadProfilePic();
                      //     }else{
                      //       await Navigator.of(context).push(_showAppQrCode());
                      //       getCounter();
                      //       listenCartCount();
                      //       loadProfile();
                      //       loadProfilePic();
                      //     }
                      //   }
                      // ),

                      // Divider(color: Colors.black54),

                      ListTile(
                        contentPadding: EdgeInsets.only(left: 10, top: 10),
                        leading: Icon(Icons.info_outline,size: 30.0, color: Colors.deepOrange[400]),
                        title: Text('Data Privacy',
                          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 16.0),
                        ),
                        onTap: () async {
                          await Navigator.of(context).push(showDpn2()).then((val)=>{onRefresh()});
                        }
                      ),

                      Divider(thickness: 3, color: Colors.grey[200]),

                      Visibility(
                        visible: logout,
                        child: ListTile(
                          contentPadding: EdgeInsets.only(left: 10),
                          leading: Icon(Icons.logout ,size: 30.0,color: Colors.deepOrange[400]),
                          title: Text('Log out',
                            style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16.0)),
                          onTap: () async{
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).push(_homepage());
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),


      ///Loading screen
      body: isLoading ?
      Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ) :
      ///Content for main body or main widget same as activity page on native android
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              color: Colors.deepOrangeAccent,
              child: Scrollbar(
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    Container(
                      color: Colors.deepOrange[300],
                      child: SizedBox(height: 180,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            margin: const EdgeInsets.all(0),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                Row(
                                  children: [

                                    Column(
                                      children: [

                                        Padding(
                                          padding: EdgeInsets.fromLTRB(5.0, 15.0, 0, 5.0),
                                          child: Image.asset("assets/png/logo_raider8.2.png",
                                            fit: BoxFit.contain,
                                            height: 120,
                                            width: 120,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Expanded(
                                      child:Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(0.0, 20.0, 10, 5.0),
                                            child: Text('Alturush, offers affordable products for you, without any hidden charges.', maxLines: 3,
                                              overflow: TextOverflow.ellipsis, style: GoogleFonts.openSans(fontSize: 12),
                                            ),
                                          ),

                                          Padding(
                                            padding: EdgeInsets.fromLTRB(0, 20, 10, 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [

                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(0.0, 5.0, 0, 5.0),
                                                  child: Image.asset("assets/storesLogo/icm.png",
                                                    fit: BoxFit.fitHeight,
                                                    height: 40,
                                                    width: 40,
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 5.0),
                                                  child: Image.asset("assets/storesLogo/alturas_mall.png",
                                                    fit: BoxFit.fitHeight,
                                                    height: 40,
                                                    width: 40,
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 5.0),
                                                  child: Image.asset("assets/storesLogo/plaza_marcela.jpeg",
                                                    fit: BoxFit.contain,
                                                    height: 40,
                                                    width: 40,
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 5.0),
                                                  child: Image.asset("assets/storesLogo/altacita.jpeg",
                                                    fit: BoxFit.fitWidth,
                                                    height: 40,
                                                    width: 40,
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 5.0),
                                                  child: Image.asset("assets/storesLogo/alturas_talibon.png",
                                                    fit: BoxFit.contain,
                                                    height: 40,
                                                    width: 40,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Card(
                        elevation: 0.0,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                child: new Text("Select Province",
                                  style: GoogleFonts.openSans(fontSize: 16.0, color: Colors.black54, fontWeight: FontWeight.bold),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30.0),
                                  onTap: (){
                                    // debugPrint('${getProvinceData[1]['prov_name']}');
                                    selectProvince();
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
                                      style: GoogleFonts.openSans(fontSize: 15, color: Colors.black87),
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                                      controller: province,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a province';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepOrange.withOpacity(0.8),
                                              width: 2.0),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 5, 5),
                                child: new Text("Select town",
                                  style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, color: Colors.black54, fontWeight: FontWeight.bold),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onTap: (){
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    if(province.text.isEmpty){
                                      Fluttertoast.showToast(
                                        msg: "Please select a province",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: Colors.black.withOpacity(0.7),
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                    } else {
                                      selectTown();
                                    }
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
                                      style: GoogleFonts.openSans(fontSize: 15, color: Colors.black87),
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                                      controller:town,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a town';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepOrange.withOpacity(0.8),
                                              width: 2.0),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 10.0),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                    child: Container(
                                      height: 50.0,
                                      child: OutlinedButton(
                                        onPressed: (){
                                          if (_formKey.currentState.validate()) {
                                            // getGlobalCat();
                                            print(unitGroupId);
                                            loadBu();
                                            // print("business units: "); print(buData);
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white, backgroundColor: Colors.deepOrangeAccent,
                                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0)),
                                        ),
                                        child: Text("Go", style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10.0),

                            ],
                          ),
                        ),
                      ),
                    ),

                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: buData == null ? 0: buData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () async{

                            if (buData[index]['bunit_code'] != '5') {
                              await Navigator.of(context).push(_globalCat(
                                buData[index]['logo'],
                                buData[index]['business_unit'],
                                buData[index]['acroname'],
                                buData[index]['bunit_code'],
                                buData[index]['group_code'])).then((val)=>{onRefresh()});
                            } else {
                              print('ayaw kol');
                            }

                            getCounter();
                            listenCartCount();
                          },
                          child:Container(
                            height: 90.0,
                            width: 30.0,
                            child: Card(
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  ListTile(
                                    leading:Container(
                                      width: 55.0,
                                      height: 55.0,
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          image: new NetworkImage(buData[index]['logo']),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                        border: new Border.all(
                                          color: Colors.deepOrange[400],
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    title: Text(buData[index]['business_unit'],
                                      style: GoogleFonts.openSans(color: Colors.black54, fontStyle: FontStyle.normal, fontWeight:FontWeight.bold, fontSize: 18.0),
                                    ),
                                  ),
                                ],
                              ),
                              elevation: 0.0,
                              margin: EdgeInsets.all(3),
                            ),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

///Routes to other pages same as intent on native android
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

Route _homepage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
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


Route profile(){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
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

Route _showDiscountPerson() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => DiscountManager(),
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

Route _showAppQrCode() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => CountdownTimerDemo(),
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

Route _loadCart() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoadCart(),
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

Route _globalCat(buLogo, buName, buAcroname, buCode, groupCode) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GlobalCat(
        buLogo:buLogo,
        buName:buName,
        buAcroname:buAcroname,
        buCode:buCode,
        groupCode:groupCode),
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

Route showDpn2() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ShowDpn2(),
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

// Route _electronicsRoute(_electronicsRoute) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => ElectronicsApp(electronicsRoute:_electronicsRoute),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       var begin = Offset(0.0, 1.0);
//       var end = Offset.zero;
//       var curve = Curves.decelerate;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }




