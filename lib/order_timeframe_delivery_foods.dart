import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_account_signin.dart';
import 'db_helper.dart';

class OrderTimeFrameDeliveryFoods extends StatefulWidget {
  final ticketNo;
  final mop;
  final acroname;
  final tenantName;
  final tenantId;
  final ticketId;

  const OrderTimeFrameDeliveryFoods({Key key, this.ticketNo, this.mop, this.acroname, this.tenantName, this.tenantId, this.ticketId}) : super(key: key);
  // const OrderTimeFrame({Key key, @required this.cart}) : super(key: key);
  @override
  _OrderTimeFrameDeliveryFoodsState createState() => _OrderTimeFrameDeliveryFoodsState();
}

class _OrderTimeFrameDeliveryFoodsState extends State<OrderTimeFrameDeliveryFoods>{
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  List getTime, getStatus, timeframe, getCon;

  String submitted, submittedDate;
  String prepared, prepareDate, prepareHr, prepareMin, prepareSec;
  String taggedStatus, taggedStatusDate, tagHr, tagMin, tagSec;
  String taggedPickup, taggedPickupDate, tagPickupHr, tagPickupMin, tagPickupSec;
  String r_status, r_statusDate, r_statusHr, r_statusMin, r_statusSec;
  String setup, setupDate, setupHr, setupMin, setupSec;
  String transit, transDate, transHr, transMin, transSec;
  String delivered, deliveredDate, deliveredHr, deliveredMin, deliveredSec;
  String container, quantity;
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

  Future refresh() async{
    setState(() {
      // canceLstatus();
      // timeFrame();
    });
  }

  Future getContainer() async {
    var res = await db.getContainer(widget.ticketId, widget.tenantId);
    if (!mounted) return;
    setState(() {
      getCon = res['user_details'];

      if (getCon.isEmpty) {
        container = '';
        quantity ='';
      } else {
        container = getCon[0]['container_type'];
        quantity = getCon[0]['quantity'];
      }


      print(getCon);
      isLoading == false;
    });
  }

  Future timeFrame() async{
    var res = await db.orderTimeFrameDelivery(widget.ticketNo, widget.tenantId);
    var res1 = await db.cancelStatus(widget.ticketNo);
    if (!mounted) return;
    setState(() {


      getTime = res['user_details'];
      getStatus = res1['user_details'];

      status = getStatus[0]['cancel_status'];
      print(getStatus);

      if (getTime[0]['prepared_at'] == null) {
        submitted ='';
      } else {
        submittedDate = getTime[0]['prepared_at'];
        DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
        submitted = DateFormat().add_yMMMMd().add_jm().format(date);
      }



      if (getTime[0]['tag_status'] == '0') {
        prepared = '';
        prepareHr ='';
        prepareMin='';
        prepareSec='';
      } else {
        prepareDate = getTime[index]['tag_status_at'];
        DateTime prep = DateFormat('yyyy-MM-dd hh:mm:ss').parse(prepareDate);
        prepared = DateFormat().add_yMMMMd().add_jm().format(prep);

        DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
        DateTime endDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(prepareDate);
        Duration dif = endDate.difference(startDate);

        prepareHr = dif.inHours.toString();
        prepareMin = ("/ ${(dif.inMinutes %60).toString()} min");
        prepareSec = ("${(dif.inSeconds %60).toString()} sec");
      }

      if (getTime[0]['r_setup'] == '0') {
        r_status = '';
        r_statusHr = '';
        r_statusMin = '';
        r_statusSec = '';
      } else {
        r_statusDate = getTime[index]['r_setup_at'];
        DateTime prep = DateFormat('yyyy-MM-dd hh:mm:ss').parse(r_statusDate);
        r_status = DateFormat().add_yMMMMd().add_jm().format(prep);

        DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(prepareDate);
        DateTime endDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(r_statusDate);
        Duration dif = endDate.difference(startDate);

        r_statusHr = dif.inHours.toString();
        r_statusMin = ("/ ${(dif.inMinutes %60).toString()} min");
        r_statusSec = ("${(dif.inSeconds %60).toString()} sec");
      }

      if (getTime[0]['trans_status'] == null || getTime[0]['trans_status'] == '0') {
        transit ='';
        transHr ='';
        transMin ='';
        transSec ='';
      } else {
        transDate = getTime[index]['trans_at'];
        DateTime prep = DateFormat('yyyy-MM-dd hh:mm:ss').parse(transDate);
        transit = DateFormat().add_yMMMMd().add_jm().format(prep);

        DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(r_statusDate);
        DateTime endDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(transDate);
        Duration dif = endDate.difference(startDate);

        transHr = dif.inHours.toString();
        transMin = ("/ ${(dif.inMinutes %60).toString()} min");
        transSec = ("${(dif.inSeconds %60).toString()} sec");
        // print(transit);
      }

      if (getTime[0]['delivered_status'] == null || getTime[0]['delivered_status'] == '0' ) {
        delivered = '';
        deliveredHr ='';
        deliveredMin ='';
        deliveredSec ='';
      } else {
        deliveredDate = getTime[index]['delivered_at'];
        DateTime prep = DateFormat('yyyy-MM-dd hh:mm:ss').parse(deliveredDate);
        delivered = DateFormat().add_yMMMMd().add_jm().format(prep);

        DateTime startDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(transDate);
        DateTime endDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(deliveredDate);
        Duration dif = endDate.difference(startDate);

        deliveredHr = dif.inHours.toString();
        deliveredMin = ("/ ${(dif.inMinutes %60).toString()} min");
        deliveredSec = ("${(dif.inSeconds %60).toString()} sec");
        // print(delivered);
      }
      // print(getTime);

      isLoading = false;
    });
  }

