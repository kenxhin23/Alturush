import 'package:arush/profile_page.dart';
import 'package:arush/search.dart';
import 'package:arush/track_order.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_button/sleek_button.dart';

import 'create_account_signin.dart';
import 'db_helper.dart';
import 'grocery/gc_categories.dart';
import 'grocery/gc_loadStore.dart';
import 'grocery/groceryMain.dart';
import 'load_cart.dart';
import 'load_store.dart';
import 'load_tenants.dart';


class GlobalCat extends StatefulWidget {
  final buCode;
  final buLogo;
  final buName;
  final buAcroname;
  final groupCode;
  GlobalCat({Key key, @required this.buLogo,this.buName,this.buCode, this.buAcroname, this.groupCode}) : super(key: key);
  @override
  _GlobalCat createState() => _GlobalCat();
}

class _GlobalCat extends State<GlobalCat>{
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = RapidA();
  List listProfile;
  List loadTenants;
  List listSubtotal;
  List listCounter;
  List globalCat;
  List buData;
  List tenantStatus;
  List tenantStatus2;

  var isLoading = true;
  var cartLoading = true;
  var profileLoading = true;
  var cartCount;
  var profilePicture = "";
  var subtotal;

  int gridCount;

  bool showBadge;
  bool showCB;
  bool showMedplus;
  bool showValentines;

  String tenantIdXmas;
  String tenantIdMedPlus;
  String tenantIdValentines;
  String categoryIdXmas;
  String categoryIdValentines;
  String getTenantStatus;
  String getTenantStatusXmas;
  String getTenantStatusMedPlus;
  String getTenantStatusValentines;

  String image;
//   Future loadTenant() async {
// //    var res = await db.getTenants(widget.buCode);
//     var res = await db.getTenantsCi(widget.buCode);
//     if (!mounted) return;
//     setState(() {
//       isLoading = false;
//       loadTenants = res['user_details'];
//     });
//   }

  showCb() async {
    if (widget.buCode != '3' && getTenantStatusXmas == '1') {
      showCB = true;
    } else {
      showCB = false;
    }

  }

  showMp() async {
    if (widget.buCode == '1'&& getTenantStatusMedPlus == '1') {
      showMedplus = true;
    } else {
      showMedplus = false;
    }

  }

  showVb() async {
    if (widget.buCode != '3' && getTenantStatusValentines == '1') {
      showValentines = true;
    } else {
      showValentines = false;
    }

  }

  Future getGlobalCat() async{
    var res = await db.getGlobalCat();
    if (!mounted) return;
    setState(() {
      globalCat = res['user_details'];
      print(globalCat);
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


  Future getStatus() async {
    var res = await db.getStatus2(widget.buCode);
    if (!mounted) return;
    setState(() {
      tenantStatus2 = res['user_details'];
      for (int i=0; i<tenantStatus2.length;i++) {

        if (tenantIdXmas == tenantStatus2[i]['tenant_id']) {
          getTenantStatusXmas = tenantStatus2[i]['active'];

        }

        if ('39' == tenantStatus2[i]['tenant_id']) {
          getTenantStatusMedPlus = tenantStatus2[i]['active'];

        }

        if (tenantIdValentines == tenantStatus2[i]['tenant_id']) {
          getTenantStatusValentines = tenantStatus2[i]['active'];

        }
        isLoading = false;
      }
      print("ang status sa xmas $getTenantStatusXmas");

      print("ang status sa medplus $getTenantStatusMedPlus");

      print("ang status sa valentines $getTenantStatusValentines");
      showCb();
      showMp();
      showVb();
    });

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
      print(cartCount);
    });
  }

  Future loadBu() async {
    var res = await db. getBusinessUnitsCi();
    if (!mounted) return;
    setState(() {
      buData = res['user_details'];
    });
  }


  String status;
  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
  }

  Future onRefresh() async {
    getGlobalCat();
    getCounter();
    loadProfile();
    loadProfilePic();
  }

