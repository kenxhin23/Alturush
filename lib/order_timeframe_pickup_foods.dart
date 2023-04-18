import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_account_signin.dart';
import 'db_helper.dart';

class OrderTimeFramePickupFoods extends StatefulWidget {
  final ticketNo;
  final mop;
  final acroname;
  final tenantName;
  final tenantId;
  final ifCancelled;

  const OrderTimeFramePickupFoods({Key key, this.ticketNo, this.mop, this.acroname, this.tenantName, this.tenantId, this.ifCancelled}) : super(key: key);
  // const OrderTimeFrame({Key key, @required this.cart}) : super(key: key);
  @override
  _OrderTimeFramePickupFoodsState createState() => _OrderTimeFramePickupFoodsState();
}

class _OrderTimeFramePickupFoodsState extends State<OrderTimeFramePickupFoods>{
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  List getTime, getStatus, timeframe;

  String submitted, submittedDate, submittedHr, submittedMin, submittedSec;
  String prepared, prepareDate, prepareHr, prepareMin, prepareSec;
  String taggedStatus, taggedStatusDate, tagHr, tagMin, tagSec;
  String taggedPickup, taggedPickupDate, tagPickupHr, tagPickupMin, tagPickupSec;
  String setup, setupDate, setupHr, setupMin, setupSec;
  String transit, transitDate, transHr, transMin, transSec;
  String cancelled, delivered, completed, remitted;
  String status;
  var index = 0;

  bool pending;
  bool submit;
  bool taggedpickup;
  bool cancel;

  var taggedstatus = true;
  var prepare = true;
  var set_up = true;
  var trans = true;
  var deliver = true;
  var complete = true;
  var remit = true;
  var canceL = true;

  Future onRefresh() async{

    setState(() {
      // canceLstatus();
      timeFrame();
    });
  }

  Future timeFrame() async{
    var res = await db.orderTimeFramePickUp(widget.ticketNo, widget.tenantId);
    var res1 = await db.cancelStatus(widget.ticketNo);
    if (!mounted) return;
    setState(() {

      getTime = res['user_details'];
      getStatus = res1['user_details'];
      status = getStatus[0]['cancel_status'];

      if (getTime[0]['pending_status'] == '1') {
        pending = true;
      } else {
        pending = false;
      }

      if (status == '1') {
        cancel = true;
      } else {
        cancel = false;
      }

      if (getTime[0]['prepared_at'] == null) {
        submit = false;
        submitted = '';
      } else {
        submit = true;
        submittedDate = getTime[0]['prepared_at'];
        DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
        submitted = DateFormat().add_yMMMMd().add_jm().format(date);
      }


      if (getTime[0]['tag_pickup_at'] == null) {
        taggedpickup = false;
        taggedPickup = '';
      } else {
        taggedpickup = true;
        taggedPickupDate = getTime[0]['tag_pickup_at'];
        DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(taggedPickupDate);
        taggedPickup = DateFormat().add_yMMMMd().add_jm().format(date);
      }


      print(getTime);
      isLoading = false;
    });
  }

  @override
  void initState(){
    print(widget.ticketNo);
    print(widget.mop);
    print(widget.acroname);
    print(widget.tenantName);
    print(widget.tenantId);
    onRefresh();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrangeAccent, // Status bar
          statusBarIconBrightness: Brightness.light,  // Only honored in Android M and above
        ),
        backgroundColor: Colors.deepOrange[400],
        elevation: 0.1,
        titleSpacing: 0,
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
        title: Text(
          "Order Time Frame (Pick-up)", style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ),
      body: isLoading ?
      Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ) :
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child:RefreshIndicator(
              color: Colors.deepOrangeAccent,
              onRefresh: onRefresh,
              child: Scrollbar(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      height: 40,
                      color: Colors.deepOrange[300],
                      child: Text('${widget.tenantName}',
                        style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                    ),

                    Container(
                      height: 40,
                      color: Colors.grey[200],
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text('ORDER TRANSACTION DETAILS',
                            style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
                          ),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Visibility(
                          visible: pending && taggedpickup == false && submit == false && cancel == false && widget.ifCancelled == false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('PENDING...',
                                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Visibility(
                          visible: cancel || widget.ifCancelled,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('CANCELLED ORDER',
                                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Visibility(
                          visible: submit || taggedpickup && cancel == false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timer_outlined, size: 20, color: Colors.deepOrangeAccent),
                                Text(' ORDER TIME FRAME',
                                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Divider(thickness: 2, color: Colors.grey[200]),

                        Visibility(
                          visible: submit || taggedpickup && cancel == false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 10),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Order Submission',
                                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
                                ),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('(Submitted Order by Tenant)',
                                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.deepOrangeAccent),
                                ),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('$submitted',
                                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),
                                ),
                              ),

                              SizedBox(height: 15),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Order Claimed',
                                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
                                ),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('(Picked-Up By Customer)',
                                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.deepOrangeAccent),
                                ),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('$taggedPickup',
                                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),
                                ),
                              ),

                              SizedBox(
                                height: 10,
                              ),

                              Divider(thickness: 2, color: Colors.grey[200]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
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

