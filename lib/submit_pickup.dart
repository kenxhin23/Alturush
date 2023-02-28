import 'dart:convert';
import 'dart:io';

import 'package:arush/profile/addNewAddress.dart';
import 'package:arush/profile/editAddress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'db_helper.dart';
import 'model.dart';
import 'package:intl/intl.dart';
import 'create_account_signin.dart';
import 'package:sleek_button/sleek_button.dart';
import 'track_order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class SubmitPickUp extends StatefulWidget {
  final groupValue;
  final deliveryDateData;
  final deliveryTimeData;
  final getTenantData;
  final getTenantNameData;
  final getBuNameData;
  final subtotal;
  final specialInstruction;
  final productID;
  SubmitPickUp({Key key,
    @required
    this.groupValue,
    this.deliveryDateData,
    this.deliveryTimeData,
    this.getTenantData,
    this.getTenantNameData,
    this.getBuNameData,
    this.subtotal,
    this.specialInstruction,
    this.productID}) : super(key: key);
  @override
  _SubmitPickUp createState() => _SubmitPickUp();
}

class _SubmitPickUp extends State<SubmitPickUp> with TickerProviderStateMixin {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  var amountTender = TextEditingController();
  final changeFor = TextEditingController();
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  final db = RapidA();
  final model = Model();
  final oCcy = new NumberFormat("#,##0.00", "en_US");

  List loadCartData = [];
  List getBu = [];
  List getTenant = [];
  List getItemsData = [];
  List getItemsData2 = [];
  List placeOrder = [];
  List loadIdList = [];

  String placeOrderTown;
  String placeOrderBrg;
  String province;
  String placeContactNo;
  String placeRemarks;
  String street;
  String userName;
  String houseNo;
  String comma;
  String date;
  String time;
  String tenant;
  String buName;
  String groupID;

  var townId;
  var barrioId;
  var stores;
  var items;
  var index = 0;
  var isLoading = true;

  bool exist = false;

  double amt;

  int shipping;

  List<String> productName = [];
  List<String> price = [];
  List<String> quantity = [];
  List<String> totalPrice = [];
  List<String> tenantID = [];

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

  Future onRefresh() async {

    print('ni refresh nah');
    getPlaceOrderData();
    loadId();
    // loadCart();
    loadCart2();
    // getBuSegregate1();
    getBuSegregate2();
    getTenantSegregate();
    checkIfHasId();
  }

