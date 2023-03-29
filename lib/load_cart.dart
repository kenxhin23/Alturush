import 'package:arush/profile/addressMasterFile.dart';
import 'package:arush/profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'deliveryMethod.dart';
import 'pickupMethod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'track_order.dart';
import 'create_account_signin.dart';
import 'package:intl/intl.dart';

class LoadCart extends StatefulWidget {
  @override
  _LoadCart createState() => _LoadCart();
}

class _LoadCart extends State<LoadCart> with TickerProviderStateMixin {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final _formKey = GlobalKey<FormState>();

  List loadCartData = [];
  List loadCartData2 = [];
  List lGetAmountPerTenant;
  List loadSubtotal;
  List listProfile;
  List loadIMainItems;
  List loadChoices;
  List loadFlavors;
  List loadAddons;
  List loadTotalData;
  List loadTotalData2;
  List getTotalAmount;
  List getTotalAmount2;
  List loadTotalPrice;
  List placeOrder;
  List getBu;
  List getBu2;
  List getBuLength;

  ///select all
  List<String> orderID =[];
  List<String> tempID = [];
  List<String> uomID = [];
  List<String> quantity = [];
  List<String> price = [];
  List<String> measurement = [];
  List<String> totalPrice = [];
  List<String> icoos = [];
  List<String> buName = [];
  List<String> tenantID = [];
  List<String> tenantName = [];
  List<String> noStore = [];
  List<String> choiceUom = [];
  List<String> _options = ['Pay via Cash/COD']; // Option 2
  List<String> groupId =[];
  List<bool> locGroupID = [];
  List<bool> subTotalTenant = [];

  var isLoading = true;
  var checkOutLoading = true;
  var profileLoading = true;
  var boolFlavorId = false;
  var boolDrinkId = false;
  var boolFriesId = false;
  var boolSideId = false;
  var labelFlavor = "";
  var labelDrinks = "";
  var labelFries = "";
  var labelSides = "";
  var profilePicture = "";
  var stores = 0;
  var items = 0;

  int flavorGroupValue;
  int drinksGroupValue;
  int friesGroupValue;
  int sidesGroupValue;
  int flavorId;
  int drinkId, drinkUom;
  int friesId, friesUom;
  int sideId, sideUom;
  int subTotal = 0;
  int index = 0;
  int option;
  double grandTotal = 0.00;
  double minimumAmount = 0.00;
  double amountPT = 0.00;
  String min;

  String totPrice;
  String _selectOption; // Option 2
  String minimum;
  String groupID;
  String numStore;

  bool value1;
  bool value2;
  bool val = false;
  bool _ischecked = false;

  AnimationController controller;

  void initController(){
    controller = BottomSheet.createAnimationController(this);
    // Animation duration for displaying the BottomSheet
    controller.duration = const Duration(milliseconds: 500);
    // Animation duration for retracting the BottomSheet
    controller.reverseDuration = const Duration(milliseconds: 500);
    // Set animation curve duration for the BottomSheet
    controller.drive(CurveTween(curve: Curves.easeIn));
  }

  Future onRefresh() async {

    print('ni refresh na');
    loadCart();
    loadTotal();
    getBuSegregate();
    checkIfBf();
    loadProfilePic();
    getTotal();
    getPlaceOrderData();
    getBuGroupID();
    getTotal();
    getBuSegregate2();
    loadCart2();
    loadTotal2();
    getTotal2();

    orderID.clear();
    tempID.clear();
    uomID.clear();
    quantity.clear();
    price.clear();
    measurement.clear();
    totalPrice.clear();
    icoos.clear();
    choiceUom.clear();
    tenantID.clear();
    tenantName.clear();
    buName.clear();
    noStore.clear();


    setState(() {
      for (int i=0;i<side.length;i++){
        side[i] = false;
        for(int j=0;j<side1.length;j++){
          side1[j] = false;
        }
      }
    });
  }

  Future addTempCartPickup() async {
    await db.addTempCartPickup(
      orderID,
      tempID,
      uomID,
      quantity,
      price,
      measurement,
      totalPrice,
      icoos
    );
  }

  Future addTempCartDelivery() async {
    await db.addTempCartDelivery(
      orderID,
      tempID,
      uomID,
      quantity,
      price,
      measurement,
      totalPrice,
      icoos
    );
  }

  Future loadCart() async {
    var res = await db.loadCartData();
    if (!mounted) return;
    setState(() {
      loadCartData = res['user_details'];
      loadIMainItems = loadCartData;
      // items = loadCartData.length;
      isLoading = false;
      getPlaceOrderData();
    });
    print(loadCartData);
  }

