import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'create_account_signin.dart';
import 'db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'load_cart.dart';
import 'profile/addressMasterFile.dart';
import 'order_details_food.dart';
import 'idmasterfile.dart';
import 'package:badges/badges.dart';
import 'profile/accountSettings.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:arush/profile_page.dart';
import 'order_details_goods.dart';


class TrackOrder extends StatefulWidget {
  @override
  _TrackOrder createState() => _TrackOrder();
}

class _TrackOrder extends State<TrackOrder> with SingleTickerProviderStateMixin{

  final db = RapidA();
  TabController _tabController;

  List listGetTicketOnFoods = []; //pending list
  List listGetTicketOnGoods = [];
  List listGetTicketOnTransit = [];
  List listGetTicketOnDelivered = [];
  List listGetTicketOnCancelled = [];
  List listProfile = [];
  List listCounter = [];
  // List listOrderTicket = [];

  List<String> months = ['January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'];

  String orderTicket;
  String selectedMonth;
  String dateMonth;
  String month;

  var firstName;
  var lastName;
  var status;
  var profilePicture = "";
  var pendingCounter = "";
  var onTransitCounter = "";
  var deliveredCounter = "";
  var cancelledCounter = "";
  var cartLoading = true;
  var isLoading = true;
  var profileLoading = true;
  var cartCount;

  int monthNo;

  bool showBadge;

  double total;

  Timer timer;


  Future getTicketNoOnFoods() async{
    var res = await db.getTicketNoOnFoods();
    if (!mounted) return;
    setState(() {
      listGetTicketOnFoods = res['user_details'];
      pendingCounter = listGetTicketOnFoods.length.toString();
      // print(listGetTicket);
    });
    // print(listGetTicket);
  }

  Future getTicketNoOnGoods() async{
    var res = await db.getTicketNoOnGoods();
    if (!mounted) return;
    setState(() {
      listGetTicketOnGoods = res['user_details'];
      print(res);
      print('sa goods ni');

      // print(listGetTicket);
    });
    // print(listGetTicket);
  }

  Future getOrderTicketIfExist(ticketID) async {
    var res = await db.getOrderTicketIfExist(ticketID);
    if (!mounted) return;
    setState(() {
      orderTicket = res;
      // print(orderTicket);
    });
  }

  Future loadProfile() async {
    var res = await db.loadProfile();
    if (!mounted) return;
    setState(() {
      listProfile = res['user_details'];
      profilePicture = listProfile[0]['d_photo'];
      profileLoading = false;
    });
  }

  Future getTicketNoFoodOnTransit() async {
    var res = await db.getTicketNoFoodOnTransit();
    if (!mounted) return;
    setState(() {
      listGetTicketOnTransit = res['user_details'];
      onTransitCounter = listGetTicketOnTransit.length.toString();
    });
  }

  Future getTicketNoFoodOnDelivered() async {
    var res = await db.getTicketNoFoodOnDelivered();
    if (!mounted) return;
    setState(() {
      listGetTicketOnDelivered = res['user_details'];
      deliveredCounter = listGetTicketOnDelivered.length.toString();
    });
  }

  Future getTicketCancelled() async {
    var res = await db.getTicketCancelled();
    if (!mounted) return;
    setState(() {
      listGetTicketOnCancelled = res['user_details'];
      cancelledCounter = listGetTicketOnCancelled.length.toString();
    });
  }

