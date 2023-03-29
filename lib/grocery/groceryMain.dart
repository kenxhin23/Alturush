import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../db_helper.dart';
import 'package:intl/intl.dart';
import '../create_account_signin.dart';
import '../showDpn.dart';
import '../track_order.dart';
import 'package:sleek_button/sleek_button.dart';
import 'gc_loadStore.dart';
import 'gc_cart.dart';
import 'package:arush/idmasterfile.dart';
import 'package:arush/showDpn2.dart';
import '../load_bu.dart';
import 'package:arush/profile_page.dart';
//paul jearic

class GroceryMain extends StatefulWidget {
  final groceryRoute;
  GroceryMain({Key key, @required this.groceryRoute,}) : super(key: key);
  @override
  _GroceryMain createState() => _GroceryMain();
}

class _GroceryMain extends State<GroceryMain> with SingleTickerProviderStateMixin{
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final province = TextEditingController();
  final town = TextEditingController();

  List loadProfileData;
  List buData;
  List loadSubtotal;
  List listCounter;

  String firstName = "";
  String quotes = "";
  String author = "";
  String profilePhoto;
  String status;

  var cartLoading = true;
  var isLoading1 = true;
  var cartCount = 0;
  var subTotal ;

  int provinceId;
  int townID;

  // Future loadBu() async{
  //     var res = await db.getBusinessUnitsCi(unitGroupId,1);
  //     if (!mounted) return;
  //     setState(() {
  //       buData = res['user_details'];
  //     });
  //     Timer(Duration(milliseconds:500), () {
  //       _needsScroll = true;
  //       _scrollToEnd();
  //     });
  // }

  _scrollToEnd() async{
    if (_needsScroll) {
      _needsScroll = false;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  Future getCounter() async {
    var res = await db.getGcCounter();
    if (!mounted) return;
    setState(() {
      listCounter = res['user_details'];
    });
  }

  Future listenCartCount() async{
    var res = await db.getGcCounter();
    if (!mounted) return;
    setState(() {
      cartLoading = false;
      listCounter = res['user_details'];
      cartCount = listCounter[0]['num'];
    });
  }

  // Future loadGcSubTotal() async{
  //   var res = await db.loadGcSubTotal();
  //   if (!mounted) return;
  //   setState(() {
  //     isLoading1 = false;
  //     loadSubtotal = res['user_details'];
  //     if(loadSubtotal[0]['d_subtotal'] == null){
  //       subTotal = 0;
  //     }else{
  //       subTotal = loadSubtotal[0]['d_subtotal'].toString();
  //     }
  //   });
  // }

  Future loadProfile() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
    if(status != null) {
      var res = await db.loadProfile();
      // loadGcSubTotal();
      // getCounter();
      // timer = Timer.periodic(Duration(seconds: 5), (Timer t) => loadGcSubTotal());
      if (!mounted) return;
      setState(() {
        loadProfileData = res['user_details'];
        firstName = loadProfileData[0]['d_fname'];
      });
    }
    else{
      firstName = "";
      profilePhoto = "";
    }
  }

  Future futureLoadQuotes() async{
    var res = await db.futureLoadQuotes();
    if (!mounted) return;
    setState(() {
      quotes = res["content"];
      author = "-"+res["author"];
    });
  }


  List getProvinceData;
  selectProvince() async{
    var res = await db.getProvince();
    if (!mounted) return;
    setState(() {
      getProvinceData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select Province',),
          content: Container(
            height: 90.0,
            width: 300.0,
            child: Scrollbar(
              child: ListView.builder(
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
                    child: ListTile(
                      title: Text(getProvinceData[index]['prov_name']),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                province.clear();
              },
            ),
          ],
        );
      },
    );
  }

  List getTownData;
  selectTown() async{
    var res = await db.selectTown(provinceId.toString());
    if (!mounted) return;
    setState(() {
      getTownData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select Town',),
          content: Container(
            height: 300.0,
            width: 300.0,
            child: Scrollbar(
              child:ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getTownData == null ? 0 : getTownData.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap:(){
                      town.text = getTownData[index]['town_name'];
                      townID = int.parse(getTownData[index]['town_id']);
                      unitGroupId = int.parse(getTownData[index]['bunit_group_id']);
                      Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(getTownData[index]['town_name']),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                town.clear();
              },
            ),
          ],
        );
      },
    );
  }