  Future loadCart2() async {
    var res = await db.loadCartData2(tempID);
    if (!mounted) return;
    setState(() {
      loadCartData2 = res['user_details'];
      items = loadCartData2.length;
    });
  }

  Future getPlaceOrderData() async {
    var res1 = await db.getPlaceOrderData();
    if (!mounted) return;
    setState(() {
      placeOrder = res1['user_details'];
      getBuSegregate();
      min = placeOrder[0]['minimum_order_amount'];
      minimumAmount = oCcy.parse(min);
      groupID = placeOrder[0]['d_groupID'];
      // print("minimum amount is: $minimumAmount");
      getTotal();
      // print(placeOrder);
      isLoading = false;
    });
  }

  Future getBuGroupID() async{
    var res = await db.getBuGroupID();
    if (!mounted) return;
    setState(() {
      getBuLength = res['user_details'];
      isLoading = false;
    });
    // print(getBuLength.length);
  }

  String g;
  Future getBuSegregate() async {
    var res = await db.getBuSegregate1();
    if (!mounted) return;
    setState(() {
      locGroupID.clear();
      groupId.clear();
      getBu = res['user_details'];
      for (int i=0; i<getBu.length; i++) {
        bool result = getBu[i]['d_bu_group_id'] == groupID;
        locGroupID.add(result);
        groupId.add(getBu[i]['d_bu_group_id']);
        g = getBu[i]['d_bu_group_id'] ;
      }
      // stores = getBu.length;
    });
    print(getBu);
  }

  Future getBuSegregate2() async {
    var res = await db.getBuSegregate2(tempID);
    if (!mounted) return;
    setState(() {
      getBu2 = res['user_details'];
      stores = getBu2.length;
    });
  }

  Future getTotal() async {
    var res = await db.getAmountPerTenant();
    if (!mounted) return;
    setState(() {
      // subTotalTenant.clear();
      getTotalAmount = res['user_details'];
      // for(int q=0;q<getTotalAmount.length;q++){
      //   bool result = oCcy.parse(getTotalAmount[q]['total']) >= minimumAmount;
      //   subTotalTenant.add(result);
      //   print(result);
      // }
      isLoading = false;
    });
    // print(subTotalTenant);
  }

  Future getTotal2() async {
    var res = await db.getAmountPerTenant2(tempID);
    if (!mounted) return;
    setState(() {
      subTotalTenant.clear();
      getTotalAmount2 = res['user_details'];
      for(int q=0;q<getTotalAmount2.length;q++){
        bool result = oCcy.parse(getTotalAmount2[q]['total']) >= minimumAmount;
        subTotalTenant.add(result);
        print(result);
      }
      isLoading = false;
    });
    print(subTotalTenant);
  }

