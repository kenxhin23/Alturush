import 'package:arush/profile/addressMasterFile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import '../profile_page.dart';
import 'gc_pick_up.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../track_order.dart';
import '../create_account_signin.dart';
import 'package:intl/intl.dart';
import 'gc_delivery.dart';

class GcLoadCart extends StatefulWidget {
  @override
  _GcLoadCart createState() => _GcLoadCart();
}

class _GcLoadCart extends State<GcLoadCart> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final _modeOfPayment = TextEditingController();

  List loadCartData     = [];
  List loadCartData2    = [];
  List loadSubtotal     = [];
  List loadPriceGroup   = [];
  List listProfile      = [];
  List getBu            = [];
  List getTotalAmount   = [];
  List getTotalAmount2  = [];
  List getGcItemsList   = [];
  List getBillList      = [];
  List getConFeeList    = [];
  List getBuName        = [];
  List getAddress       = [];
  List getDeliveryFee   = [];

  List<bool> subTotalStore = [];

  List<String> _options = ['Pay via Cash/COD']; //
  List<String> tempID = [];

  double totalAmount = 0.00;
  double amountPT = 0.00;
  int option;

  String priceGroup;
  String status;
  String profilePicture;
  String _selectOption;
  String townID;

  var profileLoading = true;
  var isLoading = true;
  var isLoading1 = true;
  var totalLoading = true;
  var subTotal = 0.00;
  var stores = 0;
  var items = 0;
  var bill = 0.0;
  var pickupFee = 0.00;
  var pickingFee = 0.0;
  var conFee = 0.00;
  var deliveryFee = 0.00;
  var grandTotal = 0.00;
  var minimumAmount = 0.00;
  var lt = 0;

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

    gcLoadPriceGroup();
    // gcLoadBu();
    // loadCart();
    getTotal();
    // loadGcSubTotal();
    loadCart2();
    loadGcSubTotal2();
    gcLoadBu2();
    gcGetAddress();

    tempID.clear();
    grandTotal = 0.00;

    setState(() {
      for (int i=0;i<side.length;i++){
        side[i] = false;
        for(int j=0;j<side1.length;j++){
          side1[j] = false;
        }
      }
    });
  }

  Future loadProfilePic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status  = prefs.getString('s_status');
    if(status != null) {
      var res = await db.loadProfile();
      if (!mounted) return;
      setState(() {
        listProfile = res['user_details'];
        profilePicture = listProfile[0]['d_photo'];
        profileLoading = false;
      });
    }
  }

  Future getTotal() async{
    var res = await db.getAmountPerStore();
    if (!mounted) return;
    setState(() {
      getTotalAmount = res['user_details'];
      // for(int q=0;q<getTotalAmount.length;q++){
      //   bool result = oCcy.parse(getTotalAmount[q]['total']) > minimumAmount;
      //   subTotalStore.add(result);
      // }
      // isLoading = false;
      print(getTotalAmount);
    });
  }

  Future getTotal2() async{
    var res = await db.getAmountPerStore2(tempID);
    if (!mounted) return;
    setState(() {
      subTotalStore.clear();
      getTotalAmount2 = res['user_details'];
      for(int q=0;q<getTotalAmount2.length;q++){
        bool result = oCcy.parse(getTotalAmount2[q]['total']) > minimumAmount;
        subTotalStore.add(result);
        print(result);
        // grandTotal = subTotal;
      }
      // isLoading = false;
    });
  }

  Future gcLoadBu() async {
    var res = await db.gcLoadBu();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      // stores = getBu.length;
      // lt = getBu.length;
      // isLoading = false;
    });
  }

  Future gcLoadBu2() async {
    var res = await db.gcLoadBu2(tempID);
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      stores = getBu.length;
      lt = getBu.length;
      // isLoading = false;
    });
  }

  Future gcGetAddress() async {
    var res = await db.gcGetAddress();
    if (!mounted) return;
    setState(() {
      getAddress = res['user_details'];
      for (int i=0; i <getAddress.length; i++) {
        if(getAddress[i]['shipping'] == '1') {
          townID = getAddress[i]['town_id'];
        }
      }
      print('town id ni $townID');
    });
  }

  Future gcLoadPriceGroup() async {
    var res = await db.gcLoadPriceGroup();
    if (!mounted) return;
    setState(() {
      loadPriceGroup = res['user_details'];
      for (int i=0;i<loadPriceGroup.length;i++) {
        priceGroup = loadPriceGroup[i]['price_group'];
        loadCart();
      }
      priceGroup = loadPriceGroup[0]['price_group'];
      // isLoading = false;
    });
  }

  Future loadMethods() async {
    // getTotal2();
    loadCart2();
    loadGcSubTotal2();
    gcLoadBu2();
    getMin();
    getTotal2();
    gcDeliveryFee();

  }


  Future getMin() async {
    var res = await db.getConFee();
    // isLoading = false;
    if (!mounted) return;
    setState(() {
      getConFeeList = res['user_details'];
      pickupFee = double.parse(getConFeeList[0]['pickup_charge']);
      minimumAmount = double.parse(getConFeeList[0]['minimum_order_amount']);
      pickingFee = pickupFee;
    });
    print(minimumAmount);
    print(pickingFee);
  }

  Future loadCart() async {
    var res = await db.gcLoadCartData();
    if (!mounted) return;
    setState(() {
      loadCartData = res['user_details'];
      // items = loadCartData.length;
      isLoading = false;
    });
  }

  Future loadCart2() async {
    var res = await db.gcLoadCartData2(tempID);
    if (!mounted) return;
    setState(() {
      loadCartData2 = res['user_details'];
      items = loadCartData2.length;
      // isLoading = false;
    });
  }

  Future loadGcSubTotal() async{
    var res = await db.loadGcSubTotal();
    if (!mounted) return;
    setState(() {
      loadSubtotal = res['user_details'];
      if (loadSubtotal[0]['d_subtotal']==null) {
        subTotal = 0.00;
      } else {
        // subTotal = oCcy.parse(loadSubtotal[0]['d_subtotal']);
      }
      // isLoading  = false;
    });
  }

  Future loadGcSubTotal2() async {
    var res = await db.loadGcSubTotal2(tempID);
    if (!mounted) return;
    setState(() {
      loadSubtotal = res['user_details'];
      if (loadSubtotal[0]['d_subtotal']==null) {
        subTotal = 0.00;
      } else {
        subTotal = oCcy.parse(loadSubtotal[0]['d_subtotal']);
      }
      grandTotal = subTotal;
      // isLoading  = false;
    });
  }

  Future gcDeliveryFee() async {
    var res = await db.gcDeliveryFee(townID);
    if (!mounted) return;
    setState(() {
      getDeliveryFee = res['user_details'];
      if (res != null) {
        conFee = oCcy.parse(getDeliveryFee[0]['con_fee']);
        deliveryFee = oCcy.parse(getDeliveryFee[0]['delivery_fee']);
      }
    });
    print(getDeliveryFee);
    print(conFee);
    print(deliveryFee);
  }

  void selectType(BuildContext context) async{
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height/3.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                    ///GC Delivery
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString('s_customerId');
                        if(username == null){
                          await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                        } else {
                          if (getDeliveryFee.isEmpty || getDeliveryFee == null) {
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              text: "Unsupported address for delivery\n"
                                  "Choose another address",
                              confirmBtnColor: Colors.green,
                              backgroundColor: Colors.green,
                              barrierDismissible: false,
                              onConfirmBtnTap: () async {
                                // subTotalTenant.clear();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            );
                          } else if (subTotalStore.contains(false)) {

                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              text: "Must reach a minimum order of ₱${oCcy.format(minimumAmount)} on each store.",
                              confirmBtnColor: Colors.green,
                              backgroundColor: Colors.green,
                              barrierDismissible: false,
                              onConfirmBtnTap: () async {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            );
                          } else if (getAddress.isEmpty) {
                            CoolAlert.show(
                                context: context,
                                type: CoolAlertType.error,
                                text: "Add new address",
                                confirmBtnColor: Colors.green,
                                backgroundColor: Colors.green,
                                barrierDismissible: false,
                                onConfirmBtnTap: () async {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
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
                            Navigator.of(context).push(_placeOrderDelivery(
                              stores,
                              items,
                              subTotal,
                              grandTotal,
                              priceGroup,
                              tempID,
                              townID,
                              conFee,
                              deliveryFee,
                            )).then((val)=>{onRefresh()});
                          }
                        }
                      },
                      child: Container(
                        width:130,
                        height:200,
                        child: Column(
                          children:[
                            Padding(
                              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                              child: Image.asset("assets/png/delivery.png",),
                            ),
                            Text("Delivery",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ),

                    ///GC Pick-up
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString('s_customerId');
                        if(username == null){

                          await Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                        } else {
                          print(subTotalStore);
                          if (subTotalStore.contains(false)) {

                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              text: "Must reach a minimum order of ₱${oCcy.format(minimumAmount)} on each store.",
                              confirmBtnColor: Colors.green,
                              backgroundColor: Colors.green,
                              barrierDismissible: false,
                              onConfirmBtnTap: () async {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            );
                          } else if (getAddress.isEmpty) {
                            CoolAlert.show(
                                context: context,
                                type: CoolAlertType.error,
                                text: "Add new address",
                                confirmBtnColor: Colors.green,
                                backgroundColor: Colors.green,
                                barrierDismissible: false,
                                onConfirmBtnTap: () async {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
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
                            Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new GcPickUp(
                              stores      : stores,
                              items       : items,
                              subTotal    : subTotal,
                              pickingFee  : pickingFee,
                              grandTotal  : grandTotal,
                              priceGroup  : priceGroup,
                              tempID      : tempID,
                              townID      : townID,
                            )
                            )).then((val)=>{onRefresh()});
                          }
                        }
                      },
                      child: Container(
                        width:130,
                        height:200,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                              child: Image.asset("assets/png/delivery-man.png"),
                            ),
                            Text("Pick-up",
                              style: TextStyle(
                                fontSize: 18.0,fontWeight: FontWeight.bold,
                              ),
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

  void displayBottomSheet(BuildContext context) async {
    var res = await db.getAmountPerStore2(tempID);
    if (!mounted) return;
    setState(() {
      getTotalAmount2 = res['user_details'];
      // isLoading = false;
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
                    color: Colors.green[400],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15), topLeft: Radius.circular(15),
                    ),
                  ),
                  height: 40,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text("YOUR STORE",
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
                          itemCount: getTotalAmount2 == null ? 0 : getTotalAmount2.length,
                          itemBuilder: (BuildContext context, int index) {
                            amountPT = oCcy.parse(getTotalAmount2[index]['total']);
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Container(
                                    height: 35,
                                    color: Colors.green[200],
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      child: Row(
                                        children: [
                                          Text('${getTotalAmount2[index]['buName']}',
                                              style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54)
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
                                        Text('${getTotalAmount2[index]['count']}',
                                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Divider(color: Colors.black54),

                                  Container(
                                    height: 35,
                                    color: Colors.grey[200],
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Subtotal Amount:',
                                            style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                          ),
                                          Text('₱${getTotalAmount2[index]['total']}',
                                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Column(
                                    children: [
                                      Visibility(
                                        visible: amountPT >= minimumAmount? true : false,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Padding(
                                              padding: EdgeInsets.only(left: 10, top: 10),
                                              child: Text('Minimum order reached',
                                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.green)
                                              ),
                                            ),
                                          ],
                                        )
                                      ),
                                      Visibility(
                                        visible: amountPT < minimumAmount ? true : false,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Padding(
                                              padding: EdgeInsets.only(left: 10, top: 10),
                                              child: Text('Does not reached minimum order',
                                                  style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.redAccent)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
        );
      }
    );
  }

  updateCartQty(id,qty) async{
    await db.updateGcCartQty(id,qty);
//    loadSubTotal();
  }

  modeOfPayment(_modeOfPayment){
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
        ),
        builder : (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height  * 0.4,
            child:Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  SizedBox(height:10.0),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                    child:Text("Payment method",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                  ),
                  InkWell(
                    onTap: () {
                      _modeOfPayment.text = "CASH ON DELIVERY";
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/mop/cod.png"),
                        ),
                        title: Text("CASH ON DELIVERY"),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _modeOfPayment.text = "GCASH";
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/mop/gcash.jpg"),
                        ),
                        title: Text("GCASH"),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      _modeOfPayment.text = "PAYMAYA";
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/mop/paymaya.jpg"),
                        ),
                        title: Text("PAYMAYA"),
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

  @override
  void initState() {
//    _event.add(0);
    super.initState();
    onRefresh();
    // getMin2();
    loadProfilePic();
    initController();


    gcLoadBu();
    gcLoadPriceGroup();
    getTotal();
    loadCart2();
    loadGcSubTotal2();
    gcLoadBu2();
    getMin();
  }

  @override
  void dispose() {
    super.dispose();
  }


  void removeFromCart(prodId) async{
    CoolAlert.show(
      context: context,
      showCancelBtn: true,
      type: CoolAlertType.warning,
      text: "Are you sure you want to remove this item?",
      confirmBtnColor: Colors.green,
      backgroundColor: Colors.green,
      barrierDismissible: false,
      confirmBtnText: 'Proceed',
      onConfirmBtnTap: () async {
        Navigator.of(context).pop();
        await db.removeGcItemFromCart(prodId);
        setState(() {
          onRefresh();
          gcLoadBu();
        });
      },
      cancelBtnText: 'Cancel',
      onCancelBtnTap: () async {
        Navigator.of(context).pop();
      }
    );
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
            statusBarColor: Colors.green[400], // Status bar
          ),
          backgroundColor: Colors.green[400],
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.white, size: 20,
              shadows: [
                Shadow(
                  blurRadius: 1.0,
                  color: Colors.black54,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("My cart",
            style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String username = prefs.getString('s_customerId');
                if(username == null){
                  Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                } else {
                  Navigator.of(context).push(_addressMasterfile()).then((val)=>{onRefresh()});
                }
              },
              icon: Icon(Icons.edit_location_outlined, color: Colors.white,
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
        body : isLoading
          ? Center(
           child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
           ),
        ):
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  color: Colors.green,
                  onRefresh: onRefresh,
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: getTotalAmount == null ? 0 : getTotalAmount.length,
                      itemBuilder: (BuildContext context, int index) {
                        side.add(false);
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              // Divider(thickness: 2, color: Colors.green.withOpacity(0.5)),
                              
                              InkWell(

                                child: Container(
                                  color: Colors.green[300],
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text('${getTotalAmount[index]['buName']}', style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Divider(thickness: 2, color: Colors.green.withOpacity(0.5)),

                              Padding(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 40,
                                  color: Colors.green[100],
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.zero,
                                            child: SizedBox(width: 20, height: 20,
                                              child: Checkbox(
                                                  activeColor: Colors.green,
                                                  value: side[index],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      side[index] = value;

                                                      for (int q=0;q<loadCartData.length;q++) {

                                                        if (getTotalAmount[index]['buCode'] == loadCartData[q]['buCode']){
                                                          side1[q] = false;
                                                          tempID.remove(loadCartData[q]['cart_id']);
                                                        }
                                                      }

                                                      if (value){

                                                        loadMethods();


                                                        for (int q=0;q<loadCartData.length;q++) {

                                                          if (getTotalAmount[index]['buCode'] == loadCartData[q]['buCode']){
                                                            side1[q] = true;
                                                            tempID.add(loadCartData[q]['cart_id']);
                                                          }
                                                        }
                                                      } else {

                                                        loadMethods();
                                                        grandTotal = 0.00;
                                                        for (int q=0;q<loadCartData.length;q++) {

                                                          if (getTotalAmount[index]['buCode'] == loadCartData[q]['buCode']){
                                                            side1[q] = false;
                                                            tempID.remove(loadCartData[q]['cart_id']);
                                                          }
                                                        }
                                                      }
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
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: loadCartData == null ? 0 : loadCartData.length,
                                itemBuilder: (BuildContext context, int index0) {

                                  String uom;

                                  if (loadCartData[index0]['product_uom'] == null) {
                                   uom = '';
                                  } else {
                                    uom = "- ${loadCartData[index0]['product_uom']}";
                                  }
                                  side1.add(false);
                                  return InkWell(
                                    child:
                                    Visibility(
                                      visible: loadCartData[index0]['buCode'] != getTotalAmount[index]['buCode'] ? false : true,
                                      child: Container(
                                        height: 120,
                                        child: Card( color: Colors.transparent,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: <Widget>[

                                                  Padding(
                                                    padding: EdgeInsets.only(left: 8, right: 10),
                                                    child: SizedBox(width: 20, height: 20,
                                                      child: Checkbox(
                                                        activeColor: Colors.green,
                                                        value: side1[index0],
                                                        onChanged: (bool value1) {
                                                          setState(() {
                                                            side1[index0] = value1;

                                                            if (value1) {
                                                              loadMethods();

                                                              tempID.add(loadCartData[index0]['cart_id']);

                                                            } else {
                                                              side[index] = false;
                                                              loadMethods();
                                                              grandTotal = 0.00;

                                                              tempID.remove(loadCartData[index0]['cart_id']);
                                                            }
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
                                                          imageUrl: loadCartData[index0]['product_image'],
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
                                                          child: Text("₱ ${loadCartData[index0]['price_price'].toString()}",
                                                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13,
                                                                color: Colors.black54),
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
                                                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                                                child: RichText(
                                                                  overflow: TextOverflow.ellipsis, maxLines: 2,
                                                                  text: TextSpan(
                                                                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                                                                    text: ('${loadCartData[index0]['product_name']} $uom'),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                                              child: Text("₱ ${loadCartData[index0]['total_price']}",
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
                                                                  padding:EdgeInsets.zero,
                                                                  child:Container(
                                                                    padding: EdgeInsets.all(0),
                                                                    width: 50.0,
                                                                    child: TextButton(
                                                                      style: TextButton.styleFrom(
                                                                        foregroundColor: Colors.white, disabledForegroundColor: Colors.black54.withOpacity(0.38),
                                                                      ),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(2),
                                                                          color: Colors.green[300],
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
                                                                      onPressed: side1[index0] ? null :() async{
                                                                        setState(() {
                                                                          var x = loadCartData[index0]['cart_qty'];
                                                                          int d = int.parse(x.toString());
                                                                          loadCartData[index0]['cart_qty'] = d-=1;  //code ni boss rene
                                                                          if(d<1 || d==0){
                                                                            loadCartData[index0]['cart_qty']=1;

                                                                            removeFromCart(loadCartData[index0]['cart_id']);
                                                                          }
                                                                          updateCartQty(loadCartData[index0]['cart_id'].toString(),loadCartData[index0]['cart_qty'].toString());
                                                                          Future.delayed(const Duration(milliseconds: 200), () {
                                                                            setState(() {
                                                                              gcLoadPriceGroup();
                                                                              gcLoadBu();
                                                                              getTotal();

                                                                            });
                                                                          });
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),

                                                                Padding(
                                                                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                                  child:Text(loadCartData[index0]['cart_qty'].toString(),
                                                                    style: GoogleFonts.openSans(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                                  ),
                                                                ),

                                                                Padding(
                                                                  padding:EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                  child:Container(
                                                                    padding: EdgeInsets.all(0),
                                                                    width: 50.0,
                                                                    child: TextButton(
                                                                      style: TextButton.styleFrom(
                                                                        foregroundColor: Colors.white, disabledForegroundColor: Colors.black54.withOpacity(0.38),
                                                                      ),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(2),
                                                                          color: Colors.green[300],
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
                                                                      onPressed:  side1[index0] ? null : () async {
                                                                        setState(() {
                                                                          var x = loadCartData[index0]['cart_qty'];
                                                                          int d = int.parse(x.toString());
                                                                          loadCartData[index0]['cart_qty'] = d+=1;   //code ni boss rene
                                                                          updateCartQty(loadCartData[index0]['cart_id'].toString(),loadCartData[index0]['cart_qty'].toString());
                                                                          Future.delayed(const Duration(milliseconds: 200), () {
                                                                            setState(() {
                                                                              gcLoadPriceGroup();
                                                                              gcLoadBu();
                                                                              getTotal();
                                                                            });
                                                                          });
                                                                        });
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
                                                                  onPressed: side1[index0] ? null : () async {
                                                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                    String username = prefs.getString('s_customerId');
                                                                    if (username == null) {
                                                                      Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                                                    } else {
                                                                      removeFromCart(loadCartData[index0]['cart_id']);
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
                                                                          return Colors.grey[300];
                                                                        else {
                                                                          return Colors.white;
                                                                        }
                                                                        return null; // Use the component's default.
                                                                      },
                                                                    ),
                                                                  ),
                                                                  child: Text('DELETE', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 11, color: Colors.redAccent)
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ]
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
                                        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(right: 15),
                                      child: Text("₱ ${getTotalAmount[index]['total']}",
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
                        padding: EdgeInsets.all(0),
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: Text("TOTAL SUMMARY", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('No. of Store(s)',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54)),

                            Text('$stores',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black.withOpacity(0.7))),
                          ],
                        ),
                      ),

                      // Divider(color: Colors.black54),

                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('No. of Item(s)',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54)),

                            Text('$items',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black.withOpacity(0.7))),
                          ],
                        ),
                      ),

                      // Divider(color: Colors.black54),

                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount Order',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54)),

                            Text('₱ ${oCcy.format(subTotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black.withOpacity(0.7))),
                          ],
                        ),
                      ),

                      // Divider(color: Colors.black54),
                      //
                      // Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text('Picking Fee',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.black)),
                      //       Text('₱ ${oCcy.format(pickingFee)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.normal, color: Colors.green)),
                      //     ],
                      //   ),
                      // ),

                      // Divider(color: Colors.black54),

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
                              Text('TOTAL AMOUNT TO PAY',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.green)),

                              Text('₱ ${oCcy.format(grandTotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.7))),
                            ],
                          ),
                        )
                      ),

                      // Divider(color: Colors.black54),

                      // Padding(
                      //   padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                      //   child: InkWell(
                      //     onTap: (){
                      //       FocusScope.of(context).requestFocus(FocusNode());
                      //       modeOfPayment(_modeOfPayment);
                      //     },
                      //     child: IgnorePointer(
                      //       child: new TextFormField(
                      //         textInputAction: TextInputAction.done,
                      //         cursorColor: Colors.deepOrange,
                      //         controller: _modeOfPayment,
                      //         validator: (value) {
                      //           if (value.isEmpty) {
                      //             return 'Please select mode of payment';
                      //           }
                      //           return null;
                      //         },
                      //         decoration: InputDecoration(
                      //           hintText: "Payment Method",
                      //           prefixIcon: Icon(Icons.payment_outlined,color: Colors.grey,),
                      //           contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                      //           focusedBorder:OutlineInputBorder(
                      //             borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                      //           ),
                      //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            //Add isDense true and zero Padding.
                            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                            isDense: true,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.green.withOpacity(0.8), width: 1)
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
                    child:Column(
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
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[

                      Container(
                        width: MediaQuery.of(context).size.width / 5.5,
                        child: SleekButton(
                          onTap: () async {
                            displayBottomSheet(context);
                          },
                          style: SleekButtonStyle.flat(
                            color: Colors.green[400],
                            inverted: false,
                            rounded: false,
                            size: SleekButtonSize.normal,
                            context: context,
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.tray_arrow_up,
                              size: 20.0,
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

                      SizedBox(width: 10.0,),

                      Flexible(
                        child: SleekButton(
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String username = prefs.getString('s_customerId');
                            if(username == null){
                              Navigator.of(context).push(_signIn()).then((value) => {onRefresh()});
                            } else {
                              // Navigator.of(context).push(_pickUp());
                            if (tempID.isEmpty){
                              Fluttertoast.showToast(
                              msg: "Please select item(s) for checkout. ",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.black.withOpacity(0.7),
                              textColor: Colors.white,
                              fontSize: 16.0
                              );
                            } else if (_formKey.currentState.validate()) {
                                selectType(context);
                              }
                            }
                            // selectType(context);
                          },
                          style: SleekButtonStyle.flat(
                            color: Colors.green[400],
                            inverted: false,
                            rounded: false,
                            size: SleekButtonSize.normal,
                            context: context,
                          ),
                          child: Center(
                            child: isLoading
                                ? Center(
                              child:Container(
                                height:16.0 ,
                                width: 16.0,
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ) : Text(
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

Route _pickUp(
  stores,
  items,
  subTotal,
  pickingFee,
  grandTotal,
  priceGroup
    ) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcPickUp(
        stores : stores,
        items : items,
        subTotal : subTotal,
        pickingFee : pickingFee,
        grandTotal : grandTotal,
        priceGroup : priceGroup,
    ),
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

Route _placeOrderDelivery(
    stores,
    items,
    subTotal,
    grandTotal,
    priceGroup,
    tempID,
    townID,
    conFee,
    deliveryFee,
    ){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcDelivery(
      stores      : stores,
      items       : items,
      subTotal    : subTotal,
      grandTotal  : grandTotal,
      priceGroup  : priceGroup,
      tempID      : tempID,
      townID      : townID,
      conFee      : conFee,
      deliveryFee : deliveryFee,
    ),
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