  Future getPlaceOrderData() async{
    var res = await db.getPlaceOrderData();
    if (!mounted) return;
    setState(() {
      placeOrder = res['user_details'];
      townId = placeOrder[0]['d_townId'];
      barrioId = placeOrder[0]['d_brgId'];
      placeOrderTown = placeOrder[0]['d_townName'];
      placeOrderBrg = placeOrder[0]['d_brgName'];
      placeContactNo = placeOrder[0]['d_contact'];
      placeRemarks = placeOrder[0]['land_mark'];
      street = placeOrder[0]['street_purok'];
      province = placeOrder[0]['d_province'];
      userName = ('${placeOrder[0]['firstname']} ${placeOrder[0]['lastname']}');
      getTenantSegregate();
      isLoading = false;
    });
    print(placeOrder);
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

  // Future loadCart() async {
  //   var res = await db.loadCartData();
  //   if (!mounted) return;
  //   setState(() {
  //
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

  // Future getBuSegregate() async{
  //   var res = await db.getBuSegregate();
  //   if (!mounted) return;
  //   setState(() {
  //     getBu = res['user_details'];
  //     for (int i=0; i<getBu.length; i++) {
  //       groupID = getBu[i]['d_bu_group_id'];
  //       displayAdd(groupID);
  //     }
  //     isLoading = false;
  //   });
  //   print(getBu.length);
  // }

  // Future getBuSegregate1() async {
  //   var res = await db.getBuSegregate1();
  //   if (!mounted) return;
  //   setState(() {
  //     getBu = res['user_details'];
  //     stores = getBu.length;
  //   });
  // }

  Future getBuSegregate2() async {
    var res = await db.getBuSegregate2(widget.productID);
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      for (int i=0; i<getBu.length; i++) {
        groupID = getBu[i]['d_bu_group_id'];
        displayAdd(groupID);
      }
      stores = getBu.length;
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

  Future getTenantSegregate() async{
    var res = await db.getTenantSegregate();
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];
      for(int i=0;i<getTenant.length;i++){
        tenantID.insert(i, getTenant[i]['tenant_id']);
      }
    });
  }

  updateDefaultShipping(id,customerId) async{
    await db.updateDefaultShipping(id,customerId);
  }

  updatePickupAt(date, time) async{
    await db.updatePickupAt(date, time);
  }

  _placeOrderPickUp() async{
    // await db.savePickup(
    //     widget.deliveryDateData,
    //     widget.deliveryTimeData,
    //     widget.getTenantData,
    //     widget.specialInstruction,
    //     widget.subtotal,
    //     widget.productID
    // );

    await db.savePickup2(
        widget.deliveryDateData,
        widget.deliveryTimeData,
        widget.getTenantData,
        widget.specialInstruction,
        widget.subtotal,
        widget.productID
    );
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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
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
          title: Text("Summary (Pick-up)",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        )  :
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Form(
                key: _key,
                child: RefreshIndicator(
                  color: Colors.deepOrangeAccent,
                  key: refreshKey,
                  onRefresh: onRefresh,
                  child: Scrollbar(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[

                        Divider(thickness: 1, color: Colors.deepOrangeAccent),

                        SizedBox(height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                child: new Text(
                                  "CUSTOMER ADDRESS",
                                  style: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 15, 0),
                                child: SizedBox(width: 175,
                                  child: OutlinedButton.icon(
                                    onPressed: () async{
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String username = prefs.getString('s_customerId');
                                      if(username == null){
                                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                        // Navigator.of(context).push(_signIn());
                                      }else{
                                        getPlaceOrderData();
                                        displayAddresses(context).then((val) => {onRefresh()});
                                      }
                                    },
                                    label: Text('MANAGE ADDRESS',  style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 12.0, color: Colors.white)),
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                      backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                                      overlayColor: MaterialStateProperty.all(Colors.black12),
                                      side: MaterialStateProperty.all(BorderSide(
                                        color: Colors.deepOrangeAccent,
                                        width: 1.0,
                                        style: BorderStyle.solid),
                                      ),
                                    ),
                                    icon: Wrap(
                                      children: [
                                        Icon(Icons.settings_outlined, color: Colors.white, size: 18,)
                                      ],
                                    ),
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),

                        Divider(thickness: 1, color: Colors.deepOrangeAccent,),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Row(
                            children: <Widget>[
                              Text("Customer: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 14.0)),
                              Text("${userName.toString()}", style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14.0)),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                          child: Row(
                            children: <Widget>[
                              Text("Contact Number: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 14.0)),
                              Text("${placeContactNo.toString()}", style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14.0)),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                          child: Row(
                            children: <Widget>[
                              Text("Address: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 14.0),),
                              Text("$street, $placeOrderBrg, $placeOrderTown, $province",
                                  style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14.0))
                            ],
                          )
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: Row(
                            children: <Widget>[
                              Text("Landmark: ", style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal, fontSize: 14.0)),
                              Flexible(child: Text("$placeRemarks", style: TextStyle(fontSize: 14.0), maxLines: 6, overflow: TextOverflow.ellipsis)
                              ),
                            ],
                          )
                        ),

                        Divider(thickness: 1, color: Colors.deepOrangeAccent),

                        SizedBox(height: 30,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                            child: Text("TOTAL SUMMARY", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent ),),
                          ),
                        ),

                        Divider(thickness: 1, color: Colors.deepOrangeAccent),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('No. of Store(s)',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                              Text('$stores',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('No. of Item(s)',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                              Text('$items',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount Order',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                              Text('₱ ${oCcy.format(widget.subtotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TOTAL AMOUNT TO PAY',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                              Text('₱ ${oCcy.format(widget.subtotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('PAYMENT METHOD',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                              Text('Pay via CASH',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),

                        Divider(thickness: 1, color: Colors.deepOrangeAccent),
                        SizedBox(height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                child: new Text("APPLY DISCOUNT",
                                  style: GoogleFonts.openSans(color: Colors.deepOrangeAccent, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 14.0),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                child: SizedBox(width: 175,
                                  child: OutlinedButton.icon(
                                    onPressed: () async{
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String username = prefs.getString('s_customerId');
                                      if(username == null){
                                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                        // Navigator.of(context).push(_signIn());
                                      }else{
                                        // applyDiscount();
                                        showApplyDiscountDialog(context).then((_)=>{loadId()});
                                        // await Navigator.of(context).push(_showDiscountPerson());
                                      }
                                    },
                                    label: Text('MANAGE DISCOUNT',  style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 12.0, color: Colors.white)),
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                      backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                                      overlayColor: MaterialStateProperty.all(Colors.black12),
                                      side: MaterialStateProperty.all(BorderSide(
                                        color: Colors.deepOrangeAccent,
                                        width: 1.0,
                                        style: BorderStyle.solid,)),
                                    ),
                                    icon: Wrap(
                                      children: [
                                        Icon(Icons.settings_outlined, color: Colors.white, size: 18,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(thickness: 1, color: Colors.deepOrangeAccent),

                        RefreshIndicator(
                          color: Colors.deepOrangeAccent,
                          onRefresh: loadId,
                          child: Scrollbar(
                            child: ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                exist == false ? Padding(
                                  padding: EdgeInsets.only(left: 10, top: 5),
                                  child: Text('No Discount Details', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, color: Colors.black54),),
                                ) :
                                ListView.builder(
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
                                                                height: 50,
                                                                width: 50,
                                                                decoration: new BoxDecoration(
                                                                  image: new DecorationImage(
                                                                    image: imageProvider,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                  borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                                                  border: new Border.all(
                                                                    color: Colors.black54,
                                                                    width: 0.5,
                                                                  ),
                                                                ),
                                                              ),
                                                              placeholder: (context, url,) => const CircularProgressIndicator(color: Colors.grey,),
                                                              errorWidget: (context, url, error) => Container(
                                                                height: 50,
                                                                width: 50,
                                                                decoration: new BoxDecoration(
                                                                  image: new DecorationImage(
                                                                    image: AssetImage("assets/png/No_image_available.png"),
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                  borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                                                                  border: new Border.all(
                                                                    color: Colors.black54,
                                                                    width: 0.5,
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
                                                                Text('${loadIdList[index]['name']} ',style: TextStyle(fontSize: 14, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black),),
                                                                Text('(${loadIdList[index]['discount_name']})',style: TextStyle(fontSize: 13)),
                                                                Text('${loadIdList[index]['discount_no']}',style: TextStyle(fontSize: 13, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black),),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),

                                                      SizedBox(width: 25,
                                                        child: RawMaterialButton(
                                                          onPressed:
                                                              () async {
                                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                                            String username = prefs.getString('s_customerId');
                                                            if (username == null) {
                                                              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                                              // await Navigator.of(context).push(_signIn());
                                                            } else {

                                                              removeDiscountId(loadIdList[index]['id']);

                                                            }
                                                          },
                                                          elevation: 1.0,
                                                          child:
                                                          Icon(
                                                            CupertinoIcons.delete, size: 25.0,
                                                            color: Colors.redAccent,
                                                          ),
                                                          shape:
                                                          CircleBorder(),
                                                        ),
                                                      )
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
                        )
                      ],
                    ),
                  ),
                )
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: SleekButton(
                      onTap: () async {
                        // if (amt < widget.subtotal){
                        //   Fluttertoast.showToast(
                        //       msg: "Insufficient Amount!",
                        //       toastLength: Toast.LENGTH_SHORT,
                        //       gravity: ToastGravity.BOTTOM,
                        //       timeInSecForIosWeb: 2,
                        //       backgroundColor: Colors.black.withOpacity(0.7),
                        //       textColor: Colors.white,
                        //       fontSize: 16.0
                        //   );
                        // }
                        if (_key.currentState.validate()) {
                          placeOrderPickUp();
                        }
                        // print(widget.deliveryTimeData);
                        // print(widget.deliveryDateData);
                        print(widget.getTenantData);
                        // print(widget.specialInstruction);
                      },
                      style: SleekButtonStyle.flat(
                        color: Colors.deepOrange,
                        inverted: false,
                        rounded: true,
                        size: SleekButtonSize.normal,
                        context: context,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.paperplane),
                            SizedBox(width: 5),
                            Text("CHECKOUT",
                            style: TextStyle(
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

  void change(String amount){
    print(amount);
    amt = double.parse(amount);
    // amountTender.text = oCcy.format(amt).toString();
    if(amt < widget.subtotal) {
      print('insufficient amount');
      changeFor.text = '';
    } else {
      double change = amt - widget.subtotal;
      changeFor.text = oCcy.format(change).toString();
      print(change);
    }
  }

  placeOrderPickUp() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
      // Navigator.of(context).push(_signIn());
    }else{
      _placeOrderPickUp();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Thank you for using Alturush",
        confirmBtnColor: Colors.deepOrangeAccent,
        backgroundColor: Colors.deepOrangeAccent,
        barrierDismissible:false,
        onConfirmBtnTap: () async{
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String username = prefs.getString('s_customerId');
          if(username == null){
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
            // Navigator.of(context).push(_signIn());
          }if(username != null){
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

  Future displayAddresses(context) async{
    print(groupID);
    displayAdd(groupID);
    return showModalBottomSheet(
      transitionAnimationController: controller,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight:  Radius.circular(10),topLeft:  Radius.circular(10)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
          return Container(
            height: MediaQuery.of(context).size.height  * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[

                SizedBox(height: 5),

                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: SizedBox(height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text("Select your address",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),),

                        OutlinedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20))),
                            backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                            overlayColor: MaterialStateProperty.all(Colors.black12),
                            side: MaterialStateProperty.all(BorderSide(
                              color: Colors.deepOrangeAccent,
                              width: 1.0,
                              style: BorderStyle.solid,)),
                          ),
                          onPressed:(){
                            Navigator.pop(context);
                            Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new AddNewAddress())).then((val)=>{onRefresh()});
                            refreshKey.currentState.show();
                          },
                          child:Text("+ Add new",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 14.0),),
                        ),
                      ],
                    ),
                  ),
                ),

                Divider(thickness: 1, color: Colors.deepOrangeAccent),

                Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: getItemsData == null ? 0 : getItemsData.length,
                      itemBuilder: (BuildContext context, int index) {
                        var f= index;
                        f++;
                        return InkWell(
                            onTap: () async {
                            },
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
                                        padding: EdgeInsets.only(top: 5,),
                                        child: Text('${getItemsData[index]['firstname']} ${getItemsData[index]['lastname']}',style: TextStyle(fontSize: 14, color: Colors.black),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Text('${getItemsData[index]['street_purok']}, ${getItemsData[index]['d_brgName']}, \n${getItemsData[index]['d_townName']}, '
                                            '${getItemsData[index]['zipcode']}, ${getItemsData[index]['d_province']}' ,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.black54)),
                                      )
                                    ],
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text('${getItemsData[index]['d_contact']}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.normal, color: Colors.black)),
                                  )
                                ],
                              ),
                              value: index,
                              groupValue: shipping,
                              onChanged: (newValue) {

                                state((){
                                  shipping = newValue;
                                  updateDefaultShipping(getItemsData[index]['id'],getItemsData[index]['d_customerId']);
                                  Future.delayed(const Duration(milliseconds: 200), () {
                                    setState(() {
                                      // getPlaceOrderData();
                                      Navigator.pop(context);
                                    });
                                  });
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        });
      }
    );
  }

  @override
  void initState(){
    selectedDiscountType.clear();
    tenantID.clear();
    amountTender.text = oCcy.format(widget.subtotal).toString();

    onRefresh();
    getPlaceOrderData();
    loadId();
    // loadCart();
    loadCart2();
    // getBuSegregate1();
    getBuSegregate2();
    getTenantSegregate();
    checkIfHasId();
    print(widget.productID);
    initController();
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  showApplyDiscountDialog(BuildContext context) {
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
} //end of class

class ApplyDiscountDialog extends StatefulWidget {
  @override
  _ApplyDiscountDialogState createState() => _ApplyDiscountDialogState();
}

class _ApplyDiscountDialogState extends State<ApplyDiscountDialog> {
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
    print('view id');
  }

  @override
  void initState() {
    super.initState();
    loadID();
    checkIfHasId();
    // print(selectedDiscountType);
//    print(widget.deliveryDate);
//    print(widget.changeFor+"hello");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))
      ),
      contentPadding: EdgeInsets.only(top: 5) ,
      content: Container(
        height: 400.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [

            SizedBox(height: 30,
              child: Row(
                children: [

                  SizedBox(height: 30 , width: 30,
                    child: IconButton(
                      onPressed: (){
                      },
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      icon: Image.asset('assets/png/img_552316.png',
                        color: Colors.black54,
                        fit: BoxFit.contain,
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text("Apply Discount ", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                  ),
                ],
              ),
            ),

            Divider(thickness: 1, color: Colors.deepOrangeAccent),

            SizedBox(height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text("Discount Applied List ", style: TextStyle(color: Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child:OutlinedButton(
                      onPressed: () async{
                        FocusScope.of(context).requestFocus(FocusNode());
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString('s_customerId');
                        if(username == null){
                          Navigator.of(context).push(_signIn());
                        }else{
                          showAddDiscountDialog(context).then((_)=>{loadID()});
                          checkIfHasId();
                          loadID();
                        }
                      },
                      child: Text('+ ADD',  style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 13.0, color: Colors.white)),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(25))),
                        overlayColor: MaterialStateProperty.all(Colors.black12),
                        backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                        side: MaterialStateProperty.all(BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 1.0,
                          style: BorderStyle.solid,)),
                      ),
                    ),
                  ),
                ],
              )
            ),

            Divider(thickness: 1, color: Colors.deepOrangeAccent),

            Expanded(
              child: RefreshIndicator(
                color: Colors.deepOrangeAccent,
                onRefresh: loadID,
                child: Scrollbar(
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    // shrinkWrap: true,
                    children: <Widget>[
                      ListView.builder(
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
                                SizedBox(height: 40,
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
                                            Text('${loadIdList[index]['name']} (${loadIdList[index]['discount_name']})',style: TextStyle(fontSize: 13, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black)),
                                            Text('${loadIdList[index]['discount_no']}',style: TextStyle(fontSize: 13, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black)),
                                          ],
                                        ),
                                      )
                                    ),
                                    value: side[index],
                                    onChanged: (bool value){
                                      setState(() {
                                        side[index] = value;
                                        if (value) {
                                          selectedDiscountType.add(loadIdList[index]['dicount_id']);
                                        } else{
                                          selectedDiscountType.remove(loadIdList[index]['dicount_id']);
                                        }
                                        print(selectedDiscountType);
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                    ],
                  )
                ),
              ),
            )
          ],
        )
      ),
      actions: <Widget>[

        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.black,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          onPressed:(){
            for (int i=0;i<selectedDiscountType.length;i++){
              side[i] = false;
            }
            selectedDiscountType.clear();

            Navigator.pop(context);
          },
          child:Text("CLOSE",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 12.0),),
        ),

        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.deepOrangeAccent,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
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
              print('very gud');
              Navigator.of(context).pop();
            }
          },
          child:Text("APPLY",style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 12.0),),
        ),
      ],
    );
  }

  showAddDiscountDialog(BuildContext context) {
    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AddDiscountDialog(),
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
    print(loadDiscount);
    print(_loadDiscount);
    print(_loadDiscountID);
  }

  Future getDiscountID(name) async{
    var res = await db.getDiscountID(name);
    if (!mounted) return;
    setState(() {
      loadDiscountID = res['user_details'];
      print(loadDiscountID[0]['discount_id']);
      discountID = loadDiscountID[0]['discount_id'];
      print(discountID);
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
    if (username == null) {
      await Navigator.of(context).push(_signIn());
    } else {
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
          Navigator.of(context).push(_signIn());
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
          borderRadius: BorderRadius.all(Radius.circular(8.0))
      ),
      contentPadding: EdgeInsets.only(top: 5),
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

              SizedBox(height: 30,
                child: Row(
                  children: [

                    SizedBox(height: 30 , width: 30,
                      child: IconButton(
                        onPressed: (){
                        },
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        icon: Image.asset('assets/png/img_552316.png',
                          color: Colors.black54,
                          fit: BoxFit.contain,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text("Apply Discount ", style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                    ),
                  ],
                )
              ),

              Divider(thickness: 1, color: Colors.deepOrangeAccent),

              Expanded(
                child: Scrollbar(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[

                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                          child: Text('Discount Type',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),)
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
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.deepOrangeAccent.withOpacity(0.8), width: 1)
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              //Add more decoration as you want here
                              //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                            ),
                            isExpanded: true,
                            hint: const Text(
                              'Select Discount Type', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
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
                          padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                          child: Text('Full Name',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),)
                      ),

                      SizedBox(height: 40,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            controller: _name,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.7),
                                    width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              hintText: 'Full Name ex. (Lastname, Firstname)',
                              hintStyle: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
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
                        padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                        child: Text('ID. Picture',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),)
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
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please capture an image!';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'No File Choosen',
                                  hintStyle: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
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
                        padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                        child: Text('ID. Number',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),)
                      ),

                      SizedBox(height: 40,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child:TextFormField(
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            controller: _idNumber,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter some value!';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'ID. Number',
                              hintStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.7),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
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

        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.black,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          onPressed:(){
            Navigator.pop(context);
          },
          child:Text("CLOSE",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 12.0),),
        ),

        OutlinedButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.deepOrangeAccent,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
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
      ],
    );
  }
}

Route _trackOrder() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TrackOrder(),
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
