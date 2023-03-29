import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arush/profile/addNewAddress.dart';
import 'package:arush/submit_order_paymaya.dart';
import 'package:arush/submit_paymaya.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'db_helper.dart';
import 'create_account_signin.dart';
import 'package:intl/intl.dart';
import 'package:sleek_button/sleek_button.dart';
import 'discountManager.dart';
import 'track_order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class SubmitOrder extends StatefulWidget {
  final paymentMethod;
  final deliveryDateData;
  final deliveryTimeData;
  final getTenantData;
  final getTenantNameData;
  final getBuNameData;
  final subtotal;
  final grandTotal;
  final specialInstruction;
  final deliveryCharge;
  final productID;

  SubmitOrder(
      {Key key,
      @required
        this.paymentMethod,
        this.deliveryDateData,
        this.deliveryTimeData,
        this.getTenantData,
        this.getTenantNameData,
        this.getBuNameData,
        this.subtotal,
        this.grandTotal,
        this.specialInstruction,
        this.deliveryCharge,
        this.productID,
      })
      : super(key: key);

  @override
  _SubmitOrder createState() => _SubmitOrder();
}

class _SubmitOrder extends State<SubmitOrder> with TickerProviderStateMixin {
  var amountTender = TextEditingController();
  final changeFor = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();


  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;
  bool exist = false;

  List loadCartData = [];
  List getBu;
  List getTenant;
  List getItemsData;
  List placeOrder;
  List getItemsData2;
  List getTotalAmount;
  List loadIdList;

  List<String> productName = [];
  List<String> price = [];
  List<String> quantity = [];
  List<String> totalPrice = [];
  List<bool> subTotalTenant = [];
  List<bool> locGroupID = [];

  String placeOrderTown;
  String placeOrderProvince;
  String placeOrderBrg;
  String placeContactNo;
  String placeRemarks;
  String street;
  String userName;
  String houseNo;
  String comma;
  String separator;
  String groupID;

  String results;
  String min;

  double deliveryCharge = 0.00;
  double grandTotal = 0.0;
  double minimumAmount = 0.0;
  double subAmt = 0.00;
  double amt;
  int sub;
  int shipping;

  var subtotal = 0.0;
  var townId, barrioId;
  var stores;
  var items;



  AnimationController controller;

  void initController(){
    // controller = BottomSheet.createAnimationController(this);
    // controller.duration = const Duration(milliseconds: 5);
    // controller.reverseDuration = const Duration(milliseconds: 5);
    controller = BottomSheet.createAnimationController(this);
    // Animation duration for displaying the BottomSheet
    controller.duration = const Duration(milliseconds: 500);
    // Animation duration for retracting the BottomSheet
    controller.reverseDuration = const Duration(milliseconds: 500);
    // Set animation curve duration for the BottomSheet
    controller.drive(CurveTween(curve: Curves.easeIn));
  }

  _placeOrder() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('street', widget.street);
    // prefs.setString('houseNo', widget.houseNo);
    // prefs.setString('houseNo', widget.houseNo);
    // prefs.setString('placeRemark', widget.placeRemark);

    // await db.placeOrder(
    //   widget.deliveryDateData,
    //   widget.deliveryTimeData,
    //   widget.getTenantData,
    //   widget.specialInstruction,
    //   deliveryCharge,
    //   oCcy.parse(amountTender.text),
    //   widget.productID
    // );

