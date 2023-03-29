import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../create_account_signin.dart';
import '../db_helper.dart';
import '../profile_page.dart';
import 'gc_cart.dart';
import 'gc_loadStore.dart';
import 'gc_search.dart';

class GcCategory extends StatefulWidget {

  final logo;
  final categoryName;
  final categoryNo;
  final businessUnit;
  final bUnitCode;
  final groupCode;

  GcCategory({Key key, @required this.logo,this.categoryName,this.categoryNo,this.businessUnit,this.bUnitCode, this.groupCode}) : super(key: key);
  @override
  _GcCategory createState() => _GcCategory();
}

class _GcCategory extends State<GcCategory>{
  final db = RapidA();

  List loadStoreData = [];
  List listProfile;
  List loadSubtotal;
  List listCounter;
  List categoryData;

  String status;

  int gridCount;

  var profilePicture ="";
  var profileLoading = true;
  var cartLoading = true;
  var subTotal;
  var cartCount;
  var isLoading = true;
  var offset = 0;

  bool showBadge;

  Future loadProfilePic() async {

      var res = await db.loadProfile();
      if (!mounted) return;
      setState(() {
        listProfile = res['user_details'];
        profilePicture = listProfile[0]['d_photo'];
        profileLoading = false;
      });

  }

//   Future loadGcSubTotal() async{
//     var res = await db.loadGcSubTotal();
//     if (!mounted) return;
//     setState(() {
// //      cartLoading = false;
//       loadSubtotal = res['user_details'];
//       if(loadSubtotal[0]['d_subtotal'].toString().isEmpty){
//         subTotal = 0;
//       }else{
//         subTotal = loadSubtotal[0]['d_subtotal'].toString();
//       }
//     });
//   }

  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
    if(status != null) {
      // loadGcSubTotal();
    }
  }

  Future getGcCounter() async {
    var res = await db.getGcCounter();
    if (!mounted) return;
    setState(() {
     cartLoading = false;
      listCounter = res['user_details'];
      cartCount = listCounter[0]['num'];
      if(cartCount == 0) {
        showBadge = false;
      } else {
        showBadge = true;
      }
    });
  }

  Future getGcCategory() async {
    var res = await db.getGcCategories();
    if (!mounted) return;
    setState(() {
      categoryData = res['user_details'];
      isLoading = false;
      // print(categoryData);
    });
  }

  Future loadStore() async{
    setState(() {
    });
    Map res = await db.getGcStoreCi(offset.toString(), widget.categoryNo, widget.groupCode);
    if (!mounted) return;
    setState(() {
      loadStoreData.clear();
      loadStoreData = res['user_details'];
      isLoading = false;
      offset;
    });
  }

  Future onRefresh() async {
    print('ni refresh na gc catergoy');
    loadStore();
    loadProfilePic();
    // loadGcSubTotal();
    loadProfile();
    getGcCounter();
    getGcCategory();
  }

  @override
  void initState() {
    onRefresh();
    loadStore();
    loadProfilePic();
    // loadGcSubTotal();
    loadProfile();
    getGcCounter();
    getGcCategory();
    print(widget.categoryName);
    print(widget.categoryNo);
    super.initState();
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
            statusBarColor: Colors.green[400], // Status bar
            statusBarIconBrightness: Brightness.light ,  // Only honored in Android M and above
          ),
          backgroundColor: Colors.green[400],
          elevation: 0.1,
          iconTheme: new IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.white, size: 20,
              shadows: [
                Shadow(
                  blurRadius: 1.0,
                  color: Colors.black54,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search_outlined, color: Colors.white, size: 25,
                shadows: [
                  Shadow(
                    blurRadius: 1.0,
                    color: Colors.black54,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString('s_customerId');
                if(username == null){
                  Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                } else {
                  Navigator.of(context).push(_search(widget.bUnitCode, widget.groupCode)).then((val)=>{onRefresh()});
                }
              }
            ),
            status == null ? TextButton(
              onPressed: () async {
                await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                loadProfile();
                getGcCounter();
              },
              child: Text("Login",style: GoogleFonts.openSans(color:Colors.white, fontWeight: FontWeight.bold,fontSize: 16.0),),
            ):
            Padding(
              padding: EdgeInsets.all(0),
              child: InkWell(
                customBorder: CircleBorder(),
                onTap: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String username = prefs.getString('s_customerId');
                  if(username == null){
                    // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                    await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                    loadProfile();
                    getGcCounter();
                    loadProfilePic();
                  }else{
                    await Navigator.of(context).push(_profilePage()).then((val)=>{onRefresh()});
                    loadProfile();
                    getGcCounter();
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
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
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
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
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
            ):
            Badge(
              position: BadgePosition.topEnd(top: 5, end: 10),
              animationDuration: Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              showBadge: showBadge,
              badgeColor: Colors.white,
              badgeContent: Text('${cartCount.toString()}',
                style: TextStyle(color: Colors.green[400], fontSize: 11, fontWeight: FontWeight.bold),
              ),
              child: Padding(
                padding: EdgeInsets.only(right: 25),
                child: SizedBox(width: 25,
                  child: IconButton(icon: Icon(CupertinoIcons.cart,
                    shadows: [
                      Shadow(
                        blurRadius: 1.0,
                        color: Colors.black54,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String username = prefs.getString('s_customerId');
                      if(username == null){
                        // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                        await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                        getGcCounter();
                      } else {
                        await Navigator.of(context).push(_gcViewCart()).then((val)=>{onRefresh()});
                        getGcCounter();
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
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ):
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/jpg/grocerybg.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SizedBox(
                height: 160.0,
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
                                image: new NetworkImage(widget.logo),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                              border: new Border.all(
                                color: Colors.green[400],
                                width: 1,
                              ),
                            ),
                          ),
                          title: Text(widget.businessUnit,
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              fontSize: 20.0
                            )
                          ),
                          // subtitle: Text('Select from our participating businesses',
                          //   style: GoogleFonts.openSans(
                          //     color: Colors.white,
                          //     fontStyle: FontStyle.normal,
                          //     fontSize: 13.0
                          //   ),
                          // ),
                          dense: true,
                        )
                      ]
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green[300],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 5, 0, 10),
                    child: Text('GROCERIES CATEGORY',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: Colors.green,
                onRefresh: onRefresh,
                child: Scrollbar(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: categoryData == null ? 0 : categoryData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap:  () async {
                          print(categoryData[index]['category_no']);
                          print(categoryData[index]['category_name']);
                          // GcLoadStore
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String username = prefs.getString('s_customerId');
                          if(username == null){
                            await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                          } else {
                            await Navigator.of(context).push(_loadGC(
                                widget.logo,
                                categoryData[index]['category_name'],
                                categoryData[index]['category_no'],
                                widget.businessUnit,
                                widget.bUnitCode,
                                widget.groupCode
                            )).then((val)=>{onRefresh()});
                          }
                        },
                        child: Container(
                          height: 100.0,
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
                                        image: new NetworkImage(categoryData[index]['image']),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                      border: new Border.all(
                                        color: Colors.green[400],
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  title: Text(categoryData[index]['category_name'].toString(),
                                    style: GoogleFonts.openSans(color: Colors.black54, fontWeight:FontWeight.bold, fontSize: 18.0),
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ),
                      );
                    },
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

Route _search(bunitCode, groupCode) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcSearch(
      bunitCode : bunitCode,
      groupCode : groupCode),
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

Route _profilePage() {
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


Route _gcViewCart(){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcLoadCart(),
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

Route _loadGC(
    logo,
    categoryName,
    categoryNo,
    businessUnit,
    bUnitCode,
    groupCode){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcLoadStore(
        logo:logo,
        categoryName:categoryName,
        categoryNo:categoryNo,
        businessUnit:businessUnit,
        bUnitCode:bUnitCode,
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