  void selectGcCategory(BuildContext context,logo,businessUnit,bUnitCode) async{
    List categoryData;
    var res = await db.getGcCategories();
    if (!mounted) return;
    setState(() {
      categoryData = res['user_details'];
      print(categoryData);
    });
    showModalBottomSheet(
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
                    child:Text("Category",style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),),
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
                                      Navigator.pop(context);
                                      await Navigator.of(context).push(_loadGC(logo,categoryData[index]['category_name'],categoryData[index]['category_no'],businessUnit,bUnitCode));
                                      listenCartCount();
                                      loadProfile();
                                    },
                                    child:Container(
                                      height: 120.0,
                                      width: 30.0,
                                      child: Card(
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                             ListTile(
                                              leading:Container(
                                                width: 60.0,
                                                height: 60.0,
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
                                              title: Text(categoryData[index]['category_name'].toString(),style: GoogleFonts.openSans(color: Colors.black54,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 22.0),),
                                            ),
                                          ],
                                        ),
                                        elevation: 0,
                                        margin: EdgeInsets.all(3),
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      }

  ScrollController _scrollController = new ScrollController();
  bool _needsScroll = false;
  final _formKey = GlobalKey<FormState>();

  List globalCat;
  Future getGlobalCat() async{
    var res = await db.getGlobalCat();
    if (!mounted) return;
    setState(() {
      globalCat = res['user_details'];
    });
  }

