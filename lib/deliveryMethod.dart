import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'submit_delivery.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'discountManager.dart';
import 'profile/addNewAddress.dart';
import 'create_account_signin.dart';

class PlaceOrderDelivery extends StatefulWidget {

  final paymentMethod;
  final tempID;

  const PlaceOrderDelivery({Key key, this.paymentMethod, this.tempID}) : super(key: key);
  @override
  _PlaceOrderDelivery createState() => _PlaceOrderDelivery();
}

class _PlaceOrderDelivery extends State<PlaceOrderDelivery> with SingleTickerProviderStateMixin {
  final db = RapidA();
  final oCcy                = new NumberFormat("#,##0.00", "en_US");
  final changeFor           = TextEditingController();
  final placeOrderTown      = TextEditingController();
  final userName            = TextEditingController();
  final placeOrderBrg       = TextEditingController();
  final placeContactNo      = TextEditingController();
  final placeRemarks        = TextEditingController();
  // final specialInstruction  = TextEditingController();
  final street              = TextEditingController();
  final houseNo             = TextEditingController();
  final deliveryDate        = TextEditingController();
  final deliveryTime        = TextEditingController();
  final discount            = TextEditingController();
  final _deliveryTime       = TextEditingController();
  final _deliveryDate       = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  List<String> _option            = ['Cancel Item','Cancel Order'];
  List<String> specialInstruction = [];
  List<String> getAcroNameData    = [];
  List<String> deliveryDateData   = [];
  List<String> deliveryTimeData   = [];
  List<String> special            = [];
  List<String> getTenantData      = [];
  List<String> getBuNameData      = [];
  List<String> getTenantNameData  = [];
  List<String> icoos              = [];

  List<TextEditingController> _specialInstruction = [];
  // List<TextEditingController>  _deliveryTime      = [];
  // List<TextEditingController> _deliveryDate       = [];

  List getTenant = [];
  List getItemsData = [];
  List displayAddOnsData = [];
  List placeOrder = [];
  List getBu = [];
  List checkFee = [];
  List loadDiscountedPerson = [];
  List loadCartData = [];
  List loadIMainItems = [];
  List trueTime;

  String selectedValue;
  String minimum;
  String min;
  String option;
  String datePicker ="";
  String timePicker ="";

  double deliveryCharge = 0.00;
  double delivery = 0.00;
  double grandTotal     = 0.0;
  double minimumAmount  = 0.0;
  double amountPT = 0.00;

  var subtotal  = 0.0;
  var isLoading = true;
  var townId,townName,barrioId,brgName,contact;
  var timeCount;
  var _globalTime,_globalTime2;
  var _today;
  var items;
  var stores;
  var stock;
  var lt = 0;

  int tenantNo;

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

  Future getPlaceOrderData() async{
    getTrueTime();
    // loadTotal();
    // var res = await db.loadSubTotal();
    // if (!mounted) return;
    // setState(() {
    //   loadTotalData = res['user_details'];
    //   subtotal = double.parse(loadTotalData[0]['grand_total'].toString());
    // });

    var res1 = await db.getPlaceOrderData();
    if (!mounted) return;
    setState(() {

      placeOrder = res1['user_details'];
      deliveryCharge = double.parse(placeOrder[0]['d_charge_amt']);
      townId = placeOrder[0]['d_townId'];
      barrioId = placeOrder[0]['d_brgId'];
      placeOrderTown.text = placeOrder[0]['d_townName'];
      placeOrderBrg.text = placeOrder[0]['d_brgName'];
      placeContactNo.text = placeOrder[0]['d_contact'];
      placeRemarks.text = placeOrder[0]['land_mark'];
      street.text = placeOrder[0]['street_purok'];
      houseNo.text = placeOrder[0]['complete_address'];
      grandTotal = deliveryCharge + subtotal;
      userName.text = ('${placeOrder[0]['firstname']} ${placeOrder[0]['lastname']}');
      min = placeOrder[0]['minimum_order_amount'];
      minimumAmount = oCcy.parse(min);

      // getTenantSegregate();
      getTenantSegregate2();

      isLoading = false;
    });
  }