  String status;
  Future loadProfilePic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status = prefs.getString('s_status');
    if (status != null) {
      var res = await db.loadProfile();
      if (!mounted) return;
      setState(() {
        listProfile = res['user_details'];
        profilePicture = listProfile[0]['d_photo'];
        profileLoading = false;
      });
    }
  }

  Future loadTotal() async {
    var res = await db.loadSubTotal();
    if (!mounted) return;
    setState(() {
      loadTotalData = res['user_details'];
      // grandTotal = double.parse(loadTotalData[0]['grand_total'].toString());
      print(loadTotalData);
      isLoading = false;
    });
    // print(loadTotalData);
  }

  Future loadTotal2() async {
    var res = await db.loadSubTotal2(tempID);
    if (!mounted) return;
    setState(() {
      loadTotalData2 = res['user_details'];
      grandTotal = double.parse(loadTotalData2[0]['grand_total'].toString());
      print(loadTotalData);
      isLoading = false;
    });
    // print(loadTotalData);
  }

  Future loadMethods() async {
    getBuSegregate2();
    loadCart2();
    loadTotal2();
    getTotal2();
  }

  viewAddon(BuildContext context, mainItemIndex) {
    showModalBottomSheet(
      transitionAnimationController: controller,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(15), topLeft: Radius.circular(15)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // loadFlavors
              // loadAddons
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
                        padding: EdgeInsets.all(0),
                        shrinkWrap: true,
                        itemCount: loadIMainItems[mainItemIndex]['suggestions'].length == null ? 0 : loadIMainItems[mainItemIndex]['suggestions'].length,
                        itemBuilder: (BuildContext context, int index) {
                          print(index);
                          String flavorPrice;
                          var f = index;

                            if (loadIMainItems[mainItemIndex]['suggestions'].length > 0) {
                              if (loadIMainItems[mainItemIndex]['suggestions'][f]['addon_price'] == '0.00') {
                                flavorPrice = "";
                              } else {
                                flavorPrice = ('₱ ${loadIMainItems[mainItemIndex]['suggestions'][f]['addon_price']}');
                              }

                              // print(index);

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
                                        ),
                                      ),
                                      Text('$flavorPrice',
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
                        padding: EdgeInsets.all(0),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: loadIMainItems[mainItemIndex]['choices'].length == null ? 0 : loadIMainItems[mainItemIndex]['choices'].length,
                        itemBuilder: (BuildContext context, int index) {
                          print(loadIMainItems[mainItemIndex]['choices']);
                          // print(index);
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
                                        style: GoogleFonts.openSans(fontSize: 14.0, color: Colors.black54, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text('$choicesPrice',
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
                                      style: GoogleFonts.openSans(fontSize: 14.0, color: Colors.black54, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ),

                                  Text('$choicesPrice', style: TextStyle(fontSize: 14.0, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      //addon
                      ListView.builder(
                        padding: EdgeInsets.all(0),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: loadIMainItems[mainItemIndex]['addons'].length == null ? 0 : loadIMainItems[mainItemIndex]['addons'].length,
                        itemBuilder: (BuildContext context, int index) {
                          if(loadIMainItems[mainItemIndex]['addons'][index]['unit_measure'] == null){
                            print(loadIMainItems[mainItemIndex]['addons']);

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[

                                    Expanded(
                                      child: Text('+ ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']}',
                                        style: GoogleFonts.openSans(fontSize: 14.0, color: Colors.black54, fontWeight: FontWeight.bold),
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
                          print(loadIMainItems[mainItemIndex]['addons']);

                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[

                                  Expanded(
                                    child: Text('+ ${loadIMainItems[mainItemIndex]['addons'][index]['product_name']} ${loadIMainItems[mainItemIndex]['addons'][index]['unit_measure']}',
                                      style: GoogleFonts.openSans(fontSize: 14.0, color: Colors.black54, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  Text('₱ ${loadIMainItems[mainItemIndex]['addons'][index]['addon_price']}', style: TextStyle(fontSize: 14.0))
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
        );
      }
    );
  }

  void displayBottomSheet(BuildContext context) async {
    var res = await db.getAmountPerTenant2(tempID);
    if (!mounted) return;
    setState(() {
      lGetAmountPerTenant = res['user_details'];
      // isLoading = false;
      print(res);
    });
    showModalBottomSheet(
      transitionAnimationController: controller,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(15), topLeft: Radius.circular(15)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child:Container(
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
                  height: 40.0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text("YOUR STORE(S)",
                          style: GoogleFonts.openSans(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Scrollbar(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: lGetAmountPerTenant == null ? 0 : lGetAmountPerTenant.length,
                          itemBuilder: (BuildContext context, int index) {

                            amountPT = oCcy.parse(lGetAmountPerTenant[index]['total'].toString());
                            if (amountPT < minimumAmount) {
                              minimum ='Does not reached minimum order';
                            } else {
                              minimum ='Minimum order reached';
                            }
                            print(lGetAmountPerTenant[index]['tenant_id']);
                            var f = index;
                            f++;
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Container(
                                    height: 35,
                                    color: Colors.deepOrange[200],
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      child: Row(
                                        children: [
                                          Text('${lGetAmountPerTenant[index]['tenant_name']} - ${lGetAmountPerTenant[index]['acroname']}',
                                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [

                                        Text('No. of Item(s):',
                                          style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                        ),

                                        Text('${lGetAmountPerTenant[index]['count']}',
                                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    height: 30,
                                    color: Colors.grey[200],
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [

                                          Text('Subtotal Amount:',
                                            style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                          ),

                                          Text('₱${lGetAmountPerTenant[index]['total']}',
                                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Column(
                                    children: [

                                      Visibility(
                                        visible: amountPT >= minimumAmount && placeOrder.isNotEmpty ? true : false,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Row(
                                              children: [

                                                Padding(
                                                  padding: EdgeInsets.only(left: 10, top: 10),
                                                  child: Text('Minimum order reached',
                                                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.green),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.only(top: 10),
                                                  child: Text(' / ',
                                                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black54),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.only(top: 10),
                                                  child: Text('For delivery only',
                                                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black54),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      Visibility(
                                        visible: amountPT < minimumAmount ? true : false,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Row(
                                              children: [

                                                Padding(
                                                  padding: EdgeInsets.only(left: 10, top: 10),
                                                  child: Text('Does not reached minimum order',
                                                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.redAccent),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.only(top: 10),
                                                  child: Text(' / ',
                                                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black54),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.only(top: 10),
                                                  child: Text('For delivery only',
                                                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black54),
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
        );
      }
    );
  }

  void selectType(BuildContext context) async {
    showModalBottomSheet(
      transitionAnimationController: controller,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), topLeft: Radius.circular(10)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height / 3.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [


                    ///Delivery Foods
                    GestureDetector(
                      onTap: () {
                        // getPlaceOrderData();
                        print('true or false');
                        print(subTotalTenant);

                        if (getBuLength.length > 1){
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text: "One business unit is outside the scope of delivery service",
                            confirmBtnColor: Colors.deepOrangeAccent,
                            backgroundColor: Colors.deepOrangeAccent,
                            barrierDismissible: false,
                            onConfirmBtnTap: () async {
                              // subTotalTenant.clear();
                              Navigator.of(context).pop();
                            },
                          );
                        } else if (locGroupID.contains(false))  {

                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text: "Unsupported address for delivery\n"
                            "Choose another address",
                            confirmBtnColor: Colors.deepOrangeAccent,
                            backgroundColor: Colors.deepOrangeAccent,
                            barrierDismissible: false,
                            onConfirmBtnTap: () async {
                              // subTotalTenant.clear();
                              Navigator.of(context).pop();
                            },
                          );
                        } else if (subTotalTenant.contains(false)) {

                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text: "Must reach a minimum order of ₱${oCcy.format(minimumAmount)} per tenant.",
                            confirmBtnColor: Colors.deepOrangeAccent,
                            backgroundColor: Colors.deepOrangeAccent,
                            barrierDismissible: false,
                            onConfirmBtnTap: () async {
                              // subTotalTenant.clear();
                              Navigator.of(context).pop();
                            },
                          );
                        } else if (placeOrder.isEmpty) {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text: "Add new address",
                            confirmBtnColor: Colors.deepOrangeAccent,
                            backgroundColor: Colors.deepOrangeAccent,
                            barrierDismissible: false,
                            onConfirmBtnTap: () async {
                              Navigator.of(context).pop();
                            },
                            onCancelBtnTap: () async {}
                          );
                        } else {

                          setState(() {
                            // addTempCartDelivery();
                            for (int i=0;i<side.length;i++){
                              side[i] = false;
                              for(int j=0;j<side1.length;j++){
                                side1[j] = false;
                              }
                            }
                          });
                          Navigator.pop(context);
                          // Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new PlaceOrderDelivery(paymentMethod : _selectOption, tempID : tempID)),).then((val)=>{onRefresh()});
                          Navigator.of(context).push(_placeOrderDelivery(_selectOption, tempID)).then((val)=>{onRefresh()});
                        }
                      },
                      child: Container(
                        width: 130,
                        height: 200,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                              child: Image.asset(
                                "assets/png/delivery.png",
                              ),
                            ),
                            Text("Delivery",
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    ///Pick-up Foods
                    GestureDetector(
                      onTap: () {
                        print(getBuLength.length);
                        if (getBuLength.length > 1){
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text: "One business unit is outside the scope of pick-up service",
                            confirmBtnColor: Colors.deepOrangeAccent,
                            backgroundColor: Colors.deepOrangeAccent,
                            barrierDismissible: false,
                            onConfirmBtnTap: () async {
                              // subTotalTenant.clear();
                              Navigator.of(context).pop();
                            },
                          );
                        } else if (placeOrder.isEmpty) {
                          return CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text: "Add new address",
                            confirmBtnColor: Colors.deepOrangeAccent,
                            backgroundColor: Colors.deepOrangeAccent,
                            barrierDismissible: false,
                            onConfirmBtnTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String username = prefs.getString('s_customerId');
                              if (username == null) {
                                await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});

                              }
                              if (username != null) {
                                Navigator.of(context).pop();
                              }
                            },
                            onCancelBtnTap: () async {}
                          );
                        } else {
                          setState(() {

                            for (int i=0;i<side.length;i++){
                              side[i] = false;
                              for(int j=0;j<side1.length;j++){
                                side1[j] = false;
                              }
                            }
                          });
                          Navigator.pop(context);
                          Navigator.of(context).push(_placeOrderPickUp(_selectOption, tempID)).then((val)=>{onRefresh()});
                        }
                      },
                      child: Container(
                        width: 130,
                        height: 200,
                        child: Column(
                          children: [

                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                              child: Image.asset(
                                "assets/png/delivery-man.png",
                              ),
                            ),

                            Text("Pick-up",
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }


  bool ignorePointer = false;
  Future checkIfBf() async {
    var res = await db.checkIfBf();
    if (!mounted) return;
    setState(() {

      lGetAmountPerTenant = res['user_details'];
      isLoading = false;
    });
    if (lGetAmountPerTenant[0]['isavail'] == false) {
      ignorePointer = true;
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
            title: Center(
              child: Container(
                height: 100,
                width: 100,
                child: SvgPicture.asset("assets/svg/fried.svg"),
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: Center(
                      child: Text(
                        "Some items can only be cook and deliver in specific time, please remove them to proceed.",
                        textAlign: TextAlign.justify,
                        maxLines: 3,
                        style: TextStyle(fontSize: 18.0),
                      ),
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
    } else {
      ignorePointer = false;
    }
  }

//  StreamController _event =StreamController<int>.broadcast();
  updateCartQty(id, qty) async {
    await db.updateCartQty(id, qty);
  }

  @override
  void initState() {
    super.initState();
    onRefresh();
    initController();
    option = 0;
    var numberFormat = NumberFormat('#,##0.00', 'en_US');
    var myDouble = numberFormat.parse('123,456,789.45');
    print(myDouble); // Prints: 1230.45
    print(numberFormat.format(myDouble));

  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void removeFromCart(prodId) async {
    CoolAlert.show(
        context: context,
        showCancelBtn: true,
        type: CoolAlertType.warning,
        text: "Are you sure you want to remove this item?",
        confirmBtnColor: Colors.deepOrangeAccent,
        backgroundColor: Colors.deepOrangeAccent,
        barrierDismissible: false,
        confirmBtnText: 'Proceed',
        onConfirmBtnTap: () async {
          Navigator.of(context).pop();
          await db.removeItemFromCart(prodId);
          onRefresh();
        },
        cancelBtnText: 'Cancel',
        onCancelBtnTap: () async {

          Navigator.of(context).pop();
        }
    );

    // showDialog<void>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(8.0))),
    //       contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
    //       title: Row(
    //         children: <Widget>[
    //           Text(
    //             'Hello!',
    //             style: TextStyle(fontSize: 18.0),
    //           ),
    //         ],
    //       ),
    //       content: SingleChildScrollView(
    //         child: ListBody(
    //           children: <Widget>[
    //             Padding(
    //               padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
    //               child: Center(
    //                   child:
    //                       Text(("Are you sure you want to remove this item?"))),
    //             ),
    //           ],
    //         ),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           child: Text(
    //             'Cancel',
    //             style: TextStyle(
    //               color: Colors.deepOrange,
    //             ),
    //           ),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //         TextButton(
    //             child: Text(
    //               'Proceed',
    //               style: TextStyle(
    //                 color: Colors.deepOrange,
    //               ),
    //             ),
    //             onPressed: () async {
    //               Navigator.of(context).pop();
    //               await db.removeItemFromCart(prodId);
    //               loadCart();
    //               loadTotal();
    //               getBuSegregate();
    //               checkIfBf();
    //             }),
    //       ],
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
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
          title: Text("My Cart", style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString("s_customerId");
                if (username == null) {
                  Navigator.of(context).push(_signIn()).then((value) => {onRefresh()});
                }
                Navigator.of(context).push(_addressMasterfile()).then((val)=>{onRefresh()});
              },
              icon: Icon(Icons.edit_location_outlined, color: Colors.white),
            ),
          ],
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange)),
        ) :
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  color: Colors.deepOrangeAccent,
                  onRefresh: onRefresh,
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: getBu == null ? 0 : getBu.length,
                      itemBuilder: (BuildContext context, int index0) {
                        var f = index0;
                        side.add(false);
                        return Container(
                          child: Column(
                            crossAxisAlignment : CrossAxisAlignment.start,
                            children: <Widget>[

                              InkWell(

                                child: Container(
                                  color: Colors.deepOrange[300],
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 10, top: 5),
                                        child: Text('${getBu[index0]['d_tenant_name']} - ${getBu[index0]['d_acroname']}',
                                            style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 40,
                                  color: Colors.deepOrange[100],
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.zero,
                                            child: SizedBox(width: 20, height: 20,
                                              child: Checkbox(
                                                  activeColor: Colors.deepOrangeAccent,
                                                  value: side[index0],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      side[index0] = value;

                                                      for (int q=0;q<loadCartData.length;q++) {

                                                        if (getBu[index0]['d_tenant_id'] == loadCartData[q]['main_item']['tenant_id']){
                                                          side1[q] = false;
                                                          tempID.remove(loadCartData[q]['main_item']['temp_id']);
                                                        }
                                                      }

                                                      if (value){
                                                        print(value);
                                                        loadMethods();

                                                        for (int q=0;q<loadIMainItems.length;q++) {

                                                          if (getBu[index0]['d_tenant_id'] == loadIMainItems[q]['main_item']['tenant_id']){
                                                            side1[q] = true;
                                                            tempID.add(loadCartData[q]['main_item']['temp_id']);
                                                          }
                                                        }
                                                      } else {
                                                        print(value);
                                                        loadMethods();

                                                        for (int q=0;q<loadCartData.length;q++) {

                                                          if (getBu[index0]['d_tenant_id'] == loadCartData[q]['main_item']['tenant_id']){
                                                            side1[q] = false;
                                                            tempID.remove(loadCartData[q]['main_item']['temp_id']);
                                                          }
                                                        }
                                                      }
                                                      print(tempID);
                                                    });
                                                  }
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text('Product Details',
                                              style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text('Total Price',
                                        style: GoogleFonts.openSans(fontStyle: FontStyle.normal ,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(), //
                                shrinkWrap: true,
                                itemCount: loadCartData == null ? 0 : loadCartData.length,
                                itemBuilder: (BuildContext context, int index) {
                                 String unit;

                                 if (loadCartData[index]['main_item']['unit_measure'] != null) {
                                   unit = "- ${loadCartData[index]['main_item']['unit_measure']}";
                                 } else {
                                   unit ="";
                                 }

                                  side1.add(false);
                                  return InkWell(

                                  child: Visibility(
                                    visible: loadCartData[index]['main_item']['tenant_id'] != getBu[index0]['d_tenant_id'] ? false : true,
                                    child: Container(
                                      height: 120.0,
                                      child: Card(color: Colors.transparent,
                                        child: Column(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              children: <Widget>[

                                                Padding(
                                                  padding: EdgeInsets.only(left: 8, right: 10),
                                                  child: SizedBox(width: 20, height: 20,
                                                    child: Checkbox(
                                                      activeColor: Colors.deepOrangeAccent,
                                                      value: side1[index],
                                                      onChanged: (bool value1) {
                                                        setState(() {
                                                          side1[index] = value1;

                                                          if (value1) {
                                                            loadMethods();

                                                            tempID.add(loadCartData[index]['main_item']['temp_id']);

                                                          } else {
                                                            side[index0] = false;
                                                            loadMethods();

                                                            tempID.remove(loadCartData[index]['main_item']['temp_id']);
                                                          }
                                                          print(tempID);
                                                        });
                                                      }
                                                    ),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
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
                                                      // Container(
                                                      //   width: 75.0, height: 75.0,
                                                      //   decoration: new BoxDecoration(
                                                      //     shape: BoxShape.circle,
                                                      //     image: new DecorationImage(
                                                      //       image: new NetworkImage(
                                                      //           loadCartData[index]['main_item']['image']),
                                                      //       fit: BoxFit.scaleDown,
                                                      //     ),
                                                      //   ),
                                                      // ),

                                                      Padding(
                                                        padding: EdgeInsets.fromLTRB(5, 5, 10, 0),
                                                        child: Text("₱ ${loadCartData[index]['main_item']['price'].toString()}",
                                                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13,
                                                              color: Colors.black54),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ),

                                                Expanded(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                         Flexible(
                                                           child: Row(
                                                             children: [
                                                               Flexible(
                                                                 child: Padding(
                                                                   padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                                   child: RichText(
                                                                     overflow: TextOverflow.ellipsis,
                                                                     maxLines: 2,
                                                                     text: TextSpan(
                                                                       style: GoogleFonts.openSans(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
                                                                       text: '${loadCartData[index]['main_item']['product_name']} $unit ',
                                                                     ),
                                                                   ),
                                                                 ),
                                                               ),

                                                             ],
                                                           ),
                                                         ),

                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(0, 2, 15, 0),
                                                            child: Text("₱ ${loadCartData[index]['main_item']['total_price'].toString()}",
                                                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black87),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: EdgeInsets.zero,
                                                                child: Container(
                                                                  padding: EdgeInsets.all(0),
                                                                  width: 50.0,
                                                                  child: TextButton(style: TextButton.styleFrom(
                                                                    foregroundColor: Colors.white, disabledForegroundColor: Colors.black54.withOpacity(0.38),
                                                                  ),
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(2),
                                                                        color: Colors.deepOrange[300],
                                                                      ),
                                                                      height: 25,
                                                                      width: 25,
                                                                      child: Icon(Icons.remove, size: 16,
                                                                        shadows: [
                                                                          Shadow(
                                                                            blurRadius: 1.0,
                                                                            color: Colors.black54,
                                                                            offset: Offset(1.0, 1.0),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    onPressed: side1[index] ? null :
                                                                        () async {
                                                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                      String username = prefs.getString('s_customerId');
                                                                      if (username == null) {
                                                                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                                                      } else {
                                                                        setState(() {
                                                                          var x = loadCartData[index]['main_item']['quantity'];
                                                                          int d = int.parse(x.toString());
                                                                          loadCartData[index]['main_item']['quantity'] = d -= 1; //code ni boss rene
                                                                          if (d < 1 || d == 0) {
                                                                            loadCartData[index]['main_item']['quantity'] = 1;
                                                                            removeFromCart(loadCartData[index]['main_item']['id']);
                                                                          }
                                                                          updateCartQty(loadCartData[index]['main_item']['id'].toString(), loadCartData[index]['main_item']['quantity'].toString());
                                                                              totPrice = loadCartData[index]['main_item']['total_price'].toString();
                                                                              print(totPrice);
                                                                          Future.delayed(const Duration(milliseconds: 200), () {
                                                                            setState(() {
                                                                              loadTotal();
                                                                              loadCart();
                                                                              getTotal();
                                                                            });
                                                                          });
                                                                        });
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                                child: Text(
                                                                  loadCartData[index]['main_item']['quantity'].toString(),
                                                                  style: GoogleFonts.openSans(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                                ),
                                                              ),

                                                              Padding(
                                                                padding:EdgeInsets.zero,
                                                                child:
                                                                Container(
                                                                  padding: EdgeInsets.all(0),
                                                                  width: 50.0,
                                                                  child: TextButton(
                                                                    style: TextButton.styleFrom(
                                                                      foregroundColor: Colors.white, disabledForegroundColor: Colors.black54.withOpacity(0.38),
                                                                    ),
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(2),
                                                                        color: Colors.deepOrange[300],
                                                                      ),
                                                                      height: 25,
                                                                      width: 25,
                                                                      child: Icon(Icons.add, size: 16,
                                                                        shadows: [
                                                                          Shadow(
                                                                            blurRadius: 1.0,
                                                                            color: Colors.black54,
                                                                            offset: Offset(1.0, 1.0),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    onPressed: side1[index] ? null :
                                                                        () async {
                                                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                      String username = prefs.getString('s_customerId');
                                                                      if (username == null) {
                                                                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                                                      } else {
                                                                        setState(() {
                                                                          var x = loadCartData[index]['main_item']['quantity'];
                                                                          int d = int.parse(x.toString());
                                                                          loadCartData[index]['main_item']['quantity'] = d += 1; //code ni boss rene
                                                                          updateCartQty(loadCartData[index]['main_item']['id'].toString(),
                                                                          loadCartData[index]['main_item']['quantity'].toString());
                                                                          totPrice = loadCartData[index]['main_item']['total_price'].toString();
                                                                          Future.delayed(const Duration(milliseconds: 200), () {
                                                                            setState(() {
                                                                              loadTotal();
                                                                              loadCart();
                                                                              getTotal();
                                                                            });
                                                                          });
                                                                        });
                                                                      }
                                                                      // loadTotal();
                                                                      // loadCart();
                                                                      // getTotal();
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          Padding(
                                                              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                              child: SizedBox(
                                                                  height: 30, width: 60,
                                                                  child: TextButton(
                                                                      onPressed: side1[index] ? null : () async {
                                                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                        String username = prefs.getString('s_customerId');
                                                                        if (username == null) {
                                                                          Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                                                        } else {
                                                                          removeFromCart(loadCartData[index]['main_item']['id']);
                                                                        }
                                                                      },
                                                                      style:
                                                                      ButtonStyle(
                                                                        padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                            RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20.0),
                                                                                side: BorderSide(color: Colors.redAccent)
                                                                            )
                                                                        ),
                                                                        // backgroundColor: MaterialStateProperty.all(Colors.white),
                                                                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                                                              (Set<MaterialState> states) {
                                                                               if (states.contains(MaterialState.disabled))
                                                                              return Colors.grey[400];
                                                                               else {
                                                                                 return Colors.white;
                                                                               }
                                                                            return null; // Use the component's default.
                                                                          },
                                                                        ),
                                                                      ),
                                                                      child:
                                                                      Text('DELETE', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 11, color: Colors.redAccent))
                                                                  )
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(left: 5),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Visibility(
                                                              visible: loadCartData[index]['main_item']['addon_length'] > 0 ? true : false,
                                                              // visible: loadCartData[index]['addon_length'] == 0 ? false : true,
                                                              child:
                                                              Padding(
                                                                padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                                                                child:
                                                                Container(
                                                                  width: 65.0,
                                                                  child: SizedBox(
                                                                    height: 30,
                                                                    child: TextButton(
                                                                      style: ButtonStyle(
                                                                        padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                            RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(15.0),
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
                                  ),
                                );
                                },
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
                                        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(right: 15),
                                      child: Text("₱ ${getBu[index0]['total']}",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(thickness: 2, color: Colors.grey[200]),
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ),

              Visibility(
                visible: loadCartData.isEmpty ? false : true,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Padding(
                        padding: EdgeInsets.zero,
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: Text("TOTAL SUMMARY",
                              style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('No. of Store(s)',
                              style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            Text('$stores',
                              style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('No. of Item(s)',
                              style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            Text('$items',
                              style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount Order',
                              style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            Text('₱ ${oCcy.format(grandTotal)}',
                              style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TOTAL AMOUNT TO PAY',
                                style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
                              ),
                              Text('₱ ${oCcy.format(grandTotal)}',
                                style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            //Add isDense true and zero Padding.
                            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                            isDense: true,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.deepOrangeAccent.withOpacity(0.8), width: 1)
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            //Add more decoration as you want here
                            //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                          ),
                          isExpanded: true,
                          hint: const Text(
                            'PAYMENT METHOD',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black54),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 30,
                          items: _options
                              .map((item) =>
                              DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black54),
                                ),
                              ))
                              .toList(),
                          // ignore: missing_return
                          validator: (value) {
                            if (value == null) {
                              return 'Please select option';
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              _selectOption = value;
                              option = _options.indexOf(value);
                              print(_selectOption);
                            });
                            //Do something when changing the item if you want.
                          },
                          onSaved: (value) {
                            _selectOption = value.toString();
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ),

              Visibility(
                visible: loadCartData.isEmpty ? false : true,
                replacement: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight / 3.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: 100,
                          child: SvgPicture.asset("assets/svg/empty-cart.svg"),
                        ),
                      ],
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 5.5,
                        child: SleekButton(
                          onTap: () async {
                            displayBottomSheet(context);
                          },
                          style: SleekButtonStyle.flat(
                            color: Colors.deepOrange[400],
                            inverted: false,
                            rounded: false,
                            size: SleekButtonSize.normal,
                            context: context,
                          ),
                          child: Center(
                            child: Image.asset('assets/png/shop-xxl.png',
                              fit: BoxFit.contain,
                              height: 20,
                              width: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Flexible(
                        child: IgnorePointer(
                          ignoring: ignorePointer,
                          child: SleekButton(
                            onTap: () async {

                              getPlaceOrderData();
                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              String username =
                              prefs.getString('s_customerId');
                              if (username == null) {
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                              } else {
                                if (lGetAmountPerTenant[0]['isavail'] ==
                                    false) {
                                  checkIfBf();
                                }
                                else if (tempID.isEmpty){
                                  Fluttertoast.showToast(
                                      msg: "Please select item(s) for checkout. ",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 2,
                                      backgroundColor: Colors.black.withOpacity(0.7),
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }
                                else {
                                  if (_formKey.currentState.validate()) {
                                    selectType(context);
                                  }
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
                              child: Text(
                                "PROCESS CHECKOUT",
                                style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 16.0,
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

Route _placeOrderPickUp(paymentMethod, tempID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PlaceOrderPickUp(
      paymentMethod : paymentMethod,
      tempID        : tempID),
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

Route _placeOrderDelivery(paymentMethod, tempID) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PlaceOrderDelivery(
      paymentMethod : paymentMethod,
      tempID        : tempID,),
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

Route _profilePage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
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

Route _addressMasterfile() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        AddressMasterFile(),
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