  @override
  void initState() {
    super.initState();
    futureLoadQuotes();
    loadProfile();
    listenCartCount();
    getGlobalCat();
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
          statusBarColor: Colors.green[300], // Status bar
        ),
        backgroundColor: Colors.white,
        elevation: 0.1,
        iconTheme: new IconThemeData(color: Colors.black),
        actions: [
          status == null ? TextButton(
            onPressed: () async {
              await Navigator.of(context).push(_signIn());
              loadProfile();
              getCounter();
              listenCartCount();
            },
            child: Text("Login",style: GoogleFonts.openSans(color:Colors.deepOrange,fontWeight: FontWeight.bold,fontSize: 18.0),),
          ): IconButton(
              icon: Icon(Icons.person, color: Colors.black),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString('s_customerId');
                if(username == null){
                  await Navigator.of(context).push(_signIn());
                  loadProfile();
                  getCounter();
                  listenCartCount();
                }else{
                  await Navigator.of(context).push(_profilePage());
                  loadProfile();
                  getCounter();
                  listenCartCount();
                }
              }
          ),
        ],
        // title: Text("Grocery Home",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        title:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/png/logo_raider8.2.png',
              fit: BoxFit.contain,
              height: 60,
            ),
            Container(
              padding: const EdgeInsets.all(8.0), child: Text("Grocery Home",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),)
          ],
        ),
      ),
      drawer:Container(
        color: Colors.deepOrange,
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
                      SizedBox(
                        height: 70.0,
                      ),
                      SizedBox(
                        height: 35.0,
                      ),

                      SizedBox(
                        height: 50.0,
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount:  globalCat == null ? 0 : globalCat.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Image.network(globalCat[index]['cat_picture']),
                                ),
                                title: Text(globalCat[index]['category'],style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 16.0),),
                                onTap: () async{
                                  Navigator.pop(context);
                                  if(globalCat[index]['id'] == '1'){
                                    Navigator.of(context).push(_foodRoute(globalCat[index]['id']));
                                  }if(globalCat[index]['id'] == '2'){
                                    Navigator.of(context).push(_groceryRoute(globalCat[index]['id']));
                                  }if(globalCat[index]['id'] == '3'){
                                    Navigator.of(context).push(_foodRoute(globalCat[index]['id']));
                                  }
                                }
                            );
                          }
                      ),
                      ListTile(
                          leading: Icon(Icons.person,size: 30.0,),
                          title: Text('Profile',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 16.0),),
                          onTap: () async{
                            Navigator.of(context).pop();
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String username = prefs.getString('s_customerId');
                            if(username != null){
                              await Navigator.of(context).push(profile());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }else{
                              await Navigator.of(context).push(_signIn());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }
                          }
                      ),
                      ListTile(
                          leading: Icon(Icons.add,size: 30.0,),
                          title: Text('Add discount',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 16.0),),
                          onTap: () async{
                            Navigator.of(context).pop();
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String username = prefs.getString('s_customerId');
                            if(username == null){
                              await Navigator.of(context).push(_signIn());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }else{
                              await Navigator.of(context).push(_signIn());
                              getCounter();
                              listenCartCount();
                              loadProfile();
                            }
                          }
                      ),
                      ListTile(
                        leading: Icon(Icons.info_outline,size: 30.0,),
                        title: Text('Data privacy',style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 16.0),),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(showDpn2());
                          }
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body:  Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Scrollbar(
                child:ListView(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: <Widget>[
                    SizedBox(
                      height: 35.0,
                    ),
                    Center(
                      child:Text("Howdy ${firstName.toString()}",style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 23.0),),
                    ),
                    Center(
                      child:Text(quotes,style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                    ),
                    Center(
                      child:Text(author,style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                    ),
                    SizedBox(
                      height: 50.0,
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
                                padding: EdgeInsets.fromLTRB(40, 10, 5, 5),
                                child: new Text(
                                  "Select Province",
                                  style: GoogleFonts.openSans(
                                      fontStyle: FontStyle.normal, fontSize: 18.0),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30.0),
                                  onTap: (){
                                    selectProvince();
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
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
                                              borderRadius: BorderRadius.circular(30.0)),
                                        )
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(40, 10, 5, 5),
                                child: new Text(
                                  "Select town",
                                  style: GoogleFonts.openSans(
                                      fontStyle: FontStyle.normal, fontSize: 18.0),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30.0),
                                  onTap: (){
                                    selectTown();
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
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
                                              borderRadius: BorderRadius.circular(30.0)),
                                        )
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
                                child: Container(
                                  height: 50.0,
                                  child: OutlinedButton(
                                    onPressed: (){
                                      if (_formKey.currentState.validate()) {
                                        // loadBu();
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.deepOrangeAccent,
                                      primary: Colors.white,
                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                    ),
                                    child: Text("Go"),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
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
                              selectGcCategory(context,buData[index]['logo'],buData[index]['business_unit'],buData[index]['bunit_code']);
                            },
                            child:Container(
                              height: 120.0,
                              width: 30.0,
                              child: Card(
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
//                                  crossAxisAlignment: CrossAxisAlignment.center,
//                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading:Container(
                                        width: 60.0,
                                        height: 60.0,
                                        decoration: new BoxDecoration(
                                          image: new DecorationImage(
                                            image: new NetworkImage(buData[index]['logo']),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                          border: new Border.all(
                                            color: Colors.black54,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      title: Text(buData[index]['business_unit'],style: GoogleFonts.openSans(color: Colors.black54,fontStyle: FontStyle.normal,fontWeight:FontWeight.bold,fontSize: 22.0),),
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
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Row(
                children: <Widget>[

                  Visibility(
                    visible: cartCount == 0 ? false : true,
                    child: Flexible(
                      child: SleekButton(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String username = prefs.getString('s_customerId');
                          if(username == null){
                            await Navigator.of(context).push(_signIn());
                            listenCartCount();
                            loadProfile();
                          }else{
                            await Navigator.of(context).push(_gcViewCart());
                            listenCartCount();
                            loadProfile();
                          }

                        },
                        style: SleekButtonStyle.flat(
                          color: Colors.green,
                          inverted: false,
                          rounded: true,
                          size: SleekButtonSize.big,
                          context: context,
                        ),
                        child: Center(
                          child: cartLoading
                              ? Center(
                            child:Container(
                              height:16.0 ,
                              width: 16.0,
                              child: CircularProgressIndicator(
//                                          strokeWidth: 1,
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ) : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("View cart  ${cartCount.toString()}",style: TextStyle(
                                  shadows: [
                                    Shadow(
                                      blurRadius: 1.0,
                                      color: Colors.black54,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0),
                              ),
                               isLoading1
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
                              Text("₱ ${subTotal.toString()}",style: TextStyle(
                                  shadows: [
                                    Shadow(
                                      blurRadius: 1.0,
                                      color: Colors.black54,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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

Route _profilePage() {
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


Route _loadGC(logo,categoryName,categoryNo,businessUnit,bUnitCode){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcLoadStore(logo:logo,categoryName:categoryName,categoryNo:categoryNo,businessUnit:businessUnit,bUnitCode:bUnitCode),
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

Route viewIds() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => IdMasterFile(),
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

Route showDpn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ShowDpn(),
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