  // Future loadTotal2() async {
  //   var res = await db.loadSubTotal2(widget.productID);
  //   if (!mounted) return;
  //   setState(() {
  //     loadTotalData = res['user_details'];
  //     subtotal = double.parse(loadTotalData[0]['grand_total'].toString());
  //     print(loadTotalData);
  //     isLoading = false;
  //   });
  //   // print(loadTotalData);
  // }

  List<bool> subTotalTenant = [];

  // Future getTenantSegregate() async{
  //   subTotalTenant.clear();
  //   var res = await db.getTenantSegregate();
  //   if (!mounted) return;
  //   setState(() {
  //     getTenant = res['user_details'];
  //     for(int q=0;q<getTenant.length;q++){
  //       bool result = oCcy.parse(getTenant[q]['total']) < minimumAmount;
  //       subTotalTenant.add(result);
  //       getTenantData.add(getTenant[q]['tenant_id']);
  //       getTenantNameData.add(getTenant[q]['tenant_name']);
  //       getBuNameData.add(getTenant[q]['bu_name']);
  //     }
  //     tenantNo = getTenant.length;
  //     // deliveryCharge = delivery * tenantNo;
  //     // print(deliveryCharge);
  //     // print(getTenant);
  //     // print(getTenantNameData);
  //     // print(getBuNameData);
  //   });
  // }

  Future getTenantSegregate2() async{
    var res = await db.getAmountPerTenant2(widget.tempID);
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];

