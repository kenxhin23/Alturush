import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';
import 'package:intl/intl.dart';
import '../load_bu.dart';
import '../live_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../create_account_signin.dart';
import 'order_summary_delivery_goods.dart';
import 'order_summary_pickup_goods.dart';
import 'order_timeframe_delivery_goods.dart';
import 'order_timeframe_pickup_goods.dart';

class ToDeliverGood extends StatefulWidget {
  final ticket;
  final ticketId;
  final mop;

  ToDeliverGood({Key key, @required this.ticket, this.ticketId, this.mop}) : super(key: key);//
  @override
  _ToDeliver createState() => _ToDeliver();
}

class _ToDeliver extends State<ToDeliverGood> {

  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  List loadTotal,lGetAmountPerTenant;
  var isLoading = false;
  List loadItems;

  Future getBunit() async {
    var res = await db.lookItemsSegregate2(widget.ticketId);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      lGetAmountPerTenant = res['user_details'];
      print("lgetamountpertenant");
      print(lGetAmountPerTenant);
    });
  }

  Future cancelOrder(tomsId) async{
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal:0.0, vertical: 20.0),
          title:Row(
            children: <Widget>[
              Text('Hello',style:TextStyle(fontSize: 18.0),),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child:Center(child:Text("Do you want to cancel this item?")),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close',style: TextStyle(
                color: Colors.green,
              ),),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Proceed',style: TextStyle(
                color: Colors.green,
              ),),
              onPressed: () async{
                cancelOrderSingle(tomsId);
                Navigator.of(context).pop();
                cancelSuccess();
              },
            ),
          ],
        );
      },
    );
  }
  var delCharge;
  var grandTotal;

  Future cancelOrderSingle(tomsId) async{
    // await db.cancelOrderSingleGood(tomsId);
    lookItemsGood();
  }
  cancelSuccess(){
    Fluttertoast.showToast(
        msg: "Your order successfully cancelled",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  Future lookItemsGood() async{
    //var res = await db.lookItems(widget.ticketNo);
    var res = await db.lookItemsGood(widget.ticketId);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadItems = res['user_details'];
      print('loaditems');
      print(loadItems);
//      tPrice = loadItems[0]['d_tot_price'];
//      deliveryCharge = loadItems[0]['d_delivery_charge'];
//      granTotal = double.parse(deliveryCharge)+tPrice;
//      tPrice = int.parse(loadItems[1]['d_tot_price']).toString();
//      deliveryCharge =  int.parse(loadItems[0]['d_delivery_charge']).toString();
//      print(int.parse(loadItems[1]['d_tot_price']).toString());
    });
  }

  var checkIfExists;
  Future checkIfOnGoing() async{
    var res = await db.checkIfOnGoing(widget.ticketId);
    if(res == 'true'){
      checkIfExists = res;
    }if(res == 'false'){
      checkIfExists = res;
    }
  }

  Future onRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }
    lookItemsGood();
    getBunit();
    checkIfOnGoing();
  }

  @override
  void initState() {
    super.initState();
    onRefresh();
    lookItemsGood();
    getBunit();
    checkIfOnGoing();
    print(widget.ticket);
    print(widget.ticketId);
    print(widget.mop);
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.green[300], // Status bar
          ),
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Order Details",style: GoogleFonts.openSans(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 16.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                color: Colors.green,
                onRefresh: onRefresh,
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: lGetAmountPerTenant == null ? 0 : lGetAmountPerTenant.length,
                    itemBuilder: (BuildContext context, int index0) {

                      String total = lGetAmountPerTenant[index0]['sumperstore'];

                      String instruction;
                      if (lGetAmountPerTenant[index0]['instructions'] == null) {
                        instruction ='';
                      } else {
                        instruction = lGetAmountPerTenant[index0]['instructions'];
                      }
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Divider(thickness: 1, color: Colors.green),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text('${lGetAmountPerTenant[index0]['business_unit']} - ${lGetAmountPerTenant[index0]['acroname']}',
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15.0),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.only(right: 15, bottom: 3),
                                  child: SizedBox(width: 20, height: 20,
                                      child: RawMaterialButton(
                                        onPressed: () async {

                                          String acroname = lGetAmountPerTenant[index0]['acroname'];
                                          String bunit_name = lGetAmountPerTenant[index0]['business_unit'];
                                          String bu_id = lGetAmountPerTenant[index0]['bu_id'];
                                          print(lGetAmountPerTenant[index0]['ticket_id']);
                                          print(widget.mop);
                                          if(widget.mop == 'Pick-up') {
                                            print('for pick-up');
                                            Navigator.of(context).push(_orderTimeFramePickup(
                                                widget.ticket,
                                                widget.ticketId,
                                                widget.mop,
                                                acroname,
                                                bunit_name,
                                                bu_id),
                                            );
                                          } else if (widget.mop == 'Delivery') {
                                            print('for delivery');
                                            Navigator.of(context).push(_orderTimeFrameDelivery(
                                                widget.ticket,
                                                widget.ticketId,
                                                widget.mop,
                                                acroname,
                                                bunit_name,
                                                bu_id),
                                            );
                                          }
                                        },
                                        elevation: 1.0,
                                        child: Icon(Icons.timer_outlined, color: Colors.green),
                                        shape: CircleBorder(),
                                      )
                                  ),
                                ),
                              ],
                            ),
                            Divider(thickness: 1, color: Colors.green),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Text('Item Ordered', style: TextStyle(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),

                                  Row(
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 50),
                                        child: Text('Status', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text('Price', style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Divider(color: Colors.black54),

                            ListView.builder(
                              physics:  NeverScrollableScrollPhysics (),
                              shrinkWrap: true,
                              itemCount:loadItems == null ? 0 : loadItems.length,
                              itemBuilder: (BuildContext context, int index1) {
                                print(loadItems[index1]['pending_status']);

                                var pending_status;
                                var ready_for_pickup;
                                var claimed;
                                var cancelled;

                                if (loadItems[index1]['pending_status'] == '1') {
                                  pending_status = true;
                                } else {
                                  pending_status = false;
                                }

                                if (loadItems[index1]['for_pickup'] == '1') {
                                  ready_for_pickup = true;
                                } else {
                                  ready_for_pickup = false;
                                }

                                if (loadItems[index1]['released_status'] == '1') {
                                  claimed = true;
                                } else {
                                  claimed = false;
                                }

                                if (loadItems[index1]['cancelled_status'] == '1' || loadItems[index1]['canceled_status'] == '1') {
                                  cancelled = true;
                                } else {
                                  cancelled = false;
                                }

                                print(pending_status);
                                return Visibility(
                                  visible: loadItems[index1]['bu_id'] != lGetAmountPerTenant[index0]['bu_id'] ? false : true,
                                  child: Container(
                                    height: 120.0,
                                    child: Card(
                                      color: Colors.transparent,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: <Widget>[

                                          Padding(
                                            padding: EdgeInsets.all(0),
                                            child: Column(
                                              children: <Widget>[
                                                CachedNetworkImage(
                                                  imageUrl: loadItems[index1]['prod_image'],
                                                  fit: BoxFit.contain,
                                                  imageBuilder: (context, imageProvider) => Container(
                                                    height: 75,
                                                    width: 75,
                                                    decoration: new BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: new DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.scaleDown,
                                                      ),
                                                    ),
                                                  ),
                                                  placeholder: (context, url,) => const CircularProgressIndicator(color: Colors.grey,),
                                                  errorWidget: (context, url, error) => Container(
                                                    height: 75,
                                                    width: 75,
                                                    decoration: new BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: new DecorationImage(
                                                        image: AssetImage("assets/png/No_image_available.png"),
                                                        fit: BoxFit.scaleDown,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(5, 5, 10, 0),
                                                  child: Text("₱ ${loadItems[index1]['price']}",
                                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13,
                                                      color: Colors.black,),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                              Expanded(
                                                child:Column(
                                                  crossAxisAlignment:CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Flexible(
                                                          child: Padding(
                                                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                            child: RichText(
                                                              overflow: TextOverflow.ellipsis,
                                                              text: TextSpan(
                                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 12),
                                                                  text: '${loadItems[index1]['prod_name']}'), maxLines: 3,
                                                            ),
                                                          ),
                                                        ),

                                                        Visibility(
                                                          visible: pending_status && cancelled == false,
                                                          child: Padding(
                                                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                            child: Container(height: 25, width: 60,
                                                              child: OutlinedButton(
                                                                style: ButtonStyle(
                                                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))),
                                                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                                                  backgroundColor: MaterialStateProperty.all(Colors.yellow),
                                                                  overlayColor: MaterialStateProperty.all(Colors.black12),
                                                                  side: MaterialStateProperty.all(BorderSide(
                                                                    color: Colors.yellow,
                                                                    width: 1.0,
                                                                    style: BorderStyle.solid,)),
                                                                ),
                                                                child:Text("Pending", style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.normal)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        Visibility(
                                                          visible: ready_for_pickup && cancelled == false && claimed == false,
                                                          child: Padding(
                                                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                            child: Container(height: 30, width: 65,
                                                              child: OutlinedButton(
                                                                style: ButtonStyle(
                                                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))),
                                                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                                                  backgroundColor: MaterialStateProperty.all(Colors.cyan),
                                                                  overlayColor: MaterialStateProperty.all(Colors.black12),
                                                                  side: MaterialStateProperty.all(BorderSide(
                                                                    color: Colors.cyan,
                                                                    width: 1.0,
                                                                    style: BorderStyle.solid,)),
                                                                ),
                                                                child:Text("Ready for pickup", style: TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.normal,),textAlign: TextAlign.center,),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        Visibility(
                                                          visible: claimed && cancelled == false,
                                                          child: Padding(
                                                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                            child: Container(height: 25, width: 60,
                                                              child: OutlinedButton(
                                                                style: ButtonStyle(
                                                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))),
                                                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                                                  backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
                                                                  overlayColor: MaterialStateProperty.all(Colors.black12),
                                                                  side: MaterialStateProperty.all(BorderSide(
                                                                    color: Colors.greenAccent,
                                                                    width: 1.0,
                                                                    style: BorderStyle.solid,)),
                                                                ),
                                                                child:Text("Claimed", style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.normal)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        Visibility(
                                                          visible: cancelled,
                                                          child: Padding(
                                                              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                              child: Container(height: 25, width: 65,
                                                                child: OutlinedButton(
                                                                  style: ButtonStyle(
                                                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))),
                                                                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                                                    backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                                                                    overlayColor: MaterialStateProperty.all(Colors.black12),
                                                                    side: MaterialStateProperty.all(BorderSide(
                                                                      color: Colors.redAccent,
                                                                      width: 1.0,
                                                                      style: BorderStyle.solid,)),
                                                                  ),
                                                                  child:Text("Cancelled", style: TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.normal)),
                                                                ),
                                                              )
                                                          ),
                                                        ),

                                                        Row(
                                                          children: <Widget>[
                                                            Container(
                                                              width: 80,
                                                              padding: EdgeInsets.fromLTRB(0, 2, 10, 0),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: [
                                                                  Text("₱ ${loadItems[index1]['total_price']}",
                                                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.green),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]
                                                    ),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(5, 5, 15, 5),
                                                          child: Text('Quantity: ${loadItems[index1]['d_qty']}',
                                                            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      elevation: 0,
                                      margin: EdgeInsets.all(3),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Divider(thickness: 1, color: Colors.black54),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TOTAL AMOUNT PURCHASED: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                                  Text('₱ ${total}',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),

                            Divider(thickness: 1, color: Colors.black54),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('IN CASE PRODUCT IS OUT OF STOCK:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('Remove it from my order', style: TextStyle(fontSize: 13, color: Colors.black54)),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('SPECIAL INSTRUCTIONS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                            ),

                            Padding(
                              padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                              child: new TextFormField(
                                enabled: false,
                                cursorColor: Colors.deepOrange,
                                style: TextStyle(color: Colors.black54, fontSize: 13),
                                controller: TextEditingController(text: '$instruction'),
                                maxLines: 4,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10.0, 0.5, 10.0, 10.0),
                                  focusedBorder:OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                ),
                              ),
                            ),
                          ],
                        )
                      );
                    }
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: SleekButton(
                      onTap: () async {

                        if (widget.mop == 'Pick-up') {
                          Navigator.of(context).push(_orderSummaryPickupGoods(widget.ticket, widget.ticketId));
                        } else if (widget.mop == 'Delivery') {
                          Navigator.of(context).push(_orderSummaryDeliveryGoods(widget.ticket, widget.ticketId));
                        }
                      },
                      style: SleekButtonStyle.flat(
                        color: Colors.green,
                        inverted: false,
                        rounded: true,
                        size: SleekButtonSize.normal,
                        context: context,
                      ),
                      child: Center(
                        child: Text("NEXT", style:TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 18.0),
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

Route _orderSummaryPickupGoods(ticket, ticketId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OrderSummaryPickupGoods(
        ticket   : ticket,
        ticketId : ticketId),
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

Route _orderSummaryDeliveryGoods(ticket, ticketId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OrderSummaryDeliveryGoods(
     ticket   : ticket,
     ticketId : ticketId),
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

Route _orderTimeFramePickup(ticket, ticketId, mop, acroname, bunit_name, bu_id) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OrderTimeFramePickupGoods(
        ticket    : ticket,
        ticketId  : ticketId,
        mop       : mop,
        acroname  : acroname,
        bunit_name: bunit_name,
        bu_id  : bu_id),
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

Route _orderTimeFrameDelivery(ticket, ticketId, mop, acroname, bunit_name, bu_id) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OrderTimeFrameDeliveryGoods(
        ticket     : ticket,
        ticketId   : ticketId,
        mop        : mop,
        acroname   : acroname,
        bunit_name : bunit_name,
        bu_id      : bu_id),
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