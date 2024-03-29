import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
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

  Timer timer;

  List loadTotal;
  List lGetAmountPerTenant;
  List loadItems;

  var isLoading = true;

  bool ifCancelled;
  bool hideCancelButton;

  String cancelDetails;
  String buId;

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

  Future cancelOrderGoods(buId, ticketID) async{
    var res = await db.cancelOrderGoods(buId, ticketID);
    if (!mounted) return;
    setState(() {
      print(res);
      onRefresh();
      print('cancelling order');
    });
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
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String username = prefs.getString('s_customerId');
    // if(username == null){
    //   Navigator.of(context).push(_signIn());
    // }
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
    timer = Timer.periodic(Duration(seconds: 30), (Timer t) => onRefresh());
  }

  @override
  void dispose() {
    timer?.cancel();
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
            statusBarColor: Colors.green[400], // Status bar
            statusBarIconBrightness: Brightness.light ,  // Only honored in Android M and above
          ),
          backgroundColor: Colors.green[400],
          elevation: 0.1,
          iconTheme: new IconThemeData(color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 1.0,
                color: Colors.black54,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.white,size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Order Details",style: GoogleFonts.openSans(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
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

                      String total;

                      if (lGetAmountPerTenant[index0]['canceled_status'] == '1'){
                        total = '0.00';
                      } else {
                        total = lGetAmountPerTenant[index0]['sumperstore'];
                      }

                      String instruction;
                      if (lGetAmountPerTenant[index0]['instructions'] == null) {
                        instruction ='';
                      } else {
                        instruction = lGetAmountPerTenant[index0]['instructions'];
                      }

                      if (lGetAmountPerTenant[index0]['cancelled_status'] == '1') {
                        cancelDetails = 'Order(s) has been cancelled.';
                      } else {
                        cancelDetails = '';
                      }

                      ifCancelled = lGetAmountPerTenant[index0]['cancelled_status'] == '1' ? true : false;
                      if (lGetAmountPerTenant[index0]['prepared_status'] == '0') {
                        hideCancelButton = true;
                      } else {
                        hideCancelButton = false;
                      }
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Container(
                              height: 40,
                              color: Colors.green[300],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text('${lGetAmountPerTenant[index0]['business_unit']} - ${lGetAmountPerTenant[index0]['acroname']}',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(right: 15, bottom: 3),
                                    child: SizedBox(width: 20, height: 20,
                                      child: RawMaterialButton(
                                        onPressed: () async {

                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          String username = prefs.getString('s_customerId');
                                          if(username == null){
                                            // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                            Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                                          } else {
                                            String acroname = lGetAmountPerTenant[index0]['acroname'];
                                            String bunit_name = lGetAmountPerTenant[index0]['business_unit'];
                                            String bu_id = lGetAmountPerTenant[index0]['bu_id'];

                                            if(widget.mop == 'Pick-up') {
                                              print('for pick-up');
                                              Navigator.of(context).push(_orderTimeFramePickup(
                                                  widget.ticket,
                                                  widget.ticketId,
                                                  widget.mop,
                                                  acroname,
                                                  bunit_name,
                                                  bu_id),
                                              ).then((val)=>{onRefresh()});
                                            } else if (widget.mop == 'Delivery') {
                                              print('for delivery');
                                              Navigator.of(context).push(_orderTimeFrameDelivery(
                                                  widget.ticket,
                                                  widget.ticketId,
                                                  widget.mop,
                                                  acroname,
                                                  bunit_name,
                                                  bu_id),
                                              ).then((val)=>{onRefresh()});
                                            }
                                          }
                                        },
                                        elevation: 1.0,
                                        child: Icon(Icons.timer_outlined, color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 1.0,
                                              color: Colors.black54,
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                        ),
                                        shape: CircleBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 40,
                              color: Colors.green[200],
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Text('Item Ordered',
                                      style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),

                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 50),
                                          child: Text('Status',
                                            style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Text('Price',
                                            style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),


                            ListView.builder(
                              physics:  NeverScrollableScrollPhysics (),
                              shrinkWrap: true,
                              itemCount:loadItems == null ? 0 : loadItems.length,
                              itemBuilder: (BuildContext context, int index1) {
                                // print(loadItems[index1]['pending_status']);

                                var pending_status;
                                var ready_for_pickup;
                                var claimed;
                                var paid;
                                var cancelled;
                                String icoos;

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

                                if (loadItems[index1]['paid_status'] == '1') {
                                  paid = true;
                                } else {
                                  paid = false;
                                }

                                if (loadItems[index1]['canceled_status'] == '1') {
                                  cancelled = true;
                                } else {
                                  cancelled = false;
                                }

                                if (loadItems[index1]['icoos'] == '0') {
                                  icoos ='Cancel Item';
                                } else {
                                  icoos ='Cancel Order';
                                }

                                // print(pending_status);
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
                                                      color: Colors.black54),
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
                                                              maxLines: 3,
                                                              text: TextSpan(
                                                                style: GoogleFonts.openSans(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold),
                                                                text: '${loadItems[index1]['prod_name']}',
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        Row(
                                                          children: <Widget>[

                                                            Visibility(
                                                              visible: cancelled == false && ready_for_pickup == false,
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
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
                                                                padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
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
                                                                padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                                                child: Container(height: 30, width: 60,
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
                                                                    child:Text("Paid & Released", style: TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.normal), textAlign: TextAlign.center,),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            Visibility(
                                                              visible: cancelled,
                                                              child: Padding(
                                                                  padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
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

                                                            Container(
                                                              width: 85,
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
                                                            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
                                                          child: Text('If out of stock: ',
                                                            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                          ),
                                                        ),

                                                        Padding(
                                                          padding: EdgeInsets.only(right: 10, top: 5),
                                                          child: Container(
                                                            padding: EdgeInsets.all(0),
                                                            width: 100,
                                                            child: DropdownButtonFormField(
                                                              decoration: InputDecoration(
                                                                enabled: false,
                                                                //Add isDense true and zero Padding.
                                                                //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                isDense: true,
                                                                focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5),
                                                                    borderSide: BorderSide(color: Colors.green.withOpacity(0.8), width: 1)
                                                                ),
                                                                contentPadding: const EdgeInsets.only(left: 5, right: 0),
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                ),
                                                                //Add more decoration as you want here
                                                                //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                              ),
                                                              hint: Text(icoos, style: GoogleFonts.openSans(fontSize: 12, color: Colors.black38),
                                                              ),
                                                              icon: const Icon(
                                                                Icons.arrow_drop_down,
                                                                color: Colors.black45,
                                                              ),
                                                              iconSize: 20,
                                                              isExpanded: true,
                                                              // ignore: missing_return
                                                            ),
                                                          ),
                                                        ),

                                                        // Padding(
                                                        //   padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                        //   child: Text(icoos,
                                                        //     style: TextStyle(fontSize: 13.0, color: Colors.black),
                                                        //   ),
                                                        // ),
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
                            Divider(thickness: 2, color: Colors.grey[200]),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TOTAL AMOUNT PURCHASED: ',
                                    style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                  ),
                                  Text('₱ ${total}',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),

                            Divider(thickness: 2, color: Colors.grey[200]),

                            Visibility(
                              visible: ifCancelled,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [

                                    SizedBox(
                                      height: 20,
                                      child: OutlinedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0))),
                                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                          backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                                          overlayColor: MaterialStateProperty.all(Colors.black12),
                                          side: MaterialStateProperty.all(BorderSide(
                                            color: Colors.redAccent,
                                            width: 1.0,
                                            style: BorderStyle.solid,)),
                                        ),
                                        child:Text("$cancelDetails", style: TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.normal)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('SPECIAL INSTRUCTIONS',
                                style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            ),

                            Padding(
                              padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                              child: new TextFormField(
                                enabled: false,
                                cursorColor: Colors.green[400],
                                style: GoogleFonts.openSans(color: Colors.black54, fontSize: 13),
                                controller: TextEditingController(text: '$instruction'),
                                maxLines: 4,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(10.0, 0.5, 10.0, 10.0),
                                  focusedBorder:OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green[400], width: 2.0),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                ),
                              ),
                            ),

                            Visibility(
                              visible: ifCancelled == false && hideCancelButton,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: SizedBox(
                                        height: 30,
                                        child: OutlinedButton(
                                          onPressed: () async {

                                            buId = lGetAmountPerTenant[index0]['bu_id'];

                                            CoolAlert.show(
                                                context: context,
                                                showCancelBtn: true,
                                                type: CoolAlertType.warning,
                                                text: "Are you sure?",
                                                confirmBtnColor: Colors.green[400],
                                                backgroundColor: Colors.green[400],
                                                barrierDismissible: false,
                                                confirmBtnText: 'Yes',
                                                onConfirmBtnTap: () async {
                                                  Navigator.of(context).pop();
                                                  setState(() {
                                                    cancelOrderGoods(buId, widget.ticketId);
                                                  });
                                                },
                                                cancelBtnText: 'Cancel',
                                                onCancelBtnTap: () async {
                                                  Navigator.of(context).pop();
                                                }
                                            );

                                          },
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
                                          child:Text("CANCEL ORDER(S)",
                                            style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString('s_customerId');
                        if(username == null){
                          // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                          Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                        } else {
                          if (widget.mop == 'Pick-up') {
                            Navigator.of(context).push(_orderSummaryPickupGoods(widget.ticket, widget.ticketId)).then((val)=>{onRefresh()});
                          } else if (widget.mop == 'Delivery') {
                            Navigator.of(context).push(_orderSummaryDeliveryGoods(widget.ticket, widget.ticketId)).then((val)=>{onRefresh()});
                          }
                        }
                      },
                      style: SleekButtonStyle.flat(
                        color: Colors.green[400],
                        inverted: false,
                        rounded: false,
                        size: SleekButtonSize.normal,
                        context: context,
                      ),
                      child: Center(
                        child: Text("NEXT",
                          style:GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 16.0,
                            shadows: [
                              Shadow(
                                blurRadius: 1.0,
                                color: Colors.black54,
                                offset: Offset(1.0, 1.0),
                              ),
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