    await db.placeOrder2(
        widget.deliveryDateData,
        widget.deliveryTimeData,
        widget.getTenantData,
        widget.specialInstruction,
        deliveryCharge,
        oCcy.parse(amountTender.text),
        widget.productID
    );
    print(widget.specialInstruction);
  }

  Future getPlaceOrderData() async{
    var res = await db.getPlaceOrderData();
    if (!mounted) return;
    setState(() {
      locGroupID.clear();
      placeOrder = res['user_details'];
      deliveryCharge = double.parse(placeOrder[0]['d_charge_amt']);
      townId = placeOrder[0]['d_townId'];
      barrioId = placeOrder[0]['d_brgId'];
      placeOrderTown = placeOrder[0]['d_townName'];
      placeOrderProvince = placeOrder[0]['d_province'];
      placeOrderBrg = placeOrder[0]['d_brgName'];
      placeContactNo = placeOrder[0]['d_contact'];
      placeRemarks = placeOrder[0]['land_mark'];
      street = placeOrder[0]['street_purok'];
      userName = ('${placeOrder[0]['firstname']} ${placeOrder[0]['lastname']}');
      grandTotal = deliveryCharge + widget.subtotal;
      min = placeOrder[0]['minimum_order_amount'];
      minimumAmount = oCcy.parse(min);
      getTenantSegregate();
      for(int q=0;q<placeOrder.length;q++){
        bool result = placeOrder[q]['d_groupID'] == groupID ;
        locGroupID.add(result);
        print(result);
      }
      amountTender.text = (oCcy.format(grandTotal).toString());
      changeFor.text = "0.00";
      getTotal2();

    });
    isLoading = false;
    print('ayaw kol');
    print(minimumAmount);
  }

  // Future getTotal() async {
  //   var res = await db.getAmountPerTenant();
  //   if (!mounted) return;
  //   setState(() {
  //     subTotalTenant.clear();
  //     getTotalAmount = res['user_details'];
  //     for(int q=0;q<getTotalAmount.length;q++){
  //       bool result = double.parse(getTotalAmount[q]['total']) < minimumAmount;
  //       subTotalTenant.add(result);
  //       subAmt = double.parse(getTotalAmount[q]['total']);
  //       // sub = int.parse(subAmt);
  //       if (subAmt < minimumAmount){
  //         results ='false';
  //       } else {
  //         results ='true';
  //       }
  //       print(getTotalAmount[q]['total']);
  //     }
  //     isLoading = false;
  //   });
  //   print('ayaw ante');
  // }

  Future getTotal2() async {
    var res = await db.getAmountPerTenant2(widget.productID);
    if (!mounted) return;
    setState(() {
      subTotalTenant.clear();
      getTotalAmount = res['user_details'];
      for(int q=0;q<getTotalAmount.length;q++){
        bool result = double.parse(getTotalAmount[q]['total']) < minimumAmount;
        subTotalTenant.add(result);
        subAmt = double.parse(getTotalAmount[q]['total']);
        // sub = int.parse(subAmt);
        if (subAmt < minimumAmount){
          results ='false';
        } else {
          results ='true';
        }
        print(getTotalAmount[q]['total']);
      }
      isLoading = false;
    });
    print('ayaw ante');
  }

  Future onRefresh() async {
    print('ni refresh nah');
    // loadCart();
    loadCart2();
    getBuSegregate2();
    getPlaceOrderData();
    loadId();
    getBuSegregate();
  }

  // Future loadCart() async {
  //   var res = await db.loadCartData();
  //   if (!mounted) return;
  //   setState(() {
  //     loadCartData = res['user_details'];
  //     items = loadCartData.length;
  //     isLoading = false;
  //   });
  // }

  Future loadCart2() async {
    var res = await db.loadCartData2(widget.productID);
    if (!mounted) return;
    setState(() {

      loadCartData = res['user_details'];
      items = loadCartData.length;
      isLoading = false;
    });
  }


  Future checkIfHasId() async{
    var res = await db.checkIfHasId();
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        exist = true;
      }else{
        exist = false;
      }
    });
  }

  Future loadId() async{
    var res = await db.displayId();
    if (!mounted) return;
    setState(() {
      loadIdList = res['user_details'];
      isLoading = false;
    });
    print('load id');
    print(selectedDiscountType);
  }

  void change(String amount){
    print(amount);
    amt = double.parse(amount);
    // amountTender.text = oCcy.format(amt).toString();
    if(amt < grandTotal) {
      print('insufficient amount');
      changeFor.text = '';
    } else {
      double change = amt - grandTotal;
      changeFor.text = oCcy.format(change).toString();
      print(change);
    }
  }

  insufficientAmount () {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      text: "Amount tender is lesser than your total payable",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      onConfirmBtnTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String username = prefs.getString('s_customerId');
        if (username == null) {
          // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
          Navigator.of(context).push(_signIn()).then((value) => {onRefresh()});
        }
        if (username != null) {
          Navigator.of(context).pop();
        }
      },
    );
  }


  placeOrderNow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if (username == null) {
      // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
      Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
    } else if(amountTender.text.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
            title: Text(
              "Notice!",
              style: TextStyle(fontSize: 18.0),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[

                  Padding(
                    padding:EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                    child: Text("Some fields is invalid or empty"),
                  ),
                ],
              ),
            ),
            actions: <Widget>[

              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.deepOrange,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      _placeOrder();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Thank you for using Alturush",
        confirmBtnColor: Colors.deepOrangeAccent,
        backgroundColor: Colors.deepOrangeAccent,
        barrierDismissible: false,
        onConfirmBtnTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String username = prefs.getString('s_customerId');
          if (username == null) {
            // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
            Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
          }
          if (username != null) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(_trackOrder());
          }
        },
      );
    }
  }

  Future getLastOrder() async {
//    await db.placeOrder(widget.townId.toString(),widget.barrioId.toString(),widget.contactNo,widget.placeRemark,widget.houseNo,widget.changeFor,widget.street);
//    var res = await model.getLastOrder();
//    if (!mounted) return;
//    setState(() {
//      list = res;
//    });
//
//    var res1 = await model.getLastItems(list[0]['d_ticket_id']);
//    if (!mounted) return;
//    setState(() {
//      list1 = res1;
//      print(list1);
//      isLoading = false;
//    });
  }

  Future getBuSegregate() async {
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      for (int i=0; i<getBu.length; i++) {
        groupID = getBu[i]['d_bu_group_id'];
        // print(groupID);
        displayAdd(groupID);
      }
      print(getBu);
    });
  }

  Future displayAdd(id) async {
    var res = await db.displayAddresses(id);
    if (!mounted) return;
    setState(() {
      getItemsData = res['user_details'];
      for(int q = 0;q<getItemsData.length;q++) {
        if (getItemsData[q]['shipping'] == '1') {
          shipping = q;
        }
      }
    });
  }

  Future displayAddresses(context) async{
    print(groupID);
    displayAdd(groupID);
    return showModalBottomSheet(
      transitionAnimationController: controller,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
          return Container(
            height: MediaQuery.of(context).size.height  * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15), topLeft: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text("Select your address",
                        style: GoogleFonts.openSans(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                      ),

                      OutlinedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10))),
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          overlayColor: MaterialStateProperty.all(Colors.black12),
                          side: MaterialStateProperty.all(BorderSide(
                            color: Colors.deepOrangeAccent,
                            width: 1.0,
                            style: BorderStyle.solid),
                          ),
                        ),
                        onPressed:(){
                          Navigator.pop(context);
                          Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new AddNewAddress())).then((val)=>{onRefresh()});
                          refreshKey.currentState.show();
                        },
                        child:Text("+ Add new",
                          style: GoogleFonts.openSans(color:Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: getItemsData == null ? 0 : getItemsData.length,
                      itemBuilder: (BuildContext context, int index) {

                        return InkWell(
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: RadioListTile(
                              visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity,
                              ),
                              contentPadding: EdgeInsets.only(left: 10),
                              activeColor: Colors.deepOrange,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text('${getItemsData[index]['firstname']} ${getItemsData[index]['lastname']}',
                                          style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Text('${getItemsData[index]['street_purok']}, ${getItemsData[index]['d_brgName']}, \n${getItemsData[index]['d_townName']}, '
                                          '${getItemsData[index]['zipcode']}, ${getItemsData[index]['d_province']}',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text('${getItemsData[index]['d_contact']}',
                                      style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.normal, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              value: index,
                              groupValue: shipping,
                              onChanged: (newValue) async {
                                state((){
                                  // getPlaceOrderData();
                                  if (getItemsData[index]['d_groupID'] != groupID){
                                    CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      text: "Unsupported address for delivery choose another address",
                                      confirmBtnColor: Colors.deepOrangeAccent,
                                      backgroundColor: Colors.deepOrangeAccent,
                                      barrierDismissible: false,
                                      onConfirmBtnTap: () async {
                                        // subTotalTenant.clear();
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  } else {
                                    shipping = newValue;
                                    updateDefaultShipping(getItemsData[index]['id'],getItemsData[index]['d_customerId']);
                                    Future.delayed(const Duration(milliseconds: 200), () {
                                      setState(() {
                                        // getPlaceOrderData();
                                        Navigator.pop(context);
                                      });
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      }
    );
  }

  updateDefaultShipping(id,customerId) async{
    await db.updateDefaultShipping(id,customerId);
  }

  void displayOrder(tenantId) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height: 50.0, // Change as per your requirement
            width: 10.0, // Change as per your requirement
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            ),
          ),
        );
      },
    );

    var res = await db.displayOrder(tenantId);
    if (!mounted) return;
    setState(() {
      getItemsData = res['user_details'];
      Navigator.of(context).pop();
    });

    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height: 250.0, // Change as per your requirement
            width: 310.0, // Change as per your requirement
            child: Scrollbar(
              child: ListView.builder(
//                  physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getItemsData == null ? 0 : getItemsData.length,
                itemBuilder: (BuildContext context, int index) {
                  var f = index;
                  f++;
                  return ListTile(
                    title: Text('$f. ${getItemsData[index]['d_prodName']} ₱${getItemsData[index]['d_price']} x ${getItemsData[index]['d_quantity']}',
                      style: TextStyle(fontSize: 15.0),
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
                  color: Colors.deepOrange,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future getTenantSegregate() async {
    var res = await db.getTenantSegregate();
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];
      isLoading = false;
      // stores = getTenant.length;
      // print(getTenant);
    });
  }

  Future getBuSegregate2() async {
    var res = await db.getBuSegregate2(widget.productID);
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      stores = getBu.length;
    });
  }

  void removeDiscountId(discountID) async {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.warning,
      text: "Are you sure you want to remove this ID?",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      showCancelBtn: true,
      cancelBtnText: 'Cancel',
      onCancelBtnTap: () async {
        Navigator.of(context, rootNavigator: true).pop();
      },
      confirmBtnText: 'Proceed',
      onConfirmBtnTap: () async {
        print(discountID);
        Navigator.of(context, rootNavigator: true).pop();
        await db.deleteDiscountID(discountID);
        loadId();
      },
    );
  }

  @override
  void initState() {
    selectedDiscountType.clear();
    onRefresh();
    super.initState();
    print(widget.specialInstruction);
    getPlaceOrderData();
    getLastOrder();
    getTenantSegregate();
    getBuSegregate2();
    checkIfHasId();
    changeFor.text = '0.00';
    initController();
    print('dali ari');
    print(widget.productID);
    getTotal2();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    changeFor.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
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
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Summary (Delivery)",
            style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),
        body: isLoading ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) :
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Form(
                key: _formKey,
                child: RefreshIndicator(
                  color: Colors.deepOrangeAccent,
                  key: refreshKey,
                  onRefresh: onRefresh,
                  child: Scrollbar(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[

                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[300],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                child: new Text("DELIVERY ADDRESS",
                                  style: GoogleFonts.openSans(color: Colors.white, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 14.0),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 15, 0),
                                child: SizedBox(
                                  height: 30,
                                  width: 175,
                                  child: OutlinedButton.icon(
                                    onPressed: () async{
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String username = prefs.getString('s_customerId');
                                      if(username == null){
                                        Navigator.of(context).push(_signIn()).then((value) => {onRefresh()});
                                      }else{
                                        getPlaceOrderData();
                                        displayAddresses(context).then((_) => {onRefresh()});
                                      }
                                    },
                                    label: Text('MANAGE ADDRESS',
                                      style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 12.0, color: Colors.deepOrangeAccent),
                                    ),
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                      backgroundColor: MaterialStateProperty.all(Colors.white),
                                      overlayColor: MaterialStateProperty.all(Colors.black12),
                                      side: MaterialStateProperty.all(BorderSide(
                                        color: Colors.deepOrangeAccent,
                                        width: 1.0,
                                        style: BorderStyle.solid),
                                      ),
                                    ),
                                    icon: Wrap(
                                      children: [
                                        Icon(Icons.settings_outlined, color: Colors.deepOrangeAccent, size: 18,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 5.0),
                          child: Row(
                            children: <Widget>[
                              Text("Recipient: ",
                                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black54),
                              ),
                              Text("${userName.toString()}",
                                style: TextStyle(fontSize: 14.0, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                          child: Row(
                            children: <Widget>[
                              Text("Contact Number: ",
                                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black54),
                              ),
                              Text("${placeContactNo.toString()}",
                                style: TextStyle(fontSize: 14.0, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                          child: Row(
                            children: <Widget>[
                              Text("Address: ",
                                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black54),
                              ),
                              Flexible(
                                child: Text("$street, $placeOrderBrg, $placeOrderTown, $placeOrderProvince",
                                  style: TextStyle(fontSize: 14.0, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: Row(
                            children: <Widget>[
                              Text("Landmark: ",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black54),
                              ),
                              Flexible(
                                child: Text("${placeRemarks.toString()}",
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14.0, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 5,
                        ),

                        Container(
                          height: 40,
                          color: Colors.grey[200],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.zero,
                                child: Text("TOTAL SUMMARY",
                                  style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('No. of Store(s)',
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text('$stores',
                                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('No. of Item(s)',
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text('$items',
                                style: TextStyle(fontSize: 14.0, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount Order',
                                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text('₱ ${oCcy.format(widget.subtotal)}',
                                style: TextStyle(fontSize: 13.0, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Delivery  Fee",
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text('₱ ${oCcy.format(deliveryCharge)}',
                                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          height: 40,
                          color: Colors.grey[200],
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TOTAL AMOUNT TO PAY',
                                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
                                ),
                                Text('₱ ${oCcy.format(grandTotal)}',
                                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('PAYMENT METHOD',
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text('Pay via CASH ON DELIVERY (COD)',
                                style: TextStyle(fontSize: 13.0, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('AMOUNT TENDER',
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              SizedBox(
                                width: 175,
                                height: 35,
                                child: new TextFormField(
                                  onTap: () {
                                    amountTender.clear();
                                    changeFor.clear();
                                  },
                                  textAlign: TextAlign.end,
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange,
                                  controller: amountTender,
                                  style: TextStyle(fontSize: 13),
                                  onChanged: (value)  => change(value),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      CoolAlert.show(
                                        context: context,
                                        type: CoolAlertType.error,
                                        text: "Please enter amount",
                                        confirmBtnColor: Colors.deepOrangeAccent,
                                        backgroundColor: Colors.deepOrangeAccent,
                                        barrierDismissible: false,
                                        confirmBtnText: 'Okay',
                                        onConfirmBtnTap: () async {
                                          Navigator.of(context, rootNavigator: true).pop();
                                        },
                                      );
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    // prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.deepOrange,
                                        width: 2.0,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3.0),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 50,
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('CHANGE',
                                  style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                                SizedBox(
                                  width: 175,
                                  child: TextFormField(
                                    textAlign: TextAlign.end,
                                    enabled: false,
                                    cursorColor: Colors.deepOrange,
                                    controller: changeFor,
                                    style: TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      // prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                      focusedBorder:OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.deepOrange,
                                          width: 2.0,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        Container(
                          height: 40,
                          color: Colors.deepOrange[300],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: new Text("APPLY DISCOUNT",
                                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.white),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(right: 15),
                                child: SizedBox(
                                  height: 30,
                                  width: 175,
                                  child: OutlinedButton.icon(
                                    onPressed: () async{
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String username = prefs.getString('s_customerId');
                                      if(username == null){
                                        Navigator.of(context).push(_signIn()).then((val) => {onRefresh()});
                                      } else {
                                        showApplyDiscountDialog(context).then((_) => {onRefresh()});
                                      }
                                    },
                                    label: Text('MANAGE DISCOUNT',
                                      style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 12.0, color: Colors.deepOrangeAccent),
                                    ),
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                      backgroundColor: MaterialStateProperty.all(Colors.white),
                                      overlayColor: MaterialStateProperty.all(Colors.black12),
                                      side: MaterialStateProperty.all(BorderSide(
                                        color: Colors.deepOrangeAccent,
                                        width: 1.0,
                                        style: BorderStyle.solid),
                                      ),
                                    ),
                                    icon: Wrap(
                                      children: [
                                        Icon(Icons.settings_outlined, color: Colors.deepOrangeAccent, size: 18.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        RefreshIndicator(
                          color: Colors.deepOrangeAccent,
                          onRefresh: loadId,
                          child: Scrollbar(
                            child: ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                exist == false ? Padding(
                                  padding: EdgeInsets.only(left: 10, top: 5),
                                  child: Text('No Discount Details',
                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ) : ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: loadIdList == null ? 0 : loadIdList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    var q = index;
                                    q++;
                                    if (selectedDiscountType.isEmpty){

                                      side.insert(index, false);
                                    }
                                    // side.add(false);
                                    return Container(
                                      height: 85.0,
                                      child: Column(
                                        children: <Widget>[
                                          ListTile(
                                            contentPadding: EdgeInsets.all(0),
                                            title: Column(
                                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [

                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [

                                                      Row(
                                                        children: [

                                                          Padding(
                                                            padding: EdgeInsets.only(left: 5),
                                                            child: CachedNetworkImage(
                                                              imageUrl: loadIdList[index]['d_photo'],
                                                              fit: BoxFit.contain,
                                                              imageBuilder: (context, imageProvider) => Container(
                                                                height: 55,
                                                                width: 55,
                                                                decoration: new BoxDecoration(
                                                                  image: new DecorationImage(
                                                                    image: imageProvider,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                  borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                                                  border: new Border.all(
                                                                    color: Colors.deepOrangeAccent,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                              placeholder: (context, url,) => const CircularProgressIndicator(color: Colors.grey,),
                                                              errorWidget: (context, url, error) => Container(
                                                                height: 55,
                                                                width: 55,
                                                                decoration: new BoxDecoration(
                                                                  image: new DecorationImage(
                                                                    image: AssetImage("assets/png/No_image_available.png"),
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                  borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                                                  border: new Border.all(
                                                                    color: Colors.deepOrangeAccent,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                          Padding(
                                                            padding: EdgeInsets.only(left: 15),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('Name: ${loadIdList[index]['name']} ',
                                                                  style: GoogleFonts.openSans(fontSize: 14, color: Colors.black87),
                                                                ),
                                                                Text('Discount Type: (${loadIdList[index]['discount_name']})',
                                                                  style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54),
                                                                ),
                                                                Text('ID Number: ${loadIdList[index]['discount_no']}',
                                                                  style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      SizedBox(
                                                        width: 25,
                                                        child: RawMaterialButton(
                                                          onPressed:
                                                              () async {
                                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                                            String username = prefs.getString('s_customerId');
                                                            if (username == null) {
                                                              await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                                                            } else {
                                                              removeDiscountId(loadIdList[index]['id']);
                                                            }
                                                          },
                                                          elevation: 1.0,
                                                          child: Icon(
                                                            CupertinoIcons.delete, size: 25.0,
                                                            color: Colors.redAccent,
                                                          ),
                                                          shape: CircleBorder(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Divider(color: Colors.black54),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),

            Padding(
              padding:
                EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: SleekButton(
                      onTap: () async {

                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString("s_customerId");
                        if (username == null) {
                          Navigator.of(context).push(_signIn()).then((value) => {onRefresh()});
                        } else {
                          setState(() {
                            getTotal2();
                            if(subTotalTenant.contains(true)) {
                              print('no');
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.error,
                                text: "Your address didn't reached the minimum amount per tenant",
                                confirmBtnColor: Colors.deepOrangeAccent,
                                backgroundColor: Colors.deepOrangeAccent,
                                barrierDismissible: false,
                                onConfirmBtnTap: () async {
                                  // subTotalTenant.clear();
                                  Navigator.of(context).pop();
                                },
                              );
                            } else {
                              print('yes');
                              if (_formKey.currentState.validate()){
                                if (widget.grandTotal <=  oCcy.parse(amountTender.text)) {
                                  placeOrderNow();
                                } else if (widget.grandTotal > oCcy.parse(amountTender.text)) {
                                  insufficientAmount();
                                }
                              }
                            }
                          });
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.paperplane, size: 20,
                              shadows: [
                                Shadow(
                                  blurRadius: 1.0,
                                  color: Colors.black54,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                            SizedBox(width: 5),
                            Text("CHECKOUT",
                              style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                shadows: [
                                  Shadow(
                                    blurRadius: 1.0,
                                    color: Colors.black54,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Future showApplyDiscountDialog(BuildContext context) async{
    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: ApplyDiscountDialog()
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {}
    );
  }
}//end of class

class ApplyDiscountDialog extends StatefulWidget {
  @override
  _ApplyDiscountDialogState createState() => _ApplyDiscountDialogState();
}

class _ApplyDiscountDialogState extends State<ApplyDiscountDialog> with SingleTickerProviderStateMixin {
  bool exist = false;
  final db = RapidA();
  bool canUpload = false;
  var isLoading = true;
  List loadIdList;

  Future checkIfHasId() async{
    var res = await db.checkIfHasId();
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        exist = true;
      }else{
        exist = false;
      }
    });
  }

  Future loadID() async{
    var res = await db.displayId();
    if (!mounted) return;
    setState(() {
      loadIdList = res['user_details'];
      isLoading = false;
    });
    print('load id');
    print(selectedDiscountType);
  }

  @override
  void initState() {
    super.initState();
    // loadID();
    checkIfHasId();
    loadID().then((_)=>setState((){}));
    // print(selectedDiscountType);
    // initController();
   // print(widget.productID);
//    print(widget.changeFor+"hello");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        height: 400.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15), topLeft: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      icon: Image.asset('assets/png/img_552316.png',
                      color: Colors.white,
                      fit: BoxFit.contain,
                      height: 30,
                      width: 30,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text("Apply Discount ",
                      style: GoogleFonts.openSans(color: Colors.white,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),
                    ),
                  ),
                ],
              )
            ),

            Container(
              color: Colors.grey[200],
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text("Discount Applied List ",
                      style: GoogleFonts.openSans(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 10, 5),
                    child:OutlinedButton(
                      onPressed: () async{
                        FocusScope.of(context).requestFocus(FocusNode());
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString('s_customerId');
                        if(username == null){
                          // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                          await Navigator.of(context).push(_signIn());
                        }else{
                          showAddDiscountDialog(context).then((_)=>{loadID()});
                          checkIfHasId();
                        }
                      },
                      child: Text('+ ADD',
                        style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 13.0, color: Colors.white),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10))),
                        overlayColor: MaterialStateProperty.all(Colors.black12),
                        backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                        side: MaterialStateProperty.all(BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 0.5,
                          style: BorderStyle.solid),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: Colors.deepOrangeAccent,
                onRefresh: loadID,
                child: Scrollbar(
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    // shrinkWrap: true,
                    children: <Widget>[ListView.builder(
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: loadIdList == null ? 0 : loadIdList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var q = index;
                          q++;
                          if (selectedDiscountType.isEmpty){

                            side.insert(index, false);
                          }
                          // side.add(false);
                          return Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 65,
                                  child:
                                  CheckboxListTile(
                                    visualDensity: const VisualDensity(
                                      horizontal: VisualDensity.minimumDensity,
                                      vertical: VisualDensity.minimumDensity,
                                    ),
                                    contentPadding: EdgeInsets.only(left: 5),
                                    activeColor: Colors.deepOrange,
                                    title: Transform.translate(
                                      offset: const Offset(-5, 1),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Name: ${loadIdList[index]['name']} ',
                                              style: GoogleFonts.openSans(fontSize: 13, color: Colors.black87),
                                            ),
                                            Text('Discount Type: (${loadIdList[index]['discount_name']})',
                                              style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54),
                                            ),
                                            Text('ID #: ${loadIdList[index]['discount_no']}',
                                              style: GoogleFonts.openSans(fontSize: 13, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    value: side[index],
                                    onChanged: (bool value){
                                      setState(() {
                                        side[index] = value;
                                        if (value) {
                                          selectedDiscountType.add(loadIdList[index]['dicount_id']);
                                          print(selectedDiscountType);
                                        } else{
                                          selectedDiscountType.remove(loadIdList[index]['dicount_id']);
                                          print(selectedDiscountType);
                                        }

                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  ),
                                ),
                                Divider(thickness: 2, color: Colors.grey[200]),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Padding(
              padding: EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 100,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(color: Colors.deepOrangeAccent)
                      ),
                    ),
                  ),
                  onPressed:(){
                    for (int i=0;i<selectedDiscountType.length;i++){
                      side[i] = false;
                    }
                    selectedDiscountType.clear();

                    Navigator.pop(context);
                  },
                  child:Text("CLOSE",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 12.0),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 20),
              child: SizedBox(
                width: 100,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.deepOrange[400]),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.deepOrange[400]),
                      ),
                    ),
                  ),
                  onPressed:(){
                    if (selectedDiscountType.isEmpty){
                      print('pili pd discount');
                      Fluttertoast.showToast(
                          msg: "No discount applied!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Colors.black.withOpacity(0.7),
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    } else {
                      print(selectedDiscountType);
                      print('very gud');
                      Navigator.of(context).pop();
                    }
                  },
                  child:Text("APPLY",style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 12.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future showAddDiscountDialog(BuildContext context) async{
    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: new AddDiscountDialog(),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {}
    );
  }
}

class AddDiscountDialog extends StatefulWidget {
  @override
  _AddDiscountDialogState createState() => _AddDiscountDialogState();
}

class _AddDiscountDialogState extends State<AddDiscountDialog> {
  bool exist = false;
  final db = RapidA();
  File _image;
  bool canUpload = false;
  var isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _imageTxt = TextEditingController();
  final _idNumber = TextEditingController();
  final _name = TextEditingController();
  List loadDiscount;
  List loadDiscountID;
  List<String> _loadDiscount = [];
  List<String> _loadDiscountID = [];
  var id;
  var discountID;
  final List<String> genderItems = [
    'Male',
    'Female',
  ];
  String newFileName;
  String selectedValue;
  String discount;
  final picker = ImagePicker();

  Future checkIfHasId() async{
    var res = await db.checkIfHasId();
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        exist = true;
      }else{
        exist = false;
      }
    });
  }

  Future loadId() async{
    var res = await db.displayId();
    if (!mounted) return;
    setState(() {
      loadIdList = res['user_details'];
      isLoading = false;
    });
  }

  Future showDiscount() async{
    var res = await db.showDiscount();
    if (!mounted) return;
    setState(() {
      loadDiscount = res['user_details'];
      for (int i=0;i<loadDiscount.length;i++){
        _loadDiscount.add(loadDiscount[i]['discount_name']);
        _loadDiscountID.add(loadDiscount[i]['id']);
      }
    });
    // print(loadDiscount);
    // print(_loadDiscount);
    // print(_loadDiscountID);
  }

  Future getDiscountID(name) async{
    var res = await db.getDiscountID(name);
    if (!mounted) return;
    setState(() {
      loadDiscountID = res['user_details'];
      print(loadDiscountID[0]['discount_id']);
      discountID = loadDiscountID[0]['discount_id'];
      // print(discountID);
    });
  }


  camera() async{
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        newFileName = _image.toString();
        _imageTxt.text = _image.toString().split('/').last;
      }
    });
  }

  Future uploadId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      await Navigator.of(context).push(_signIn());
    }else{
      loading();
      String base64Image = base64Encode(_image.readAsBytesSync());
      await db.uploadId(discountID,_name.text,_idNumber.text,base64Image);
      Navigator.of(context, rootNavigator: true).pop();
      successMessage();
    }
  }

  loading(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height:50.0, // Change as per your requirement
            width: 10.0, // Change as per your requirement
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            ),
          ),
        );
      },
    );
  }

  successMessage(){
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Discounted ID successfully added",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      onConfirmBtnTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String username = prefs.getString('s_customerId');
        if (username == null) {
          await Navigator.of(context).push(_signIn());
        }
        if (username != null) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadId();
    checkIfHasId();
    showDiscount();
//    print(widget.deliveryDate);
//    print(widget.changeFor+"hello");
  }

  @override
  void dispose() {
    super.dispose();
     _imageTxt.dispose();
     _idNumber.dispose();
     _name.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        height: 400.0,
        width: 300.0,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15), topLeft: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: IconButton(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        icon: Image.asset('assets/png/img_552316.png',
                          color: Colors.white,
                          fit: BoxFit.contain,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text("Apply Discount ",
                        style: GoogleFonts.openSans(color: Colors.white,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Scrollbar(
                  child: ListView(
                    padding: EdgeInsets.only(top: 10),
                    shrinkWrap: true,
                    children: <Widget>[

                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                        child: Text('Discount Type',
                          style: GoogleFonts.openSans(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      SizedBox(height: 40,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              //Add isDense true and zero Padding.
                              //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.deepOrangeAccent.withOpacity(0.8), width: 1),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              //Add more decoration as you want here
                              //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                            ),
                            isExpanded: true,
                            hint: Text(
                              'Select Discount Type', style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black45,
                            ),
                            iconSize: 25,
                            items: _loadDiscount
                              .map((item) =>
                              DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black),
                                ),
                              ))
                                .toList(),
                            // ignore: missing_return
                            validator: (value) {
                              if (value == null) {
                                return 'Please select discount type!';
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value;
                                id = _loadDiscount.indexOf(value);
                                print(id + 1);

                                getDiscountID(selectedValue);
                              });
                              //Do something when changing the item if you want.
                            },
                            onSaved: (value) {
                              selectedValue = value.toString();
                              print(selectedValue);
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: Text('Full Name',
                          style: GoogleFonts.openSans(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      SizedBox(height: 40,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            controller: _name,
                            style: GoogleFonts.openSans(fontSize: 14),
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.7),
                                    width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              hintText: 'Full Name ex. (Lastname, Firstname)',
                              hintStyle: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter some value!';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: Text('ID. Picture',
                          style: GoogleFonts.openSans(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      SizedBox(height: 40,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child:InkWell(
                            onTap: (){
                              FocusScope.of(context).requestFocus(FocusNode());
                              camera();
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                textInputAction: TextInputAction.done,
                                cursorColor: Colors.deepOrange.withOpacity(0.5),
                                controller: _imageTxt,
                                style: GoogleFonts.openSans(fontSize: 14),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please capture an image!';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'No File Choosen',
                                  hintStyle: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                                  contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                                  prefixIcon: Icon(Icons.camera_alt_outlined,color: Colors.grey,),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.5),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: Text('ID. Number',
                          style: GoogleFonts.openSans(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      SizedBox(height: 40,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child:TextFormField(
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            controller: _idNumber,
                            style: GoogleFonts.openSans(fontSize: 14),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter some value!';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'ID. Number',
                              hintStyle: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.7),
                                  width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Padding(
              padding: EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 100,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.deepOrangeAccent),
                      ),
                    ),
                  ),
                  onPressed:(){
                    Navigator.pop(context);
                  },
                  child:Text("CLOSE",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 12.0),),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 20),
              child: SizedBox(
                width: 100,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.deepOrange[400]),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.deepOrange[400]),
                      ),
                    ),
                  ),
                  onPressed:(){
                    if (_formKey.currentState.validate()) {
                      uploadId();
                    }
                    // _name.clear();
                    // _imageTxt.clear();
                    // _idNumber.clear();
                  },
                  child:Text("APPLY",style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 12.0),),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Route _trackOrder() {
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

Route _signIn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        CreateAccountSignIn(),
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

Route addNewAddress() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AddNewAddress(),
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

Route _showDiscountPerson() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => DiscountManager(),
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