      isLoading = false;
      lt=getTenant.length;
      for(int q=0;q<lt;q++){
        bool result = oCcy.parse(getTenant[q]['total']) < minimumAmount;
        getTenantData.add(getTenant[q]['tenant_id']);
        getTenantNameData.add(getTenant[q]['tenant_name']);
        getBuNameData.add(getTenant[q]['bu_name']);
        getAcroNameData.add(getTenant[q]['acroname']);
      }
    });
  }


  updateCartStock(id, stk) async {
    await db.updateCartIcoos(id, stk);
  }

  // Future loadCart() async {
  //   var res = await db.loadCartData();
  //   if (!mounted) return;
  //   setState(() {
  //
  //     loadCartData = res['user_details'];
  //     loadIMainItems = loadCartData;
  //     items = loadCartData.length;
  //     isLoading = false;
  //     // print(loadCartData);
  //   });
  // }

  Future onRefresh() async {
    loadCart2();
    getPlaceOrderData();
    getBuSegregate();
  }

  Future loadCart2() async {
    var res = await db.loadCartData2(widget.tempID);
    if (!mounted) return;
    setState(() {

      loadCartData = res['user_details'];
      loadIMainItems = loadCartData;
      items = loadCartData.length;
      isLoading = false;
      // print(loadCartData.length);
    });
  }

  updateDefaultShipping(id,customerId) async{
    await db.updateDefaultShipping(id,customerId);
  }

  Future countDiscount() async{
    if(selectedDiscountType.length == 0){
      discount.text = "";
    }else{
      if(selectedDiscountType.length == 1){
        discount.text = selectedDiscountType.length.toString() +" person";
      }
      else{
        discount.text = selectedDiscountType.length.toString() +" persons";
      }
    }
  }

  List loadTotalData;

  // Future loadTotal() async{
  //   var res = await db.loadSubTotal();
  //   if (!mounted) return;
  //   setState(() {
  //     loadTotalData = res['user_details'];
  //     subtotal = double.parse(loadTotalData[0]['grand_total'].toString());
  //   });
  // }

  Future loadTotal2() async {
    var res = await db.loadSubTotal2(widget.tempID);
    if (!mounted) return;
    setState(() {
      loadTotalData = res['user_details'];
      subtotal = double.parse(loadTotalData[0]['grand_total'].toString());
      print(loadTotalData);
      isLoading = false;
    });
    // print(loadTotalData);
  }

  Future getBuSegregate() async{
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
    });
  }

  viewAddon(BuildContext context, mainItemIndex) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      transitionAnimationController: controller,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15), topLeft: Radius.circular(15),
        ),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

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
                        itemCount: loadIMainItems[mainItemIndex]['suggestions'].length == null ? 0 : loadIMainItems[mainItemIndex]['suggestions'].length,
                        itemBuilder: (BuildContext context, int index) {
                          print(loadIMainItems[mainItemIndex]['suggestions']);
                          String flavorPrice;
                          var f = index;
                            if (loadIMainItems[mainItemIndex]['suggestions'].length > 0) {
                              if (loadIMainItems[mainItemIndex]['suggestions'][f]['addon_price'] == '0.00'){
                                flavorPrice = "";
                              }else{
                                flavorPrice = ('₱ ${loadIMainItems[mainItemIndex]['suggestions'][f]['addon_price']}');
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text('+ ${loadIMainItems[mainItemIndex]['suggestions'][f]['description']}',
                                          style: GoogleFonts.openSans(fontSize: 14.0, color: Colors.black54, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ),
                                      Text('${flavorPrice}',
                                        style: TextStyle(fontSize: 14.0, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          return SizedBox();
                        },
                      ),

                      ///choices
                      ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: loadIMainItems[mainItemIndex]['choices'].length == null ? 0 : loadIMainItems[mainItemIndex]['choices'].length,
                        itemBuilder: (BuildContext context, int index) {
                          String choicesPrice;
                          if (loadIMainItems[mainItemIndex]['choices'][index]['addon_price'] == '0.00') {
                            choicesPrice = "";
                          } else {
                            choicesPrice = ('₱ ${loadIMainItems[mainItemIndex]['choices'][index]['addon_price']}');
                          }
                          if(loadIMainItems[mainItemIndex]['choices'][index]['unit_measure'] == null) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(child: Text('+ ${loadIMainItems[mainItemIndex]['choices'][index]['product_name']}',
                                        style: GoogleFonts.openSans(fontSize: 14.0, color: Colors.black54, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text('${choicesPrice}',
                                      style: TextStyle(fontSize: 14.0, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text('+ ${loadIMainItems[mainItemIndex]['choices'][index]['product_name']} - ${loadIMainItems[mainItemIndex]['choices'][index]['unit_measure']}',
                                      style: GoogleFonts.openSans(fontSize: 14.0, color: Colors.black54, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,
                                    )
                                  ),
                                  Text('${choicesPrice}',
                                    style: TextStyle(fontSize: 14.0, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      //addon
                      ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: loadIMainItems[mainItemIndex]['addons'].length == null ? 0 : loadIMainItems[mainItemIndex]['addons'].length,
                        itemBuilder: (BuildContext context, int index) {
                          if(loadIMainItems[mainItemIndex]['addons'][index]['unit_measure'] == null){
                            return Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text('+ ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']}',
                                        style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ),
                                    Text('₱ ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}',
                                      style: TextStyle(fontSize: 14.0, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text('+ ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']} ${loadIMainItems[mainItemIndex]['addons'][index]['unit_measure']}',
                                      style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text('₱ ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}',
                                    style: TextStyle(fontSize: 14.0, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        );
      }
    );
  }


  void displayBottomSheet(BuildContext context,tenantId,buName,tenantName) async{
    var res = await db.displayOrder(tenantId);
    if (!mounted) return;
    setState(() {
      getItemsData = res['user_details'];
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
          height: MediaQuery.of(context).size.height  * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[

              SizedBox(height:10.0),

              Padding(
                padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                child:Text(buName+"-"+tenantName,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
              ),

              Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: getItemsData == null ? 0 : getItemsData.length,
                  itemBuilder: (BuildContext context, int index) {
                    var f = index;
                    f++;
                    return InkWell(
                      onTap: (){
                        // displayAddOns(getItemsData[index]['cart_id']);
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$f. ${getItemsData[index]['d_prodName']} ',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                            Text('₱${getItemsData[index]['prod_price']}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                            Text(' x ${getItemsData[index]['d_quantity']}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }

 void displayOrder(tenantId) async{
   showDialog<void>(
     context: context,
     barrierDismissible: false, // user must tap button!
     builder: (BuildContext context) {
       return AlertDialog(
         shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.all(Radius.circular(8.0))
         ),
         contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
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

   var res = await db.displayOrder(tenantId);
   if (!mounted) return;
   setState((){
     getItemsData = res['user_details'];
     Navigator.of(context).pop();
   });
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height: 250.0, // Change as per your requirement
            width: 310, // Change as per your requirement
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getItemsData == null ? 0 : getItemsData.length,
                itemBuilder: (BuildContext context, int index) {
                  var f = index;
                  f++;
                  return ListTile(
                    title: Text('$f. ${getItemsData[index]['d_prodName']} ₱${getItemsData[index]['d_price']} x ${getItemsData[index]['d_quantity']}',style: TextStyle(fontSize: 15.0)),
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

  submitPlaceOrder() async{
     FocusScope.of(context).requestFocus(FocusNode());

      if(subTotalTenant.contains(true)){

      return CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "Must reach a minimum order of ₱${oCcy.format(minimumAmount)} per tenant.",
        confirmBtnColor: Colors.deepOrangeAccent,
        backgroundColor: Colors.deepOrangeAccent,
        barrierDismissible: false,
        onConfirmBtnTap: () async {
          Navigator.of(context).pop();
        },
        onCancelBtnTap: () async {
        }
      );

      } if (_today == false && deliveryTime.text.isEmpty){

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

                    Center(
                      child: Text("Please enter delivery time"),
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

       SharedPreferences prefs = await SharedPreferences.getInstance();
       String username = prefs.getString('s_customerId');
       if(username == null){

         Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});

       } else {

         print(specialInstruction);

         Navigator.of(context).push(_submitOrder(
           widget.paymentMethod,
           // deliveryDateData,
           // deliveryTimeData,
           _deliveryDate.text,
           _deliveryTime.text,
           getTenantData,
           getTenantNameData,
           getBuNameData,
           subtotal,
           grandTotal,
           specialInstruction,
           deliveryCharge,
           widget.tempID,
           )
         ).then((val)=>{onRefresh()});
       }
    }
  }

  getTrueTime() async{
    var res = await db.getTrueTime();
    if (!mounted) return;
    setState(() {
      trueTime = res['user_details'];
    });
  }

  @override
  void initState(){
    side.clear();
    selectedDiscountType.clear();
    super.initState();
    // loadCart();
    onRefresh();

    print(widget.paymentMethod);
    print(widget.tempID);
    initController();
    stock = 0;
    print(stock);
    // print(userName.text);
    // loadTotal();
    loadTotal2();
    // getTenantSegregate();
    // trapTenantLimit();
  }

  var index = 0;
  @override
  void dispose() {
    super.dispose();
    changeFor.dispose();
    placeOrderTown.dispose();
    placeOrderBrg.dispose();
    placeContactNo.dispose();
    placeRemarks.dispose();
    street.dispose();
    houseNo.dispose();
    deliveryDate.dispose();
    deliveryTime.dispose();
    discount.dispose();
    _specialInstruction[index].dispose();
//    trap.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async{
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
          title: Text("Review Checkout Form (Delivery)",
            style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 16.0),
          ),
        ),
        body: isLoading ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) :
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Expanded(
              child: Form(
                key: _formKey,
                child: RefreshIndicator(
                  color: Colors.deepOrangeAccent,
                  onRefresh: onRefresh,
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: getTenant == null ? 0 : getTenant.length,
                      itemBuilder: (BuildContext context, int index0) {
                        // _deliveryDate.add(new TextEditingController());
                        // _deliveryTime.add(new TextEditingController());
                        _specialInstruction.add(new TextEditingController());

                        amountPT = oCcy.parse(getTenant[index0]['total']);
                        if (amountPT < minimumAmount) {
                          minimum ='/ Does not reach minimum order';
                        } else {
                          minimum ='/ Minimum order reached';
                        }
                        return Container(
                          child: Column(
                            crossAxisAlignment : CrossAxisAlignment.start,
                            children: <Widget>[

                              Container(
                                height: 40,
                                color: Colors.deepOrange[300],
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text('${getTenant[index0]['tenant_name'].toString()} - ${getTenant[index0]['acroname'].toString()}',
                                        style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                height: 40,
                                color: Colors.deepOrange[100],
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Product Details',
                                        style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                      Text('Total Price',
                                        style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: loadCartData == null ? 0 : loadCartData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (loadCartData[index]['main_item']['icoos'] == '0'){
                                    option = 'Cancel Item';
                                  } else {
                                    option = 'Cancel Order';
                                  }
                                  return Visibility(
                                    visible: loadCartData[index]['main_item']['tenant_id'] != getTenant[index0]['tenant_id'] ? false : true,
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

                                                      Padding(
                                                        padding: EdgeInsets.only(left: 5),
                                                        child: CachedNetworkImage(
                                                          imageUrl: loadCartData[index]['main_item']['image'],
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
                                                      ),

                                                      Padding(
                                                        padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                                                        child: Text("₱ ${loadCartData[index]['main_item']['price'].toString()}",
                                                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black54),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                Expanded(
                                                  child: Column(
                                                    children: <Widget>[

                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[

                                                          Flexible(
                                                            child: Padding(
                                                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                              child: RichText(
                                                                text: TextSpan(
                                                                  style: GoogleFonts.openSans(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
                                                                  text: '${loadCartData[index]['main_item']['product_name']}'),
                                                                overflow: TextOverflow.ellipsis, maxLines: 2,
                                                              ),
                                                            ),
                                                          ),

                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(0, 2, 20, 0),
                                                            child: Text("₱ ${loadCartData[index]['main_item']['total_price'].toString()}",
                                                              style: TextStyle(fontSize: 13, color: Colors.black87),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      Row(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(5, 5, 15, 5),
                                                            child: Text('Quantity: ${loadCartData[index]['main_item']['quantity'].toString()}',
                                                              style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      Padding(
                                                        padding: EdgeInsets.only(left: 0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [

                                                            Visibility(
                                                              visible: loadCartData[index]['main_item']['addon_length'] > 0 ? true : false,
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                                                child:
                                                                Container(
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
                                                                      child: Text('${loadCartData[index]['main_item']['addon_length'].toString()}  more',
                                                                        style:TextStyle(fontSize: 12.0, color: Colors.deepOrangeAccent),
                                                                      ),
                                                                      onPressed:
                                                                          () async {
                                                                        viewAddon(context, index);
                                                                        // debugPrint('${loadIMainItems[index]['choices'][index]['product_name']}');
                                                                      },
                                                                    ),
                                                                  )
                                                                ),
                                                              ),
                                                            ),

                                                            Padding(
                                                              padding: EdgeInsets.only(right: 10),
                                                              child: Container(
                                                                padding: EdgeInsets.all(0),
                                                                width: 95,
                                                                child: DropdownButtonFormField(
                                                                  decoration: InputDecoration(
                                                                    //Add isDense true and zero Padding.
                                                                    //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                    isDense: true,
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(5),
                                                                        borderSide: BorderSide(color: Colors.deepOrangeAccent.withOpacity(0.8), width: 1)
                                                                    ),
                                                                    contentPadding: const EdgeInsets.only(
                                                                        left: 5, right: 0
                                                                    ),
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(5),
                                                                    ),
                                                                    //Add more decoration as you want here
                                                                    //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                                  ),
                                                                  isExpanded: false,
                                                                  hint: Text(option,
                                                                    style: GoogleFonts.openSans(fontSize: 12, color: Colors.black54),
                                                                  ),
                                                                  icon: const Icon(
                                                                    Icons.arrow_drop_down,
                                                                    color: Colors.black45,
                                                                  ),
                                                                  iconSize: 20,
                                                                  items: _option
                                                                    .map((item) =>
                                                                    DropdownMenuItem<String>(
                                                                      value: item,
                                                                      child: Container(
                                                                        margin: EdgeInsets.all(0),
                                                                        padding: EdgeInsets.all(0),
                                                                        width: 70,
                                                                        child:Text(item,
                                                                          style: GoogleFonts.openSans(fontSize: 11.0, color: Colors.black54),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                      .toList(),
                                                                  // ignore: missing_return
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      selectedValue = value;
                                                                      stock  = _option.indexOf(value);

                                                                      print(stock);
                                                                      print(loadCartData[index]['main_item']['product_id']);

                                                                      updateCartStock(loadCartData[index]['main_item']['product_id'], stock);

                                                                    });
                                                                    //Do something when changing the item if you want.
                                                                  },
                                                                  onTap: (){

                                                                  },
                                                                  onSaved: (value) {
                                                                    selectedValue = value.toString();
                                                                    print(selectedValue);
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        elevation: 0,
                                        margin: EdgeInsets.all(0),
                                      ),
                                    ),
                                  );
                                }
                              ),

                              Divider(thickness: 2, color: Colors.grey[200]),

                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text("Total Amount",
                                        style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Text("₱ ${getTenant[index0]['total']}",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Divider(thickness: 2, color: Colors.grey[200]),

                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                                child: new Text("Setup Date & Time for Delivery",
                                  style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
                                child: new Text("Delivery date*",
                                  style: GoogleFonts.openSans(fontSize: 13.0, color: Colors.black87),
                                ),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: (){

                                    _deliveryTime.clear();

                                    FocusScope.of(context).requestFocus(FocusNode());

                                    showGeneralDialog(
                                      barrierColor: Colors.black.withOpacity(0.5),
                                      transitionBuilder: (context, a1, a2, widget) {
                                        return Transform.scale(
                                          scale: a1.value,
                                          child: Opacity(
                                            opacity: a1.value,
                                            child: AlertDialog(
                                              contentPadding: EdgeInsets.all(0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(15.0))
                                              ),
                                              titlePadding: const EdgeInsets.all(0),
                                              title: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepOrange[400],
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(15), topLeft: Radius.circular(15),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 15, top: 10),
                                                  child: Text("Set date for this delivery",
                                                    style: GoogleFonts.openSans(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              content: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(height: 10),

                                                  Container(
                                                    padding: EdgeInsets.all(0),
                                                    height:220.0, // Change as per your requirement
                                                    width: 300.0, // Change as per your requirement
                                                    child: Scrollbar(
                                                      child:ListView.builder(
                                                        padding: EdgeInsets.all(0),
                                                        physics: BouncingScrollPhysics(),
                                                        itemCount: 5,
                                                        itemBuilder: (BuildContext context, int index1) {
                                                          int n = 0;
                                                          n = index1;
                                                          var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                          var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                          ///for database
                                                          final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                          final String formatted = formatter.format(d2);
                                                          ///for app display
                                                          final DateFormat formatter2 = DateFormat('MMMM d, y, EEEE');
                                                          final String formatted2 = formatter2.format(d2);
                                                          return InkWell(
                                                            onTap: (){
                                                              // while(deliveryDateData.length > getTenant.length-1){
                                                              //   deliveryDateData.removeAt(index0);
                                                              // }
                                                              _deliveryDate.text = formatted2;
                                                              datePicker = formatted;
                                                              print(_deliveryDate.text);
                                                              // deliveryDateData.insert(index0, _deliveryDate[index0].text);

                                                              Navigator.of(context).pop();
                                                              if (index1 == 0) {
                                                                setState(() {
                                                                  timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:00")).inHours;
                                                                  timeCount = timeCount.abs();
                                                                  _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
                                                                  _globalTime2 = _globalTime.hour;
                                                                  if (_globalTime2 >= 19) {
                                                                    timeCount = 0;
                                                                  }
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  timeCount = 12;
                                                                  _globalTime = new DateTime.now();
                                                                  _globalTime2 = 07;
                                                                  // _deliveryDate.clear();
                                                                });
                                                              }
                                                            },
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: <Widget>[
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                                                      child: Text('${formatted2.toString()}',
                                                                        style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Divider(thickness: 2, color: Colors.grey[200]),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                                                          side: BorderSide(color: Colors.deepOrangeAccent),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text('Clear',
                                                      style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                    onPressed: () {
                                                      _deliveryDate.clear();
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      transitionDuration: Duration(milliseconds: 400),
                                      barrierDismissible: true,
                                      barrierLabel: '',
                                      context: context,
                                      pageBuilder: (context, animation1, animation2) {}
                                    );
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                      cursorColor: Colors.deepOrange,
                                      controller: _deliveryDate,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please select delivery date';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.date_range,color: Colors.deepOrange[400]),
                                        contentPadding: EdgeInsets.all(0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 5, 5),
                                child: new Text("Delivery time*",
                                  style: GoogleFonts.openSans(fontSize: 13.0, color: Colors.black87),
                                ),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: (){

                                    getTrueTime();
                                    if(_deliveryDate.text.isEmpty){
                                      Fluttertoast.showToast(
                                        msg: "Please select a delivery date",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: Colors.black.withOpacity(0.7),
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                    } else {
                                      FocusScope.of(context).requestFocus(FocusNode());

                                      showGeneralDialog(
                                        barrierColor: Colors.black.withOpacity(0.5),
                                        transitionBuilder: (context, a1, a2, widget) {
                                          return Transform.scale(
                                            scale: a1.value,
                                            child: Opacity(
                                              opacity: a1.value,
                                              child: AlertDialog(
                                                contentPadding: EdgeInsets.all(0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                                                ),
                                                titlePadding: const EdgeInsets.all(0),
                                                title: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepOrange[400],
                                                    borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(15), topLeft: Radius.circular(15),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: 15, top: 10),
                                                    child: Text("Set time for this delivery",
                                                      style: GoogleFonts.openSans(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                content: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SizedBox(height: 10),

                                                    Container(
                                                      height:220.0, // Change as per your requirement
                                                      width: 300.0, // Change as per your requirement
                                                      child: Scrollbar(
                                                        child:  ListView.builder(
                                                          padding: EdgeInsets.all(0),
                                                          physics: BouncingScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemCount:  timeCount,
                                                          itemBuilder: (BuildContext context, int index1) {
                                                            int t = index1;
                                                            t++;
                                                            final now =  _globalTime;
                                                            final dtFrom = DateTime(now.year, now.month, now.day, _globalTime2+t, 0+00, now.minute, now.second);
                                                            // final dtTo = DateTime(now.year, now.month, now.day, 8+t, 0+30);
                                                            final format = DateFormat.jm();  //"6:00 AM"
                                                            final formatt = DateFormat.Hm(); //"6:
                                                            String from = format.format(dtFrom);
                                                            String fromm = formatt.format(dtFrom);

                                                            return InkWell(
                                                              onTap: (){

                                                                _deliveryTime.text = from;
                                                                print(_deliveryTime.text);

                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Row (
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                                                        child: Text('${from.toString()}',
                                                                          style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Divider(thickness: 2, color: Colors.grey[200]),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                                                            side: BorderSide(color: Colors.deepOrangeAccent),
                                                          ),
                                                        ),
                                                      ),
                                                      child: Text('Clear',
                                                        style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                                      ),
                                                      onPressed: () {
                                                        _deliveryTime.clear();
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                  },
                                  child: IgnorePointer(
                                    child: new TextFormField(
                                      style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,
                                      controller: _deliveryTime,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please select delivery time';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(CupertinoIcons.time, color: Colors.deepOrangeAccent),
                                        contentPadding: EdgeInsets.all(0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: new Text("Special Instruction",
                                  style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                child: new TextFormField(
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange,
                                  controller: _specialInstruction[index0],
                                  style: GoogleFonts.openSans(fontSize: 13),
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintStyle: GoogleFonts.openSans(fontSize: 13),
                                    hintText:"Special instruction",
                                    contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                                    focusedBorder:OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                ),
              )
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
                          Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                        } else {
                          if (_formKey.currentState.validate()) {
                            submitPlaceOrder();
                          }
                          for (int i=0; i<getTenant.length; i++){
                            while(specialInstruction.length > getTenant.length-1){
                              specialInstruction.removeAt(i);
                            }
                            specialInstruction.insert(i, "'${_specialInstruction[i].text}'");
                          }
                        }

                        // print(specialInstruction);
                        // print(getTenantData);
                        // print(getTenantNameData);
                        // print(getBuNameData);
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

int groupValue = 0;
Widget _myRadioButton({String title, int value, Function onChanged}) {
  return Theme(
    data: ThemeData.light(),
    child: RadioListTile(
      activeColor: Colors.deepOrange,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(title),
    ),
  );
}

Route _submitOrder(
    paymentMethod,
    deliveryDateData,
    deliveryTimeData,
    getTenantData,
    getTenantNameData,
    getBuNameData,
    subtotal,
    grandTotal,
    specialInstruction,
    deliveryCharge,
    productID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SubmitOrder(
      paymentMethod       : paymentMethod,
      deliveryDateData    : deliveryDateData,
      deliveryTimeData    : deliveryTimeData,
      getTenantData       : getTenantData,
      getTenantNameData   : getTenantNameData,
      getBuNameData       : getBuNameData,
      subtotal            : subtotal,
      grandTotal          : grandTotal,
      specialInstruction  : specialInstruction,
      deliveryCharge      : deliveryCharge,
      productID           : productID),
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