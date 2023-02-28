import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  const OrderTimeFramePickupFoods({Key key, this.ticketNo, this.mop, this.acroname, this.tenantName, this.tenantId}) : super(key: key);
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

  var submit = true;
  var taggedpickup = true;
  var taggedstatus = true;
  var cancel = true;
  var prepare = true;
  var pending = true;
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

      if (getTime[0]['prepared_at'] == null) {
        submitted = '';
      } else {
        submittedDate = getTime[0]['prepared_at'];
        DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
        submitted = DateFormat().add_yMMMMd().add_jm().format(date);
      }


      if (getTime[0]['tag_pickup_at'] == null) {
        taggedPickup = '';
      } else {
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
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Order Time Frame (Pick-up)", style: GoogleFonts.openSans(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ),
      body: isLoading ?
      Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ) :
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child:RefreshIndicator(
              color: Colors.deepOrangeAccent,
              onRefresh: onRefresh,
              child: Scrollbar(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[

                    Divider(thickness: 1, color: Colors.deepOrange),

                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('${widget.tenantName}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepOrangeAccent)),
                    ),

                    Divider(thickness: 1, color: Colors.deepOrange),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text('ORDER TRANSACTION DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.time, size: 16, color: Colors.black),
                              Text(' ORDER TIME FRAME', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black)),
                            ],
                          )
                        ),

                        Divider(color: Colors.black54),

                        SizedBox(height: 10),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Order Submission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('(Submitted Order by Tenant)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.deepOrangeAccent)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('$submitted', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black)),
                        ),

                        Divider(color: Colors.black54),

                        SizedBox(height: 10),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Order Claimed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('(Picked-Up By Customer)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.deepOrangeAccent)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('$taggedPickup', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black)),
                        ),
                        Divider(color: Colors.black54),

                        // Visibility(
                        //     visible: status == '1' ? true : false,
                        //     child: Center(
                        //       child: Text("Cancelled Order", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        //     )
                        // ),
                        //
                        // Visibility(
                        //   visible: status == '0' ? true : false,
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ]
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