  Future toRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }
    print('refresh na');
    loadProfile(); //load profile picture
    getTicketNoOnFoods(); //p
    getTicketNoOnGoods();// ending request
    // getTicketNoFoodOnTransit(); //on transit request
    // getTicketNoFoodOnDelivered(); // delivered
    // getTicketCancelled(); // cancelled

    isLoading = false;
  }

 void  getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName =  prefs.getString('s_firstname');
      lastName = prefs.getString('s_lastname');
    });
  }
  // Future getCounter() async {
  //   var res = await db.getCounter();
  //   if (!mounted) return;
  //   setState(() {
  //     isLoading = false;
  //     listCounter = res['user_details'];
  //   });
  // }
  //
  // Future listenCartCount() async{
  //   var res = await db.getCounter();
  //   if (!mounted) return;
  //   setState(() {
  //     isLoading = false;
  //     cartLoading = false;
  //     listCounter = res['user_details'];
  //     cartCount = listCounter[0]['num'];
  //
  //     if (cartCount == 0) {
  //       showBadge = false;
  //     } else {
  //       showBadge = true;
  //     }
  //     // print(cartCount);
  //   });
  // }
  @override
  void initState() {
    // getCounter();
    // listenCartCount();
    _tabController = TabController(vsync: this, length: 2);
    getUserName();
    getTicketNoOnFoods();
    getTicketNoOnGoods();
    toRefresh();
    // print(months);
    // getOrderTicketIfExist();
    timer = Timer.periodic(Duration(seconds: 30), (Timer t) => toRefresh());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        return Navigator.canPop(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          titleSpacing: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.deepOrangeAccent[200], // Status bar
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            indicatorColor: Colors.deepOrange,
            tabs: [
              Tab(
                child: Text(
                  "Foods, etc.",
                  style: GoogleFonts.openSans(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
              ),
              Tab(
                child: Text("Goods",
                  style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 15.0),
                ),
              ),
            ],
          ),
          // actions: [
          //   cartLoading ?
          //   Center(
          //     child:Container(
          //       height:16.0 ,
          //       width: 16.0,
          //       child: CircularProgressIndicator(
          //         valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
          //       ),
          //     ),
          //   ) :
          //   Badge(
          //     position: BadgePosition.topEnd(top: 5, end: 10),
          //     animationDuration: Duration(milliseconds: 300),
          //     animationType: BadgeAnimationType.slide,
          //     showBadge: showBadge,
          //     badgeContent: Text('${cartCount.toString()}',
          //       style: TextStyle(color: Colors.white, fontSize: 10),
          //     ),
          //     child: Padding(
          //       padding: EdgeInsets.only(right: 25),
          //       child: SizedBox(width: 25,
          //         child: IconButton(icon: Icon(CupertinoIcons.cart, color: Colors.black54),
          //           onPressed: () async {
          //             await Navigator.of(context).push(_loadCart());
          //             getCounter();
          //             listenCartCount();
          //           }
          //         )
          //       ),
          //     )
          //   )
          // ],
          title: Text("Orders History",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0),),
        ),
        body : isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) : TabBarView(
          controller: _tabController,
          children: [

            ///Foods & etc.
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      //Add isDense true and zero Padding.
                      //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.deepOrangeAccent.withOpacity(0.8), width: 1)
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        // width: 0.0 produces a thin "hairline" border
                        borderSide: const BorderSide(color: Colors.black54, width: 1),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          // borderSide: const BorderSide(color: Colors.green, width: 0.0),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.8), width: 1.0)
                      ),
                      //Add more decoration as you want here
                      //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                    ),
                    isExpanded: true,
                    hint: const Text(
                      '-- Select Month --',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black45,
                    ),
                    iconSize: 30,
                    items: months
                        .map((item) =>
                        DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black),
                          ),
                        ))
                        .toList(),
                    // ignore: missing_return
                    validator: (value) {
                      if (value == null) {
                        return 'Please select option';
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                        monthNo = months.indexOf(value);
                        // print(selectedMonth);
                      });
                      //Do something when changing the item if you want.
                    },
                    onSaved: (value) {
                      selectedMonth = value.toString();
                    },
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    color: Colors.deepOrangeAccent,
                    onRefresh: toRefresh,
                    child: Scrollbar(
                      child: ListView(
                        children: [

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                            child:ListView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: listGetTicketOnFoods == null ? 0 : listGetTicketOnFoods.length,
                              itemBuilder: (BuildContext context, int index) {
                                String status;
                                if (double.parse(listGetTicketOnFoods[index]['total']) == 0) {
                                  status ='(Cancelled)';
                                } else {
                                  status ='';
                                }
                                String ticket = listGetTicketOnFoods[index]['d_ticket'];
                                String ticketId = listGetTicketOnFoods[index]['d_ticket_id'];
                                String mop = listGetTicketOnFoods[index]['d_mop'];
                                String type = listGetTicketOnFoods[index]['order_type_stat'];
                                // if (listGetTicket[index]['cancel_status'] == '1') {
                                //   status ='(Cancelled)';
                                // } else {
                                //   status ='';
                                // }
                                if (selectedMonth == null) {
                                  var now = DateTime.now();
                                  selectedMonth = DateFormat().add_MMMM().format(now);
                                }

                                dateMonth = listGetTicketOnFoods[index]['date'];
                                DateTime date = DateFormat('yyyy-MM-dd').parse(dateMonth);
                                month = DateFormat().add_MMMM().format(date);

                                return Padding(
                                  padding:EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
                                  child: InkWell(
                                    onTap:(){
                                      getOrderTicketIfExist(ticketId);
                                      Navigator.of(context).push(viewUpComingFood(
                                        1,
                                        ticket,
                                        ticketId,
                                        mop,
                                        type,
                                      ));
                                      // Future.delayed(const Duration(milliseconds: 100), () {
                                      //   setState(() {
                                      //     if (orderTicket == 'true') {
                                      //       // print('dayon kol');
                                      //       Navigator.of(context).push(viewUpComingFood(1,
                                      //           ticket,
                                      //           ticketId,
                                      //           mop,
                                      //           type));
                                      //     } else if (orderTicket =='false') {
                                      //       print('ayaw kol');
                                      //       // Navigator.of(context).push(viewUpComingGood('20734'));
                                      //     }
                                      //   });
                                      // });
                                    },
                                    child: Visibility(
                                      visible: month == selectedMonth,
                                      child: Container(
                                        height: 65.0,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          elevation: 0.0,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[

                                              Padding(
                                                padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 5.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children:<Widget>[

                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[

                                                        Text(' ${listGetTicketOnFoods[index]['d_mop']}',style: TextStyle(color: Colors.black),),

                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(' Ticket # ${listGetTicketOnFoods[index]['d_ticket']}',style: TextStyle(fontSize: 16.0,color: Colors.black, fontWeight: FontWeight.bold)),
                                                          ],
                                                        )
                                                      ],
                                                    ),

                                                    Padding(
                                                      padding: EdgeInsets.only(top: 15),
                                                      child: Text(' $status', style: TextStyle(fontSize: 16.0,color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            ///Goods
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      //Add isDense true and zero Padding.
                      //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.deepOrangeAccent.withOpacity(0.8), width: 1)
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        // width: 0.0 produces a thin "hairline" border
                        borderSide: const BorderSide(color: Colors.black54, width: 1),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          // borderSide: const BorderSide(color: Colors.green, width: 0.0),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.8), width: 1.0)
                      ),
                      //Add more decoration as you want here
                      //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                    ),
                    isExpanded: true,
                    hint: const Text(
                      '-- Select Month --',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black45,
                    ),
                    iconSize: 30,
                    items: months
                        .map((item) =>
                        DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black),
                          ),
                        ))
                        .toList(),
                    // ignore: missing_return
                    validator: (value) {
                      if (value == null) {
                        return 'Please select option';
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                        monthNo = months.indexOf(value);
                        // print(selectedMonth);
                      });
                      //Do something when changing the item if you want.
                    },
                    onSaved: (value) {
                      selectedMonth = value.toString();
                    },
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    color: Colors.deepOrangeAccent,
                    onRefresh: toRefresh,
                    child: Scrollbar(
                      child: ListView(
                        children: [

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                            child:ListView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: listGetTicketOnGoods == null ? 0 : listGetTicketOnGoods.length,
                              itemBuilder: (BuildContext context, int index) {
                                String status;
                                // if (double.parse(listGetTicketOnGoods[index]['total']) == 0) {
                                //   status ='(Cancelled)';
                                // } else {
                                //   status ='';
                                // }
                                String ticket = listGetTicketOnGoods[index]['d_ticket'];
                                String ticketId = listGetTicketOnGoods[index]['d_ticket_id'];
                                String mop = listGetTicketOnGoods[index]['d_mop'];
                                String type = listGetTicketOnGoods[index]['order_type_stat'];
                                // if (listGetTicket[index]['cancel_status'] == '1') {
                                //   status ='(Cancelled)';
                                // } else {
                                //   status ='';
                                // }
                                if (selectedMonth == null) {
                                  var now = DateTime.now();
                                  selectedMonth = DateFormat().add_MMMM().format(now);
                                }

                                dateMonth = listGetTicketOnGoods[index]['date'];
                                DateTime date = DateFormat('yyyy-MM-dd').parse(dateMonth);
                                month = DateFormat().add_MMMM().format(date);

                                return Padding(
                                  padding:EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
                                  child: InkWell(
                                      onTap:(){
                                        getOrderTicketIfExist(ticketId);

                                              Navigator.of(context).push(viewUpComingGood(
                                                ticket,
                                                ticketId,
                                                mop,
                                              ));
                                      },
                                      child: Visibility(
                                        visible: month == selectedMonth,
                                        child: Container(
                                          height: 65.0,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            elevation: 0.0,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 5.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children:<Widget>[

                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[

                                                          Text(' ${listGetTicketOnGoods[index]['d_mop']}',style: TextStyle(color: Colors.black),),

                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(' Ticket # ${listGetTicketOnGoods[index]['d_ticket']}',style: TextStyle(fontSize: 16.0,color: Colors.black, fontWeight: FontWeight.bold)),
                                                            ],
                                                          )
                                                        ],
                                                      ),

                                                      // Padding(
                                                      //   padding: EdgeInsets.only(top: 15),
                                                      //   child: Text(' $status', style: TextStyle(fontSize: 16.0,color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Route viewUpComingFood(pend, ticketNo,ticketId, mop, type) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ToDeliverFood(
        pend:pend,
        ticketNo:ticketNo,
        ticketId:ticketId,
        mop:mop,
        type:type),
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

Route viewUpComingGood(ticket, ticketId, mop) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ToDeliverGood(ticket : ticket, ticketId : ticketId, mop : mop),
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
