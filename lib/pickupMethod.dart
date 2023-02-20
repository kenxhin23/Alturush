import 'package:arush/profile/addNewAddress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'submit_delivery.dart';
import 'package:intl/intl.dart';
import 'submit_pickup.dart';
import 'discountManager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';

class PlaceOrderPickUp extends StatefulWidget {
  final paymentMethod;
  final productID;

  const PlaceOrderPickUp({Key key, this.paymentMethod, this.productID}) : super(key: key);
  @override
  _PlaceOrderPickUp createState() => _PlaceOrderPickUp();
}

class _PlaceOrderPickUp extends State<PlaceOrderPickUp>    with SingleTickerProviderStateMixin {
  final db = RapidA();
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  List<TextEditingController> _deliveryDate =  [];
  List<TextEditingController>  _deliveryTime = [];
  List<TextEditingController> _specialInstruction = [];

  List<String> _option = ['Cancel Item','Cancel Order'];
  List<String> getTenantData = [];
  List<String> getBuNameData = [];
  List<String> getAcroNameData = [];
  List<String> getTenantNameData =[];
  List<String> deliveryDateData = [];
  List<String> deliveryTimeData = [];
  List<String> specialInstruction = [];
  List<String> productName = [];
  List<String> price = [];
  List<String> quantity = [];
  List<String> totalPrice = [];
  List<String> tenantID = [];
  List loadCartData = [];
  List loadIMainItems;
  List getBu;
  List getTenant;
  List getItemsData;
  List getOrder;
  List getSubtotal;
  List loadTotalData;
  List placeOrder;
  List getItemsData2;


  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final discount = TextEditingController();
  var subtotal = 0.0;
  var isLoading = true;
  var lt = 0;
  var timeCount;
  var items;
  var stores;
  var _globalTime,_globalTime2;
  var stock;
  String date;
  String time;
  String selectedValue;
  String option;

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

  submitPickUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }else{
        Navigator.of(context).push(submitPickUpRoute(
            widget.paymentMethod,
            deliveryDateData,
            deliveryTimeData,
            getTenantData,
            getTenantNameData,
            getBuNameData,
            subtotal,
            specialInstruction,
            widget.productID));
    }
  }

  updateCartStock(id, stk) async {
    await db.updateCartStk(id, stk);
  }

  // void loadTotal() async{
  //   subtotal = 0;
  //   var res = await db.loadSubTotal();
  //   if (!mounted) return;
  //   setState((){
  //     isLoading = false;
  //     loadTotalData = res['user_details'];
  //     subtotal = double.parse(loadTotalData[0]['grand_total'].toString());
  //
  //   });
  // }

  Future loadTotal2() async {
    var res = await db.loadSubTotal2(widget.productID);
    if (!mounted) return;
    setState(() {
      loadTotalData = res['user_details'];
      subtotal = double.parse(loadTotalData[0]['grand_total'].toString());
      print(loadTotalData);
      isLoading = false;
    });
    // print(loadTotalData);
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
  //     // print(loadCartData.length);
  //   });
  // }

  Future loadCart2() async {
    var res = await db.loadCartData2(widget.productID);
    if (!mounted) return;
    setState(() {

      loadCartData = res['user_details'];
      loadIMainItems = loadCartData;
      items = loadCartData.length;
      isLoading = false;
      // print(loadCartData.length);
    });
  }

  Future getOrderData() async{
    var res = await db.getOrderData();
    if (!mounted) return;
    setState(() {
      getOrder = res['user_details'];
    });
  }

  Future getBuSegregate() async {
    var res = await db.getBuSegregate1();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      stores = getBu.length;
      // print(getBu.length);
    });
  }

  // Future getTenantSegregate() async{
  //   var res = await db.getTenantSegregate();
  //   if (!mounted) return;
  //   setState(() {
  //     getTenant = res['user_details'];
  //
  //     isLoading = false;
  //     lt=getTenant.length;
  //     for(int q=0;q<lt;q++){
  //       getTenantData.add(getTenant[q]['tenant_id']);
  //       getTenantNameData.add(getTenant[q]['tenant_name']);
  //       getBuNameData.add(getTenant[q]['bu_name']);
  //       getAcroNameData.add(getTenant[q]['acroname']);
  //     }
  //     // print(getTenant.length);
  //     // print(getTenantData);
  //     // print(getTenantNameData);
  //     // print(getBuNameData);
  //   });
  // }

  Future getTenantSegregate2() async{
    var res = await db.getAmountPerTenant2(widget.productID);
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];

      isLoading = false;
      lt=getTenant.length;
      for(int q=0;q<lt;q++){
        getTenantData.add(getTenant[q]['tenant_id']);
        getTenantNameData.add(getTenant[q]['tenant_name']);
        getBuNameData.add(getTenant[q]['bu_name']);
        getAcroNameData.add(getTenant[q]['acroname']);
      }
    });
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

  Future toRefresh() async{
    // getOrderData();
    // getTenantSegregate();
    getTenantSegregate2();
  }

  List trueTime;
  getTrueTime() async{
    var res = await db.getTrueTime();
    if (!mounted) return;
    setState(() {
      trueTime = res['user_details'];
      print(trueTime);
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
          topRight: Radius.circular(10), topLeft: Radius.circular(10)),
    ),
    builder: (ctx) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // loadFlavors
            // loadAddons
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
              child: Text(
                "ADD ONS",
                style: TextStyle(
                    fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
              ),
            ),

            Divider(thickness: 1, color: Colors.deepOrangeAccent,),

            Expanded(
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[

                    ///flavors
                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: loadIMainItems[mainItemIndex]['suggestions'].length == null ? 0 : loadIMainItems[mainItemIndex]['suggestions'].length,
                      itemBuilder: (BuildContext context, int index) {
                        String flavorPrice;
                        var f = index;
                          if (loadIMainItems[mainItemIndex]['suggestions'].length > 0) {
                            if (loadIMainItems[mainItemIndex]['suggestions'][f]['addon_price'] == '0.00'){
                              flavorPrice = "";
                            }else{
                              flavorPrice = ('₱ ${loadIMainItems[mainItemIndex]['suggestions'][f]['addon_price']}');
                            }
                            return Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        '+ ${loadIMainItems[mainItemIndex]['suggestions'][f]['description']}',
                                        style: TextStyle(fontSize: 14.0,), overflow: TextOverflow.ellipsis,
                                      )
                                    ),
                                    Text('$flavorPrice', style: TextStyle(fontSize: 14.0)),
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
                            padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text('+ ${loadIMainItems[mainItemIndex]['choices'][index]['product_name']}',
                                    style: TextStyle(fontSize: 14.0,), overflow: TextOverflow.ellipsis,)
                                  ),
                                  Text('$choicesPrice', style: TextStyle(fontSize: 14.0)),
                                ],
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Container(
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text('+ ${loadIMainItems[mainItemIndex]['choices'][index]['product_name']} - ${loadIMainItems[mainItemIndex]['choices'][index]['unit_measure']}',
                                    style: TextStyle(fontSize: 14.0,), overflow: TextOverflow.ellipsis,
                                  )
                                ),
                                Text('$choicesPrice', style: TextStyle(fontSize: 14.0)),
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
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '+ ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']}',
                                      style: TextStyle(fontSize: 14.0,), overflow: TextOverflow.ellipsis,
                                    )
                                  ),
                                  Text('₱ ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}', style: TextStyle(fontSize: 14.0)),
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
                                  child: Text(
                                    '+ ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']} ${loadIMainItems[mainItemIndex]['addons'][index]['unit_measure']}',
                                    style: TextStyle(fontSize: 14.0,), overflow: TextOverflow.ellipsis,
                                  )
                                ),
                                Text('₱ ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}', style: TextStyle(fontSize: 14.0)),
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
    });
  }


  void  displayOrder(tenantId) async{
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

  Future onRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }
    getOrderData();
    getBuSegregate();
    getTrueTime();
    // getTenantSegregate();
    // loadTotal();
    loadTotal2();
    // loadCart();
    loadCart2();
  }

  @override
  void initState(){
    selectedDiscountType.clear();
    super.initState();
    selectedDiscountType.clear();
    onRefresh();
    getOrderData();
    getBuSegregate();
    getTrueTime();
    // getTenantSegregate();
    getTenantSegregate2();
    // loadTotal();
    loadTotal2();
    // loadCart();
    loadCart2();
    stock = 0;
    print(widget.productID);
    // _deliveryDate.clear();
    _deliveryTime.clear();
    // print(getBu.length);
    initController();
  }

  @override
  void dispose() {
    var index = 0;
    _deliveryTime[index].dispose();
    _deliveryDate[index].dispose();
    _specialInstruction[index].dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
//          Navigator.pop(context);
        return true;
      },

      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Review Checkout Form (Pick-up)",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0),),
        ),
        body: isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange)),
        ) :
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Expanded(
              child: Form(
                key: _key,
                child: RefreshIndicator(
                  color: Colors.deepOrangeAccent,
                  onRefresh: onRefresh,
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: getTenant == null ? 0 : getTenant.length,
                      itemBuilder: (BuildContext context, int index0) {
                        _deliveryDate.add(new TextEditingController());
                        _deliveryTime.add(new TextEditingController());
                        _specialInstruction.add(new TextEditingController());

                        return Container(
                          child: Column(
                            crossAxisAlignment : CrossAxisAlignment.start,
                            children: <Widget>[

                              Divider(thickness: 1, color: Colors.deepOrangeAccent),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${getTenant[index0]['tenant_name'].toString()} - ${getTenant[index0]['acroname'].toString()}',
                                  style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 15.0),
                                ),
                              ),

                              Divider(thickness: 1, color: Colors.deepOrangeAccent),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Product Details',
                                      style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    Text('Total Price',
                                      style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),

                              Divider(color: Colors.black54),

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

                                                      CachedNetworkImage(
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

                                                      Padding(
                                                        padding: EdgeInsets.fromLTRB(5, 5, 10, 0),
                                                        child: Text("₱ ${loadCartData[index]['main_item']['price']}",
                                                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13,
                                                            color: Colors.black,),
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
                                                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 12),
                                                                    text: '${loadCartData[index]['main_item']['product_name']}'),
                                                                overflow: TextOverflow.ellipsis, maxLines: 2,
                                                              ),
                                                            ),
                                                          ),

                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(0, 2, 20, 0),
                                                            child: Text("₱ ${loadCartData[index]['main_item']['total_price'].toString()}",
                                                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13,
                                                                color: Colors.deepOrangeAccent),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      Row(
                                                        children: <Widget>[

                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(5, 5, 15, 5),
                                                            child: Text('Quantity: ${loadCartData[index]['main_item']['quantity'].toString()}',
                                                              style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black),
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
                                                              // visible: loadCartData[index]['addon_length'] == 0 ? false : true,
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                                                child: Container(
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
                                                                  hint: Text(
                                                                      option, style: TextStyle(fontStyle: FontStyle.normal, fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black)),
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
                                                                            width: 70,
                                                                            child:Text(item, style: TextStyle(fontStyle: FontStyle.normal, fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black)),
                                                                          )
                                                                      ))
                                                                      .toList(),
                                                                  // ignore: missing_return
                                                                  onChanged: (value){
                                                                    setState(() {
                                                                      selectedValue = value;
                                                                      stock  = _option.indexOf(value);
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
                                }
                              ),

                              Divider(thickness: 1, color: Colors.black54),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Text("₱ ${getTenant[index0]['total']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepOrangeAccent)),
                                  )
                                ],
                              ),

                              Divider(thickness: 1, color: Colors.black54),

                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                                child: new Text("Setup Date & Time for Pick-up", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
                                child: new Text("Pick-up date*", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, color: Colors.black)),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: (){

                                    _deliveryTime[index0].clear();

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
                                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                                              ),
                                              titlePadding: const EdgeInsets.only(left: 10, top: 10, bottom: 0),
                                              title: Text("Set date for this pick-up",style: TextStyle(fontSize: 15.0, color: Colors.deepOrangeAccent),
                                              ),
                                              content: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Divider(thickness: 1, color: Colors.deepOrangeAccent),
                                                  Container(
                                                    padding: EdgeInsets.all(0),
                                                    height:150.0, // Change as per your requirement
                                                    width: 300.0, // Change as per your requirement
                                                    child: Scrollbar(
                                                      child:ListView.builder(
                                                        padding: EdgeInsets.all(0),
                                                        physics: BouncingScrollPhysics(),
                                                        itemCount: 4,
                                                        itemBuilder: (BuildContext context, int index1) {
                                                          int n = 0;
                                                          n = index1;
                                                          var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                          var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                          final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                          final String formatted = formatter.format(d2);
                                                          return InkWell(
                                                            onTap: (){
                                                              while(deliveryDateData.length > getTenant.length-1){
                                                                deliveryDateData.removeAt(index0);
                                                              }
                                                              _deliveryDate[index0].text = formatted;
                                                              deliveryDateData.insert(index0, _deliveryDate[index0].text);

                                                              Navigator.of(context).pop();
                                                              if (index1 == 0) {
                                                                setState(() {
                                                                  timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:30")).inHours;
                                                                  timeCount = timeCount.abs();
                                                                  _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
                                                                  _globalTime2 = _globalTime.hour;
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
                                                                Row (
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: <Widget>[
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                                      child: Text('${formatted.toString()}',style: TextStyle(fontSize: 15.0),),
                                                                    ),
                                                                  ]
                                                                ),
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
                                                          side: BorderSide(color: Colors.deepOrangeAccent)
                                                        )
                                                      )
                                                    ),
                                                    child: Text(
                                                      'Clear',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      _deliveryDate[index0].clear();
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                )
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
                                      style: TextStyle(fontSize: 13),
                                      cursorColor: Colors.deepOrange,
                                      controller: _deliveryDate[index0],
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please select pick-up date';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.date_range,color: Colors.deepOrangeAccent,),
                                        contentPadding: EdgeInsets.all(0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 5, 5),
                                child: new Text("Pick-up time*", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, color: Colors.black)),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                child: InkWell(
                                  onTap: (){

                                    getTrueTime();
                                    if (_deliveryDate[index0].text.isEmpty) {
                                      Fluttertoast.showToast(
                                          msg: "Please select a pick-up date",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 2,
                                          backgroundColor: Colors.black.withOpacity(0.7),
                                          textColor: Colors.white,
                                          fontSize: 16.0
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
                                                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                                                ),
                                                titlePadding: const EdgeInsets.only(left: 10, top: 10, bottom: 0),
                                                title: Text("Set time for this pick-up",style: TextStyle(fontSize: 15.0, color: Colors.deepOrangeAccent)),
                                                content: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Divider(thickness: 1, color: Colors.deepOrangeAccent),
                                                    Container(
                                                      height:200.0, // Change as per your requirement
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
                                                            final dtFrom = DateTime(now.year, now.month, now.day, _globalTime2+t, 0+30, now.minute, now.second);
                                                            // final dtTo = DateTime(now.year, now.month, now.day, 8+t, 0+30);
                                                            final format = DateFormat.jm();
                                                            final formatt = DateFormat.Hm(); //"6:00 AM"
                                                            String from = format.format(dtFrom);
                                                            String fromm = formatt.format(dtFrom);

                                                            return InkWell(
                                                              onTap: (){
                                                                while(deliveryTimeData.length > getTenant.length-1){
                                                                  deliveryTimeData.removeAt(index0);
                                                                }

                                                                _deliveryTime[index0].text = from;
                                                                deliveryTimeData.insert(index0, _deliveryTime[index0].text);

                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Row (
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                                        child: Text('${from.toString()}',style: TextStyle(fontSize: 14.0),),
                                                                      ),
                                                                    ]
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }
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
                                                            side: BorderSide(color: Colors.deepOrangeAccent)
                                                          )
                                                        )
                                                      ),
                                                      child: Text(
                                                        'Clear',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        _deliveryTime[index0].clear();
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
                                      style: TextStyle(fontSize: 13),
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,
                                      controller: _deliveryTime[index0],
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please select pick-up time';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(CupertinoIcons.time, color: Colors.deepOrangeAccent,),
                                        contentPadding: EdgeInsets.all(0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: new Text("Special Instruction", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                              ),

                              Padding(
                                padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                child: new TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange,
                                  controller: _specialInstruction[index0],
                                  style: TextStyle(fontSize: 13),
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(fontSize: 13),
                                    hintText:"Special instruction",
                                    contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                                    focusedBorder:OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
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
                      onTap: () {
                        if (_key.currentState.validate()) {
                          submitPickUp();
                        }
                        for (int i=0; i<getTenant.length; i++){
                          while(specialInstruction.length > getTenant.length-1){
                            specialInstruction.removeAt(i);
                          }
                          specialInstruction.insert(i, "'${_specialInstruction[i].text}'");
                        }

                        // String time = '12:30 PM';
                        // DateTime tempDate = new DateFormat("hh:mm:ss").parse(time);
                        // print(tempDate);
                      },
                      style: SleekButtonStyle.flat(
                        color: Colors.deepOrange,
                        inverted: false,
                        rounded: true,
                        size: SleekButtonSize.big,
                        context: context,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("NEXT",
                            style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                            ),
                          ],
                        )
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


// Route _submitOrder(changeForText,townId,barrioId,contactNo,placeOrderTown,placeOrderBrg,street,houseNo,placeRemark,changeFor,deliveryCharge,grandTotal,deliveryDate,deliveryTime,groupValue) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => SubmitOrder(changeForText:changeForText,townId:townId,barrioId:barrioId,contactNo:contactNo,placeOrderTown:placeOrderTown,placeOrderBrg:placeOrderBrg,street:street,houseNo:houseNo,placeRemark:placeRemark,changeFor:changeFor,deliveryCharge:deliveryCharge,grandTotal:grandTotal,deliveryDate:deliveryDate,deliveryTime:deliveryTime,groupValue:groupValue),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       var begin = Offset(0.0, 1.0);
//       var end = Offset.zero;
//       var curve = Curves.decelerate;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }


Route submitPickUpRoute(
    groupValue,
    deliveryDateData,
    deliveryTimeData,
    getTenantData,
    getTenantNameData,
    getBuNameData,
    subtotal,
    specialInstruction,
    productID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SubmitPickUp(
        groupValue:groupValue,
        deliveryDateData:deliveryDateData,
        deliveryTimeData:deliveryTimeData,
        getTenantData:getTenantData,
        getTenantNameData:getTenantNameData,
        getBuNameData:getBuNameData,
        subtotal:subtotal,
        specialInstruction:specialInstruction,
        productID : productID),
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