  @override
  void initState() {
    super.initState();
    onRefresh();
    getGlobalCat();
    getCounter();
    getStatus();
    loadProfile();
    loadProfilePic();

    print(widget.buCode);

    ///live
    if (widget.buCode =='1'){
      image = "assets/jpg/icm.jpg";
      tenantIdXmas = '42';
      tenantIdValentines = '47';
      categoryIdXmas = '495';
      categoryIdValentines = '508';
    } else if (widget.buCode =='2'){
      image = "assets/jpg/alturas.jpeg";
      tenantIdXmas = '44';
      tenantIdValentines = '48';
      categoryIdXmas = '497';
      categoryIdValentines = '509';
    } else if (widget.buCode =='3'){
      image = "assets/jpg/alta-citta.png";
    } else if (widget.buCode =='4'){
      image = "assets/jpg/marcela.jpeg";
      tenantIdXmas = '45';
      tenantIdValentines = '49';
      categoryIdXmas = '498';
      categoryIdValentines = '510';
    } else if (widget.buCode == '5') {
      image = "assets/jpg/alturas_talibon.jpeg";
    }

///local
//     if (widget.buCode =='1'){
//       image = "assets/jpg/icm.jpg";
//       tenantId = '42';
//       categoryId = '495';
//     } else if (widget.buCode =='2'){
//       image = "assets/jpg/alturas.jpeg";
//       tenantId = '44';
//       categoryId = '496';
//     } else if (widget.buCode =='3'){
//       image = "assets/jpg/alta-citta.png";
//     } else if (widget.buCode =='4'){
//       image = "assets/jpg/marcela.jpeg";
//       tenantId = '43';
//       categoryId = '496';
//     } else if (widget.buCode == '5') {
//       image = "assets/jpg/alturas_talibon.jpeg";
//     }

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
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.deepOrangeAccent[200], // Status bar
          ),
          backgroundColor: Colors.white,
          elevation: 0.1,
          iconTheme: new IconThemeData(color: Colors.black54),
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
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                // await Navigator.of(context).push(_signIn());
                getCounter();
                loadProfile();
              },
              child: Text("Login",style: GoogleFonts.openSans(color:Colors.deepOrange,fontWeight: FontWeight.bold,fontSize: 16.0),),
            ) :
            Padding(
              padding: EdgeInsets.all(0),
              child: InkWell(
                customBorder: CircleBorder(),
                onTap: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String username = prefs.getString('s_customerId');
                  if(username == null){
                    Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                    // await Navigator.of(context).push(_signIn());
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
              ),
            ),

            cartLoading ?
            Center(
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
                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                        // await Navigator.of(context).push(_signIn());
                        getCounter();
                      
                      }else{
                        await Navigator.of(context).push(_loadCart());
                        getCounter();

                      }
                    }
                  ),
                ),
              ),
            ),
          ],
        ),
        body: isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) :  Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            Expanded(
              child: RefreshIndicator(
                color: Colors.deepOrangeAccent,
                onRefresh: onRefresh,
                child: Scrollbar(
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: <Widget>[

                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(image.toString()),
                            fit: BoxFit.cover,
                          )
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
                                          color: Colors.black54,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    title: Text(widget.buName,
                                      style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 20.0),
                                    ),
                                    subtitle: Text(
                                      'Select Categories',
                                      style: GoogleFonts.openSans(color: Colors.white, fontStyle: FontStyle.normal, fontSize: 13.0),
                                    ),
                                    dense: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 5.0),

                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 5, 0, 10),
                        child: Text('CATEGORIES',style: GoogleFonts.openSans(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            fontSize: 18.0)),
                      ),

                      SizedBox(height: 5.0),

                      ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: globalCat == null ? 0 : globalCat.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () async{
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String username = prefs.getString('s_customerId');
                              if(username == null){
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                // Navigator.of(context).push(_signIn());
                              } else {
                                if (globalCat[index]['id'] != '2'){
                                  Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new LoadTenants(
                                      buLogo: widget.buLogo,
                                      buName: widget.buName,
                                      buAcroname: widget.buAcroname,
                                      buCode: widget.buCode,
                                      globalPic: globalCat[index]['cat_picture'],
                                      globalCat:globalCat[index]['category'],
                                      globalID:globalCat[index]['id']
                                  )),).then((val)=>{onRefresh()});
                                } else {
                                  print(widget.buCode);
                                  if (widget.buCode == '3' || widget.buCode == '4' || widget.buCode == '5') {

                                    print('dili pa pwde');
                                  } else {
                                    print('unya naka');

                                    Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new GcCategory(
                                        logo:widget.buLogo,
                                        categoryName : globalCat[index]['category'],
                                        categoryNo   : globalCat[index]['id'],
                                        businessUnit : widget.buName,
                                        bUnitCode    : widget.buCode,
                                        groupCode    : widget.groupCode
                                    )),).then((val)=>{onRefresh()});
                                  }
                                }
                              }

                              // selectCategory(context,widget.buCode,loadTenants[index]['logo'], loadTenants[index]['tenant_id'], loadTenants[index]['d_tenant_name']);
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
                                            image: new NetworkImage(globalCat[index]['cat_picture']),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                          border: new Border.all(
                                            color: Colors.black54,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      title: Text(globalCat[index]['category'].toString(),style: GoogleFonts.openSans(color: Colors.black,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 18.0),),
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

                      Divider(
                        thickness: 1,
                      ),


                      ///christmas banner
                      Visibility(
                        visible: showCB,
                        child:
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
                          child: GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String username = prefs.getString('s_customerId');
                              if(username == null){
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                // Navigator.of(context).push(_signIn());
                              } else {
                                if (widget.buCode != '3') {
                                  Future.delayed(const Duration(milliseconds: 500), () async {
                                    if (getTenantStatusXmas == '1') {
                                      print('pwede');

                                      // LoadStore
                                      Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new LoadStore(
                                          categoryName  : 'All items',
                                          categoryId    : categoryIdXmas,
                                          buCode        : widget.buCode,
                                          buAcroname    : widget.buAcroname,
                                          storeLogo     : 'https://apanel.alturush.com/images/tenants/tenant_1668395602.jpeg',
                                          tenantCode    : tenantIdXmas,
                                          tenantName    : 'CHRISTMAS BASKETS',
                                          globalID      : widget.groupCode
                                      )),).then((val)=>{onRefresh()});
                                    }
                                  });
                                }
                              }

                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)
                              ),
                              child: Image.asset(
                                'assets/png/Christmas_basket_all.png',
                                fit: BoxFit.contain,
                                height: 200,
                              ),
                            )
                          ),
                        ),
                      ),


                      ///medicine plus banner
                      Visibility(
                        visible: showMedplus,
                        child:
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
                          child: GestureDetector(
                            onTap: () async {

                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String username = prefs.getString('s_customerId');
                              if(username == null){
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                // Navigator.of(context).push(_signIn());
                              } else {
                                if (widget.buCode == '1') {
                                  setState(() {
                                    Future.delayed(const Duration(milliseconds: 500), () async {
                                      if (getTenantStatusMedPlus == '1') {
                                        print('pwede');
                                        Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new LoadStore(
                                            categoryName  : 'Promotional Items',
                                            categoryId    : '500',
                                            buCode        : '1',
                                            buAcroname    : 'ICM',
                                            storeLogo     : 'https://apanel.alturush.com/images/tenants/tenant_1659425607.png',
                                            tenantCode    : '39',
                                            tenantName    : 'MEDICINE PLUS',
                                            globalID      : '4'
                                        )),).then((val)=>{onRefresh()});
                                      }
                                      // else {
                                      //   Fluttertoast.showToast(
                                      //     msg: "This promo is currently unavailable",
                                      //     toastLength: Toast.LENGTH_SHORT,
                                      //     gravity: ToastGravity.BOTTOM,
                                      //     timeInSecForIosWeb: 2,
                                      //     backgroundColor: Colors.black.withOpacity(0.7),
                                      //     textColor: Colors.white,
                                      //     fontSize: 16.0
                                      //   );
                                      // }
                                    });
                                  });
                                }
                              }

                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Image.asset(
                                'assets/png/medplus_promo.png',
                                fit: BoxFit.contain,
                                height: 200,
                              ),
                            )
                          ),
                        ),
                      ),

                      ///Valentines banner
                      Visibility(
                        visible: showValentines,
                        child:
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 30),
                          child: GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                String username = prefs.getString('s_customerId');
                                if(username == null){
                                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                  // Navigator.of(context).push(_signIn());
                                } else {
                                  if (widget.buCode != '3') {
                                    setState(() {
                                      Future.delayed(const Duration(milliseconds: 500), () async {
                                        if (getTenantStatusValentines == '1') {
                                          print('pwede');

                                          Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new LoadStore(
                                              categoryName  : 'All items',
                                              categoryId    : categoryIdValentines,
                                              buCode        : widget.buCode,
                                              buAcroname    : widget.buAcroname,
                                              storeLogo     : 'https://apanel.alturush.com/images/tenants/tenant_1675296034.jpeg',
                                              tenantCode    : tenantIdValentines,
                                              tenantName    : 'VALENTINE BOUQUETS',
                                              globalID      : widget.groupCode
                                          )),).then((val)=>{onRefresh()});
                                        }
                                        // else {
                                        //   Fluttertoast.showToast(
                                        //       msg: "This promo is currently unavailable",
                                        //       toastLength: Toast.LENGTH_SHORT,
                                        //       gravity: ToastGravity.BOTTOM,
                                        //       timeInSecForIosWeb: 2,
                                        //       backgroundColor: Colors.black.withOpacity(0.7),
                                        //       textColor: Colors.white,
                                        //       fontSize: 16.0
                                        //   );
                                        // }
                                      });
                                    });
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey)
                                ),
                                child: Image.asset(
                                  'assets/png/valentines_2023_2.png',
                                  fit: BoxFit.contain,
                                  height: 200,
                                ),
                              )
                          ),
                        ),
                      ),
                    ],
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

Route _gotoTenants(buLogo, buName, buAcroname, buCode, globalPic, globalCat, globalID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoadTenants(buLogo:buLogo, buName:buName, buAcroname:buAcroname, buCode:buCode, globalPic:globalPic, globalCat:globalCat, globalID:globalID),
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

Route _groceryRoute(_groceryRoute) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GroceryMain(groceryRoute:_groceryRoute),
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

Route _loadGC(
    logo,
    categoryName,
    categoryNo,
    businessUnit,
    bUnitCode,
    groupCode){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcCategory(
        logo:logo,
        categoryName:categoryName,
        categoryNo:categoryNo,
        businessUnit:businessUnit,
        bUnitCode:bUnitCode,
        groupCode:groupCode),
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
    pageBuilder: (context, animation, secondaryAnimation) => LoadStore(
        categoryName:categoryName,
        categoryId:categoryId,
        buCode:buCode,
        buAcroname:buAcroname,
        storeLogo:storeLogo,
        tenantCode:tenantCode,
        tenantName:tenantName,
        globalID:globalID),
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