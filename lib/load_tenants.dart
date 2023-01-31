import 'package:arush/profile_page.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'load_store.dart';
import 'db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'load_cart.dart';
import 'create_account_signin.dart';
import 'track_order.dart';
import 'package:sleek_button/sleek_button.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'search.dart';

class LoadTenants extends StatefulWidget {
  final globalID;
  final globalCat;
  final globalPic;
  final buCode;
  final buLogo;
  final buName;
  final buAcroname;

  LoadTenants({Key key, @required this.buLogo, this.buName, this.buCode, this.globalPic, this.globalCat,  this.globalID, this.buAcroname }) : super(key: key);
  @override
  _LoadTenants createState() => _LoadTenants();
}

class _LoadTenants extends State<LoadTenants> with TickerProviderStateMixin {
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = RapidA();
  List listProfile;
  List loadTenants;
  List listCounter;
  List globalCat;
  List listSubtotal;

  int gridCount;

  var isLoading = true;
  var cartLoading = true;
  var profileLoading = true;
  var subtotal;
  var cartCount;
  var profilePicture = "";

  bool showBadge;

  String image;

  AnimationController controller;

  void initController(){
    controller = BottomSheet.createAnimationController(this);
    // Animation duration for displaying the BottomSheet
    controller.duration = const Duration(milliseconds: 700);
    // Animation duration for retracting the BottomSheet
    controller.reverseDuration = const Duration(milliseconds: 500);
    // Set animation curve duration for the BottomSheet
    controller.drive(CurveTween(curve: Curves.easeIn));
  }