  Future onRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }
    timeFrame();
    getContainer();
  }
  @override
  void initState(){
    print(widget.ticketNo);
    print(widget.mop);
    print(widget.acroname);
    print(widget.tenantName);
    print(widget.tenantId);
    onRefresh();
    timeFrame();
    getContainer();
    // canceLstatus();
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
        title: Text("Order Time Frame (Delivery)", style: GoogleFonts.openSans(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 16.0),
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
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Text('ORDER TRANSACTION DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Row(
                                children: [
                                  Text('CONTAINER: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                                  Text('$container', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black)),
                                ],
                              ),

                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    VerticalDivider(color: Colors.black54),
                                    Text('QTY: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                                    Text('$quantity', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black)),
                                  ],
                                ),
                              )
                            ],
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
                          child: Text('Preparation / Time Consumed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('(Order Submission -> For Pick-up Tagging)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.deepOrangeAccent)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('$prepared $prepareMin', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black)),
                        ),

                        Divider(color: Colors.black54),

                        SizedBox(height: 10),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Picking Assignment / Time Consumed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('(For Pick-up Tagging -> Rider Set-up)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.deepOrangeAccent)),
                        ),
                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('$r_status $r_statusMin', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black)),
                        ),

                        Divider(color: Colors.black54),

                        SizedBox(height: 10),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Order Claiming / Time Consumed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('(Rider Set-up -> In Transit Tagging by Tenant)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.deepOrangeAccent)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('$transit $transMin', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black)),
                        ),

                        Divider(color: Colors.black54),

                        SizedBox(height: 10),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Delivery Period / Time Consumed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('(In Transit Tagging by Tenant -> Customer)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.deepOrangeAccent)),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10),
                          child: Text('$delivered $deliveredMin', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black)),
                        ),

                        Divider(color: Colors.black54),

                        // Visibility(
                        //   visible: status == '1' ? true : false,
                        //   child: Center(
                        //     child: Text("Cancelled Order", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        //   )
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
                    )
                  ]
                )
              )
            )
          )
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


