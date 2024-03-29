import 'package:arush/order_summary_pickup_foods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'live_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';

import 'dart:async';

import 'order_summary_delivery_foods.dart';
import 'order_timeframe_delivery_foods.dart';
import 'order_timeframe_pickup_foods.dart';
class ToDeliverFood extends StatefulWidget {
  final pend;
  final ticketNo;
  final mop;
  final type;
  final ticketId;
  ToDeliverFood({Key key, @required this.pend, this.ticketNo,this.mop,this.type, this.ticketId}) : super(key: key);//
  @override
  _ToDeliver createState() => _ToDeliver();
}

class _ToDeliver extends State<ToDeliverFood> with TickerProviderStateMixin{
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final _specialInstruction = new TextEditingController();
  var isLoading = true;
  List loadItems, lookItemsSegregateList, loadItems1;
  List loadTotalAmount;
  List loadTotal, lGetAmountPerTenant, loadSTotal;
  List instructions;

  String specialInstruction;
  String icoos;
  String cancelDetails;
  String tenantID;

  // var delCharge;
  double grandTotal = 0.00;
  var subTotal;
  var deliveryCharge;
  var index = 0;
  var checkDeliveryIfExists;
  var checkTransIfExists;
  var checkCancelledIfExists;
  var checkRemitIfExists;

  Timer timer;

  bool val;
  bool ifCancelled;
  bool hideCancelButton;

  AnimationController controller;

  void initController() {
    controller = BottomSheet.createAnimationController(this);
    // Animation duration for displaying the BottomSheet
    controller.duration = const Duration(milliseconds: 500);
    // Animation duration for retracting the BottomSheet
    controller.reverseDuration = const Duration(milliseconds: 500);
    // Set animation curve duration for the BottomSheet
    controller.drive(CurveTween(curve: Curves.easeIn));
  }

  Future getTotal() async{
    var res = await db.getTotal(widget.ticketId);
    if (!mounted) return;
    setState(() {
      // grandTotal = 0.0;
      loadTotal = res['user_details'];
      grandTotal = double.parse(loadTotal[index]['total_price']);
      subTotal = loadTotal[index]['sub_total'];
      deliveryCharge = loadTotal[index]['delivery_charge'];
      // print(loadTotal);
    });
  }

  bool delivered() {
    if (checkDeliveryIfExists.toLowerCase() == 'true') {

      return true;
    } else if (checkDeliveryIfExists.toLowerCase() == 'false') {
      return false;
    }
    throw '"$this" can not be parsed to boolean.';
  }

  bool delivered2() {
    if (checkDeliveryIfExists.toLowerCase() == 'false') {
      return true;
    } else if (checkDeliveryIfExists.toLowerCase() == 'true') {
      return false;
    }
    throw '"$this" can not be parsed to boolean.';
  }

  bool trans() {
    if (checkTransIfExists.toLowerCase() == 'true') {
      return true;
    } else if (checkTransIfExists.toLowerCase() == 'false') {
      return false;
    }
    throw '"$this" can not be parsed to boolean.';
  }

  bool trans2(checkTransIfExists) {
    if (checkTransIfExists.toLowerCase() == 'true') {
      return false;
    } else if (checkTransIfExists.toLowerCase() == 'false') {
      return true;
    }
    throw '"$this" can not be parsed to boolean.';
  }

  bool cancel() {
    if (checkCancelledIfExists.toLowerCase() == 'true') {
      return true;
    } else if (checkCancelledIfExists.toLowerCase() == 'false') {
      return false;
    }
    throw '"$this" can not be parsed to boolean.';
  }

  bool remitStatus() {
    if (checkRemitIfExists.toLowerCase() == 'true') {
      return true;
    } else if (checkRemitIfExists.toLowerCase() == 'false') {
      return false;
    }
    throw '"$this" can not be parsed to boolean.';
  }