  Future loadTenant() async {
//    var res = await db.getTenants(widget.buCode);
    var res = await db.getTenantsCi(widget.buCode, widget.globalID);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadTenants = res['user_details'];
    });
  }

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

  Future getCounter() async {
    var res = await db.getCounter();
    if (!mounted) return;
    setState(() {
      cartLoading = false;
      listCounter = res['user_details'];
      cartCount = listCounter[0]['num'];

      if (cartCount == 0) {
        showBadge = false;
      } else {
        showBadge = true;
      }
    });
  }

  String status;
  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
  }

  void selectCategory(BuildContext context ,buCode, buAcroname, logo, tenantId, tenantName, globalID) async{
    List categoryData;
    var res = await db.selectCategory(tenantId);
    if (!mounted) return;
    setState(() {
      categoryData = res['user_details'];
    });
    showModalBottomSheet(
      transitionAnimationController: controller,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
      ),
      builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height/1.5,
            child: Scrollbar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 20.0, 20.0, 20.0),
                    child:Text("Category",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                  ),

                  Expanded(
                    child: ListView(
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[

                            ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: categoryData.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () async{
                                    print(buAcroname);
                                    if (index == 0) {
                                      await Navigator.of(context).push(_loadStore(
                                        'All items',
                                        categoryData[index]['category_id'],
                                        buCode,
                                        buAcroname,
                                        logo,
                                        tenantId,
                                        tenantName,
                                        globalID));
                                      getCounter();
                                      loadProfile();
                                    } else {
                                      await Navigator.of(context).push(_loadStore(
                                        categoryData[index]['category'],
                                        categoryData[index]['category_id'],
                                        buCode,
                                        buAcroname,
                                        logo,
                                        tenantId,
                                        tenantName,
                                        globalID));
                                      getCounter();
                                      loadProfile();
                                    }
                                  },
                                  child:Container(
                                    height: 100.0,
                                    width: 30.0,
                                    child: Card(
                                      color: Colors.white,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[index == 0 ?

                                        ListTile(
                                          leading:Container(
                                            width: 50.0,
                                            height: 50.0,
                                            decoration: new BoxDecoration(
                                              image: new DecorationImage(
                                                image: new NetworkImage(categoryData[index]['image']),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                              border: new Border.all(
                                                color: Colors.black54,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),

                                            title: Text("All items",style: GoogleFonts.openSans(color: Colors.black,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 18.0),),
                                          ) :
                                        ListTile(
                                          leading:Container(
                                            width: 50.0,
                                            height: 50.0,
                                            decoration: new BoxDecoration(
                                              image: new DecorationImage(
                                                image: new NetworkImage(categoryData[index]['image']),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                              border: new Border.all(
                                                color: Colors.black54,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          title: Text(categoryData[index]['category'].toString(),style: GoogleFonts.openSans(color: Colors.black,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 18.0),),
                                        ),
                                      ],
                                    ),
                                    elevation: 0,
                                    margin: EdgeInsets.all(3),
                                  ),
                                ),
                              );
                            }
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
  @override
  void initState() {
    super.initState();
    getCounter();
    loadTenant();
    loadProfile();
    loadProfilePic();
    print(widget.globalID);
    if (widget.globalID == '1') {
      image = "assets/jpg/foods.jpg";
    } else if (widget.globalID == '3') {
      image = "assets/jpg/electronics.jpg";
    } else if (widget.globalID == '4') {
      image = "assets/jpg/pharma.jpg";
    }
    print(widget.globalCat);
    initController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    screenWidth <= 400 ? gridCount = 2 : gridCount = 3;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          iconTheme: new IconThemeData(color: Colors.black54),
          // title: Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Image.asset(
          //       'assets/png/alturush_text_logo.png',
          //       fit: BoxFit.contain,
          //       height: 30,
          //     ),
          //     // Container(
          //     //   padding: const EdgeInsets.all(8.0), child: Text("Participating Businesses",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),)
          //   ],
          // ),
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search_outlined, color: Colors.black54, size: 25,),
                onPressed: () async {
                  Navigator.of(context).push(_search());
                  }
            ),
            status == null ? TextButton(
              onPressed: () async {
                await Navigator.of(context).push(_signIn());
                getCounter();
                loadProfile();
              },
              child: Text("Login",style: GoogleFonts.openSans(color:Colors.deepOrange,fontWeight: FontWeight.bold,fontSize: 16.0),),
            ): Padding(
              padding: EdgeInsets.all(0),
              child: InkWell(
                customBorder: CircleBorder(),
                onTap: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String username = prefs.getString('s_customerId');
                  if(username == null){
                    await Navigator.of(context).push(_signIn());
                    getCounter();
                    loadProfile();
                    loadProfilePic();
                  }else{
                    await Navigator.of(context).push(profile());
                    getCounter();
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
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                    ) : CachedNetworkImage(
                      imageUrl: profilePicture,
                      imageBuilder: (context, imageProvider) => Container(
                        height: 50,
                        width: 50,
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
                        height: 50,
                        width: 50,
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
              )
            ),
            cartLoading ? Center(
              child:Container(
                height:16.0 ,
                width: 16.0,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ) :
            Badge(
              position: BadgePosition.topEnd(top: 5, end: 10),
              animationDuration: Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              showBadge: showBadge,
              badgeContent: Text('${cartCount.toString()}',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: Padding(
                padding: EdgeInsets.only(right: 25),
                child: SizedBox(width: 25,
                  child: IconButton(icon: Icon(CupertinoIcons.cart,),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String username = prefs.getString('s_customerId');
                      if(username == null){
                        await Navigator.of(context).push(_signIn());
                        getCounter();
                      } else {
                        await Navigator.of(context).push(_loadCart());
                        getCounter();
                      }
                    }
                  )
                ),
              )
            )
          ],
        ),
        body: isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ):
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image.toString()),
                  fit: BoxFit.cover,
                ),
              ),
              child: SizedBox(
                height: 150.0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(25, 30, 25, 30),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    color: Colors.transparent,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          leading:Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: new BoxDecoration(
                              image: new DecorationImage(
                                image: new NetworkImage(widget.buLogo),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                              border: new Border.all(
                                color: Colors.white,
                                width: 0.5,
                              ),
                            ),
                          ),
                          title: Text(widget.buName,
                            style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: 20.0),
                          ),
                          subtitle: Text(
                            'Select from our participating businesses',
                            style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontStyle: FontStyle.normal,
                                fontSize: 13.0),
                          ),
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 5, 0, 10),
              child: Text('PARTICIPATING BUSINESSES',style: GoogleFonts.openSans(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  fontSize: 18.0)),
            ),
            SizedBox(
              height: 5.0,
            ),

            Expanded(
              child: RefreshIndicator(
                color: Colors.deepOrangeAccent,
                onRefresh: loadTenant,
                child: Scrollbar(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: loadTenants == null ? 0 : loadTenants.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          print(widget.buAcroname);
                          selectCategory(context,widget.buCode,widget.buAcroname,loadTenants[index]['logo'], loadTenants[index]['tenant_id'], loadTenants[index]['d_tenant_name'], widget.globalID);
                        },
                        child:Container(
                          height: 100.0,
                          width: 30.0,
                          child: Card(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ListTile(
                                  leading:Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: new BoxDecoration(
                                      image: new DecorationImage(
                                        image: new NetworkImage(loadTenants[index]['logo']),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                      border: new Border.all(
                                        color: Colors.black54,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  title: Text(loadTenants[index]['d_tenant_name'].toString(),style: GoogleFonts.openSans(color: Colors.black,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 18.0),),
                                ),
                              ],
                            ),
                            elevation: 0,
                            margin: EdgeInsets.all(3),
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ),
            ),
  //           Visibility(
  //             visible: cartCount == 0 ? false : true,
  //             child: Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
  //               child: Row(
  //                 children: <Widget>[
  //                   Flexible(
  //                     child: SleekButton(
  //                       onTap: () async {
  //                         SharedPreferences prefs = await SharedPreferences.getInstance();
  //                         String username = prefs.getString('s_customerId');
  //                         if(username == null){
  //                           await Navigator.of(context).push(_signIn());
  //                           getCounter();
  //                         }else{
  //                           await Navigator.of(context).push(_loadCart());
  //                           getCounter();
  //                         }
  //                       },
  //                       style: SleekButtonStyle.flat(
  //                         color: Colors.deepOrange,
  //                         inverted: false,
  //                         rounded: true,
  //                         size: SleekButtonSize.big,
  //                         context: context,
  //                       ),
  //                       child: Center(
  //                         child: cartLoading
  //                             ? Center(
  //                           child:Container(
  //                             height:16.0 ,
  //                             width: 16.0,
  //                             child: CircularProgressIndicator(
  // //                                          strokeWidth: 1,
  //                               valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
  //                             ),
  //                           ),
  //                         ) :  Row(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Text("View cart  ${cartCount.toString()}",style: TextStyle(
  //                                 shadows: [
  //                                   Shadow(
  //                                     blurRadius: 1.0,
  //                                     color: Colors.black54,
  //                                     offset: Offset(1.0, 1.0),
  //                                   ),
  //                                 ],
  //                                 fontStyle: FontStyle.normal,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 13.0),),
  // //                            Text("₱ ${oCcy.format(num.parse(subtotal.toString()))}",style: TextStyle(
  // //                                shadows: [
  // //                                  Shadow(
  // //                                    blurRadius: 1.0,
  // //                                    color: Colors.black54,
  // //                                    offset: Offset(1.0, 1.0),
  // //                                  ),
  // //                                ],
  // //                                fontStyle: FontStyle.normal,
  // //                                fontWeight: FontWeight.bold,
  // //                                fontSize: 13.0),),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
          ],
        ),
      ),
    );
  }
}


Route _loadCart() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoadCart(),
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


Route _profilePage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TrackOrder(),
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

Route _loadStore(categoryName,categoryId,buCode, buAcroname, storeLogo, tenantCode, tenantName, globalID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoadStore(categoryName:categoryName,categoryId:categoryId, buCode:buCode, buAcroname:buAcroname, storeLogo:storeLogo, tenantCode:tenantCode, tenantName:tenantName, globalID:globalID),
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

Route _search() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Search(),
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
