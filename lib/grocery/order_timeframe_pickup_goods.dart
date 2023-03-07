

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../create_account_signin.dart';
import '../db_helper.dart';

class OrderTimeFramePickupGoods extends StatefulWidget {
  final ticket;
  final ticketId;
  final mop;
  final acroname;
  final bunit_name;
  final bu_id;

  const OrderTimeFramePickupGoods({Key key, this.ticket, this.ticketId, this.mop, this.acroname, this.bunit_name, this.bu_id }) : super(key: key);
  @override
  _OrderTimeFramePickupGoodsState createState() => _OrderTimeFramePickupGoodsState();
}

class _OrderTimeFramePickupGoodsState extends State<OrderTimeFramePickupGoods> {

  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;

  List getTime;

  String prepared, preparedDate;
  String taggedPickup, taggedPickupDate;
  String status;
  String pendingStatus;

  bool pending;
  bool cancel;
  bool prep;
  bool taggedpickup;


  Future onRefresh() async {
    timeFrame();
  }

  Future timeFrame() async{
    var res = await db.orderTimeFramePickUpGoods(widget.ticketId, widget.bu_id);
    if (!mounted) return;
    setState(() {

      getTime = res['user_details'];

      pendingStatus = getTime[0]['pending_status'];
      status = getTime[0]['cancelled_status'];

      if (pendingStatus == '1') {
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
        prepared = '';
        prep = false;
      } else {
        preparedDate = getTime[0]['prepared_at'];
        DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(preparedDate);
        prepared = DateFormat().add_yMMMMd().add_jm().format(date);
        prep = true;
      }


      if (getTime[0]['paid_at'] == null) {
        taggedPickup = '';
        taggedpickup = false;
      } else {
        taggedPickupDate = getTime[0]['paid_at'];
        DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(taggedPickupDate);
        taggedPickup = DateFormat().add_yMMMMd().add_jm().format(date);
        taggedpickup = true;
      }


      print(getTime);
      print(prepared);
      print(taggedPickup);
      print(status);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    onRefresh();
    timeFrame();
    print(widget.ticket);
    print(widget.ticketId);
    print(widget.mop);
    print(widget.acroname);
    print(widget.bunit_name);
    print(widget.bu_id);


  }

  @override
  void dispose() {
    super.dispose();
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
        title: Text('Order Time Frame (Pick-up)', style: GoogleFonts.openSans(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ),
      body: isLoading ?
      Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ) :
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              color: Colors.green,
              child: Scrollbar(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[

                    Divider(thickness: 1, color: Colors.green),

                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('${widget.bunit_name}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                    ),

                    Divider(thickness: 1, color: Colors.green),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text('ORDER TRANSACTION DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Visibility(
                          visible: pending && taggedpickup == false && prep == false && cancel == false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('PENDING...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),),
                              ],
                            ),
                          ),
                        ),

                        Visibility(
                          visible: cancel,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('CANCELLED ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),),
                              ],
                            ),
                          ),
                        ),

                        Visibility(
                          visible: (prep || taggedpickup) && cancel == false,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.time, size: 16, color: Colors.black),
                                    Text(' ORDER TIME FRAME', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black)),
                                  ],
                                ),
                              ),

                              Divider(color: Colors.black54),

                              SizedBox(height: 10),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Order Submission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('(Submitted Order)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.green)),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('$prepared', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black)),
                              ),

                              Divider(color: Colors.black54),

                              SizedBox(height: 10),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Order Claimed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('(Picked-Up By Customer)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.green)),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 10),
                                child: Text('$taggedPickup', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black)),
                              ),

                            ],
                          ),
                        ),


                        Divider(color: Colors.black54),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      )
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