  bool remitStatus2(checkRemitIfExists) {
    if (checkRemitIfExists.toLowerCase() == 'true') {
      return false;
    } else if (checkRemitIfExists.toLowerCase() == 'false') {
      return true;
    }
    throw '"$this" can not be parsed to boolean.';
  }

  Future lookItemsFood() async{
    var res = await db.lookItems(widget.ticketId);
    if (!mounted) return;
    setState(() {
      loadItems = res['user_details'];
      isLoading = false;
      print(loadItems[0]['ifDeliveryExists']);
    });
  }

  Future cancelOrderTenant(tenantID, ticketID) async{
    var res = await db.cancelOrderTenant(tenantID, ticketID);
    if (!mounted) return;
    setState(() {
      print(res);
      onRefresh();
      print('cancelling order');
    });
  }

  Future lookItemsSegregate() async{
    var res = await db.lookItemsSegregate(widget.ticketId);
    if (!mounted) return;
    setState(() {
      lookItemsSegregateList = res['user_details'];
      isLoading = false;
      // print(lookItemsSegregateList);
    });
  }

  Future getTotalAmount() async {
    var res = await db.getTotalAmount(widget.ticketId);
    if (!mounted) return;
    setState(() {
      loadTotalAmount = res['user_details'];
      isLoading = false;
    });

  }

  Future lookItemsGood() async{
    var res = await db.lookItemsGood(widget.ticketId);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadItems1 = res['user_details'];
      // print(loadItems1);
    });
  }


  Future checkIfOnGoing() async{
    var res = await db.checkIfOnGoing(widget.ticketId);
    if (!mounted) return;
    setState(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('s_customerId');
      if(username == null){
        await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
      } else {
        if(res == 'true'){
          Navigator.of(context).push(_viewOrderStatus(widget.ticketId)).then((val)=>{onRefresh()});
        }if(res == 'false'){
          itemNotYetReady();
        }
      }
    });
  }


  Future getSpecialInstructions() async {
    var res = await db.getSpecialInstructions(widget.ticketId);
    if (!mounted) return;
    setState(() {
      instructions = res['user_details'];
      isLoading = false;
    });


    isLoading = false;
  }

  Future cancelOrderSingle(tomsId,ticketId) async{

    await db.cancelOrderSingleFood(tomsId,ticketId);

      await db.cancelOrderSingleFood(tomsId,ticketId);

    // lookItemsGood();
    getTotal();
    // getSubTotal();
  }

  Future onRefresh() async{

    print('refreshed');

    lookItemsSegregate();
    lookItemsFood();
    // setState(() {
    //   if(widget.type == '0') {
    //     lookItemsFood();
    //   }if(widget.type == '1'){
    //     lookItemsGood();
    //   }
    // });
  }

  cancelOrder(tomsId,ticketId) async{
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
                color: Colors.deepOrange,
              ),),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Proceed',style: TextStyle(
                color: Colors.deepOrange,
              ),),
              onPressed: () async{
                cancelOrderSingle(tomsId,ticketId);
                Navigator.of(context).pop();
                cancelSuccess();
              },
            ),
          ],
        );
      },
    );
  }

  viewAddon(BuildContext context,mainItemIndex) {
    showModalBottomSheet(
      transitionAnimationController: controller,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight:  Radius.circular(15),topLeft:  Radius.circular(15)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height  * 0.5,
          child:Container(
            padding: EdgeInsets.all(0),
            child: Scrollbar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.deepOrange[400],
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15), topLeft: Radius.circular(15),
                      ),
                    ),
                    height: 40,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Text("ADD ONS",
                            style: GoogleFonts.openSans(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[

                          ///suggestions
                          ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: loadItems[mainItemIndex]['suggestions'] == null ? 0 : loadItems[mainItemIndex]['suggestions'].length,
                            itemBuilder: (BuildContext context, int index) {
                              // print(loadItems[mainItemIndex]['suggestions']);
                              String price;
                              if (loadItems[mainItemIndex]['suggestions'][index]['addon_price'] == '0.00'){
                                price = "";
                              } else {
                                price = ("₱ ${loadItems[mainItemIndex]['suggestions'][index]['addon_price']}");
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child:Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:[
                                      Expanded(
                                        child: Text('+ ${loadItems[mainItemIndex]['suggestions'][index]['description']}',
                                          style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text('$price', style: TextStyle(fontSize: 14.0)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          //choices
                          ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: loadItems[mainItemIndex]['choices'] == null ? 0 : loadItems[mainItemIndex]['choices'].length,
                            itemBuilder: (BuildContext context, int index) {
                              String price;
                              if (loadItems[mainItemIndex]['choices'][index]['addon_price'] == '0.00'){
                                price = "";
                              } else {
                                price = ("₱ ${loadItems[mainItemIndex]['choices'][index]['addon_price']}");
                              }
                              if(loadItems[mainItemIndex]['choices'][index]['unit_measure'] == null){
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child:Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:[
                                        Expanded(
                                          child: Text('+ ${loadItems[mainItemIndex]['choices'][index]['product_name']}',
                                            style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text('$price', style: TextStyle(fontSize: 14.0)),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child:Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:[
                                      Expanded(
                                        child: Text('+ ${loadItems[mainItemIndex]['choices'][index]['product_name']} ${loadItems[mainItemIndex]['choices'][index]['unit_measure']}',
                                          style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text('$price', style: TextStyle(fontSize: 14.0)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          ///add-ons
                          ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: loadItems[mainItemIndex]['add_ons'].length == null ? 0 : loadItems[mainItemIndex]['add_ons'].length,
                            itemBuilder: (BuildContext context, int index) {
                              if(loadItems[mainItemIndex]['add_ons'][index]['unit_measure'] == null){
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child:Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:[
                                        Expanded(
                                          child: Text('+ ${loadItems[mainItemIndex]['add_ons'][index]['product_name']}',
                                            style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text('₱ ${loadItems[mainItemIndex]['add_ons'][index]['addon_price']}', style: TextStyle(fontSize: 14.0)),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child:Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:[
                                      Expanded(
                                        child: Text('+ ${loadItems[mainItemIndex]['add_ons'][index]['product_name'].toString()} ${loadItems[mainItemIndex]['add_ons'][index]['unit_measure'].toString()}',
                                          style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text('₱ ${loadItems[mainItemIndex]['add_ons'][index]['addon_price'].toString()}', style: TextStyle(fontSize: 14.0)
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
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

  // selectType(){
  //
  //   setState(() {
  //     if(widget.type == '0') {
  //       lookItemsFood();
  //       lookItemsSegregate();
  //     }if(widget.type == '1'){
  //       // lookItemsGood();
  //     }
  //
  //   });
  // }


  itemNotYetReady(){
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal:0.0, vertical: 20.0),
          title: Center(
            child: Container(
              height: 60,
              width: 60,
              child: Image.asset("assets/png/3208749.png"),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child:Center(
                     child:Text("Can't show the rider details unless all the items are ready to deliver.",textAlign: TextAlign.justify, maxLines: 3,style:TextStyle(fontSize: 18.0),),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[

            Padding(
              padding: EdgeInsets.only(right: 5),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.deepOrangeAccent)
                    )
                  )
                ),
                child: Text('CLOSE',style: TextStyle(
                  color: Colors.white,
                ),),
                onPressed: () async{
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        );
      },
    );
  }

  ///change later to true
  bool visible = true;

  @override
  void initState(){
    onRefresh();
    lookItemsSegregate();
    getSpecialInstructions();
    // checkIfOnGoing();
    super.initState();
    lookItemsFood();
    // selectType();
    getTotal();
    getTotalAmount();
    print(widget.ticketId);
    // print(widget.pend);
    // print(widget.mop);
    timer = Timer.periodic(Duration(seconds: 30), (Timer t) => onRefresh());

    // getSubTotal();
    if(widget.mop == 'Pick-up'){
      visible = false;
    }
    initController();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.deepOrangeAccent, // Status bar
            statusBarIconBrightness: Brightness.light ,  // Only honored in Android M and above
          ),
          iconTheme: new IconThemeData(color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 1.0,
                color: Colors.black54,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
          backgroundColor: Colors.deepOrangeAccent,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.white,size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Order Details',
            style: GoogleFonts.openSans(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          actions: <Widget>[

            Visibility(
              visible: visible,
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: IconButton(
                  icon: Image.asset('assets/png/rider_icon.png',
                    fit: BoxFit.contain,
                    height: 30,
                    width: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    checkIfOnGoing();
                  },
                ),
              ),
            ),
          ],
        ),

        body: isLoading ?  Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Expanded(
              child: RefreshIndicator(
                color: Colors.deepOrangeAccent,
                onRefresh: onRefresh,
                child: Scrollbar(
                  child:ListView.builder(
                    itemCount: instructions == null || lookItemsSegregateList == null || loadTotalAmount == null ? 0 : lookItemsSegregateList?.length ?? 0,
                    itemBuilder: (BuildContext context, int index0) {
                      String total;
                      int prepared;

                      double sum;
                      if (int.parse(lookItemsSegregateList[index0]['icoos']) != lookItemsSegregateList.length) {
                        icoos = 'Remove it from my order';
                      } else {
                        icoos = 'Cancel entire order';
                      }
                      // if (lookItemsSegregateList[index0]['cancel_status'] == '1') {
                      //   total = '0.00';
                      // } else
                      if (lookItemsSegregateList[index0]['canceled_status'] == '1'){
                        total = '0.00';
                      } else {
                        total = lookItemsSegregateList[index0]['sumpertenants'];
                      }

                      if (lookItemsSegregateList[index0]['sumpertenants'] == '0.00') {
                        cancelDetails = 'Order(s) has been cancelled.';
                      } else {
                        cancelDetails = '';
                      }

                      if (int.parse(lookItemsSegregateList[index0]['sumprepared']) == 0) {
                        hideCancelButton = true;
                      } else {
                        hideCancelButton = false;
                      }

                      ifCancelled = lookItemsSegregateList[index0]['sumpertenants'] == "0.00" ? true : false;

                      print(lookItemsSegregateList[index0]['sumprepared']);
                      // print(lookItemsSegregateList[index0]['sumpertenants']);
                      String instruction;
                      if (instructions.isEmpty) {
                        instruction ='';
                      } else {
                        instruction = instructions[index0]['instructions'];
                      }
                      // print(lookItemsSegregateList[index0]['tenant_name']);
                      return Container(
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange[300],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text('${lookItemsSegregateList[index0]['tenant_name']} - ${lookItemsSegregateList[index0]['acroname']}',
                                      style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
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
                                            await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                                          } else {
                                            String acroname = lookItemsSegregateList[index0]['acroname'];
                                            String tenantName = lookItemsSegregateList[index0]['tenant_name'];
                                            String tenantId = lookItemsSegregateList[index0]['tenant_id'];
                                            bool res = lookItemsSegregateList[index0]['sumpertenants'] == '0.00' ? true : false;
                                            if (widget.mop == 'Pick-up') {
                                              Navigator.of(context).push(_orderTimeFramePickup(
                                                  widget.ticketNo,
                                                  widget.mop,
                                                  acroname,
                                                  tenantName,
                                                  tenantId,
                                                  res),
                                              ).then((val)=>{onRefresh()});
                                            } else if (widget.mop == 'Delivery') {
                                              Navigator.of(context).push(_orderTimeFrameDelivery(
                                                  widget.ticketNo,
                                                  widget.ticketId,
                                                  widget.mop,
                                                  acroname,
                                                  tenantName,
                                                  tenantId,
                                                  res),
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
                                  )
                                ],
                              ),
                            ),

                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange[200],
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Text('Item Ordered',
                                    style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                  ),

                                  Row(
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 40),
                                        child: Text('Status',
                                          style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                        ),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text('Price',
                                          style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            ListView.builder(
                              physics:  NeverScrollableScrollPhysics (),
                              shrinkWrap: true,
                              itemCount:loadItems == null ? 0 : loadItems.length,
                              itemBuilder: (BuildContext context, int index) {
                                checkTransIfExists = loadItems[index]['ifTransExists'];
                                checkDeliveryIfExists = loadItems[index]['ifDeliveryExists'];
                                checkCancelledIfExists = loadItems[index]['ifCancelExists'];
                                checkRemitIfExists = loadItems[index]['ifRemitExists'];
                                print(loadItems[index]['ifRemitExists']);
                                // print(checkTransIfExists);

                                return Visibility(
                                  visible: loadItems[index]['tenant_id'] != lookItemsSegregateList[index0]['tenant_id'] ? false : true,
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
                                                      imageUrl: loadItems[index]['prod_image'],
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
                                                      child: Text("₱ ${loadItems[index]['product_price']}",
                                                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black54),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Expanded(
                                                child:Column(
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
                                                                text: '${loadItems[index]['prod_name']}',
                                                                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        Row(
                                                          children: [
                                                            Visibility(
                                                              visible:  trans2(checkTransIfExists) && loadItems[index]['tag_pickup'] == '0' &&  remitStatus2(checkRemitIfExists) && loadItems[index]['canceled_status'] == '0' ? true : false,
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
                                                                )
                                                              ),
                                                            ),

                                                            Visibility(
                                                              visible: remitStatus2(checkRemitIfExists) && loadItems[index]['tag_pickup'] == '1' &&  loadItems[index]['canceled_status'] == '0'? true : false,
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
                                                                  )
                                                              ),
                                                            ),

                                                            Visibility(
                                                              visible: delivered2() && remitStatus() && loadItems[index]['canceled_status'] == '0' ? true : false,
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
                                                                )
                                                              ),
                                                            ),

                                                            Visibility(
                                                              visible: cancel() || loadItems[index]['canceled_status'] == '1' ? true : false,
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

                                                            Visibility(
                                                              visible: delivered2() && loadItems[index]['canceled_status'] == '0' && trans() ? true : false,
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                                                child: Container(height: 25, width: 60,
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
                                                                    child:Text("In transit", style: TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.normal)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            Visibility(
                                                              visible: delivered()  && loadItems[index]['canceled_status'] == '0' ? true : false,
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                                child: Container(height: 25, width: 65,
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
                                                                    child:Text("Delivered", style: TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.normal)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            Container(
                                                              width: 70,
                                                              padding: EdgeInsets.fromLTRB(0, 2, 10, 0),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: [
                                                                  Text("₱ ${loadItems[index]['total_price']}",
                                                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black87),
                                                                  ),
                                                                ],
                                                              )
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(5, 5, 15, 5),
                                                          child: Text('Quantity: ${loadItems[index]['d_qty']}',
                                                            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Visibility(
                                                          // visible: loadItems[index]['addon_length'] == 0 ? false : true,
                                                          visible: loadItems[index]['addon_length'] > 0 ? true : false,
                                                          child: Padding(
                                                            padding:EdgeInsets.fromLTRB(5, 0, 0, 0),
                                                            child:Container(
                                                              width: 60.0,
                                                              child: SizedBox(
                                                                height: 30,
                                                                child: TextButton(
                                                                  style: ButtonStyle(
                                                                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                      RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(20.0),
                                                                        side: BorderSide(color: Colors.deepOrangeAccent)
                                                                      )
                                                                    ),
                                                                  ),
                                                                  child:Text('${loadItems[index]['addon_length'].toString()}  more',
                                                                      style: TextStyle(fontSize: 12.0, color: Colors.deepOrangeAccent)),
                                                                  onPressed: ()async {
                                                                    viewAddon(context, index);
                                                                  },
                                                                ),
                                                              )
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      elevation: 0,
                                      margin: EdgeInsets.all(3),
                                    ),
                                  ),
                                );
                              }
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

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('IN CASE PRODUCT IS OUT OF STOCK:',
                                style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$icoos',
                                    style: TextStyle(fontSize: 13, color: Colors.black87),
                                  ),

                                  Visibility(
                                    visible: ifCancelled,
                                    child: SizedBox(
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
                                        child:Text("$cancelDetails",
                                          style: TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
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
                                cursorColor: Colors.deepOrange,
                                style: GoogleFonts.openSans(color: Colors.black54, fontSize: 13),
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

                            Visibility(
                              visible: ifCancelled == false && hideCancelButton,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: SizedBox(
                                        height: 35,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            print(lookItemsSegregateList[index0]['tenant_id']);
                                            tenantID = lookItemsSegregateList[index0]['tenant_id'];
                                            CoolAlert.show(
                                                context: context,
                                                showCancelBtn: true,
                                                type: CoolAlertType.warning,
                                                text: "Are you sure?",
                                                confirmBtnColor: Colors.deepOrangeAccent,
                                                backgroundColor: Colors.deepOrangeAccent,
                                                barrierDismissible: false,
                                                confirmBtnText: 'Yes',
                                                onConfirmBtnTap: () async {
                                                  Navigator.of(context).pop();
                                                  setState(() {
                                                    cancelOrderTenant(tenantID, widget.ticketId);
                                                  });
                                                },
                                                cancelBtnText: 'Cancel',
                                                onCancelBtnTap: () async {
                                                  Navigator.of(context).pop();
                                                }
                                            );
                                            // cancelOrderTenant(tenantID, widget.ticketId);
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
                                          child:Text("CANCEL ORDER(S)", style: GoogleFonts.openSans(color: Colors.white, fontSize: 13, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
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
                          await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                        } else {
                          if (widget.mop == 'Pick-up') {
                            Navigator.of(context).push(_orderSummaryPickup(widget.ticketNo, widget.ticketId)).then((val)=>{onRefresh()});
                          } else if (widget.mop == 'Delivery') {
                            Navigator.of(context).push(_orderSummaryDelivery(widget.ticketNo, widget.ticketId)).then((val)=>{onRefresh()});
                          }
                        }
                      },
                      style: SleekButtonStyle.flat(
                        color: Colors.deepOrange[400],
                        inverted: false,
                        rounded: false,
                        size: SleekButtonSize.normal,
                        context: context,
                      ),
                      child: Center(
                        child: Text("NEXT",
                          style:GoogleFonts.openSans(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 16.0,
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

Route _viewOrderStatus(ticketId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ViewOrderStatus(ticketId:ticketId),
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

Route _orderTimeFramePickup(ticketNo, mop, acroname, tenantName, tenantId, ifCancelled) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OrderTimeFramePickupFoods(
        ticketNo    :ticketNo,
        mop         :mop,
        acroname    :acroname,
        tenantName  :tenantName,
        tenantId    :tenantId,
        ifCancelled : ifCancelled),
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

Route _orderTimeFrameDelivery(ticketNo, ticketId, mop, acroname, tenantName, tenantId, ifCancelled) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OrderTimeFrameDeliveryFoods(
      ticketNo    : ticketNo,
      ticketId    : ticketId,
      mop         : mop,
      acroname    : acroname,
      tenantName  : tenantName,
      tenantId    : tenantId,
      ifCancelled : ifCancelled),
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

Route _orderSummaryPickup(ticketNo, ticketId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OrderSummaryPickupFoods(
        ticketNo:ticketNo,
        ticketId:ticketId),
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

Route _orderSummaryDelivery(ticketNo, ticketId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => OrderSummaryDeliveryFoods(ticketNo:ticketNo, ticketId:ticketId),
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
