import 'package:arush/profile/addNewAddress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';
import 'package:intl/intl.dart';
import 'package:sleek_button/sleek_button.dart';
import '../track_order.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arush/create_account_signin.dart';

class GcPickUpFinal extends StatefulWidget {
  final groupValue;
  final deliveryDateData;
  final deliveryTimeData ;
  final buNameData;
  final buData;
  final totalData ;
  final convenienceData;
  final placeRemarksData;
  final modeOfPayment;
  final pickUpOrDelivery;
  final stores;
  final items;
  final subTotal;
  final pickingFee;
  final grandTotal;
  final priceGroup;
  final tempID;

  GcPickUpFinal({Key key, @required
    this.groupValue,
    this.deliveryDateData,
    this.deliveryTimeData,
    this.buNameData,
    this.buData,
    this.totalData,
    this.convenienceData,
    this.placeRemarksData,
    this.modeOfPayment,
    this.pickUpOrDelivery,
    this.stores,
    this.items,
    this.subTotal,
    this.pickingFee,
    this.grandTotal,
    this.priceGroup,
    this.tempID}) : super(key: key);
  @override
  _GcPickUpFinal createState() => _GcPickUpFinal();
}

class _GcPickUpFinal extends State<GcPickUpFinal> with TickerProviderStateMixin{
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");


  var isLoading = true;
  var totalLoading = true;
  var timeCount;
  var bill = 0.0;
  var fee = 0.00;
  var conFee = 0.0;
  var grandTotal = 0.0;
  var minimumAmount = 0.0;
  var lt = 0;
  var townId;
  var barrioId;
  var stores;
  var items;
  var index = 0;
  var shipping;

  List getBillList = [];
  List getConFeeList = [];
  List getBuName = [];
  List placeOrder = [];
  List getItemsData = [];
  List getBu = [];
  List loadPriceGroup = [];
  List loadCartData = [];
  List<String> billPerBu = [];

  String priceGroup;
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
      // getTenantSegregate();
      // isLoading = false;
    });
    // print(placeOrder);
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
      // print(getItemsData);
      // isLoading = false;
    });
  }

  updateDefaultShipping(id,customerId) async{
    await db.updateDefaultShipping(id,customerId);
  }

  Future onRefresh() async {
    print('na refresh na');
    setState(() {
      getBuSegregate();
      getPlaceOrderData();
      gcLoadPriceGroup();
    });

  }

  Future gcLoadPriceGroup() async {
    var res = await db.gcLoadPriceGroup();
    if (!mounted) return;
    setState(() {
      loadPriceGroup = res['user_details'];
      for (int i=0;i<loadPriceGroup.length;i++) {

      }
      priceGroup = loadPriceGroup[0]['price_group'];
      // print(priceGroup);
      gcGroupByBu(priceGroup);
      loadCart();
      // isLoading = false;
    });
  }

  Future loadCart() async {
    var res = await db.gcLoadCartData();
    if (!mounted) return;
    setState(() {
      loadCartData = res['user_details'];
      items = loadCartData.length;
      // print(loadCartData);
      // isLoading = false;
    });
  }

  Future getBill(priceGroup, conFee) async{
    var res = await db.getBill(priceGroup);
    if (!mounted) return;
    setState((){
      // totalLoading = false;
      getBillList = res['user_details'];
      bill = double.parse(getBillList[0]['d_subtotal']);
      grandTotal = bill+(conFee);
      // totalLoading = false;
      // isLoading = false;
    });
  }

  Future gcGroupByBu(priceGroup) async{
    var res = await db.gcGroupByBu(priceGroup);
    if (!mounted) return;
    setState((){
      getBuName = res['user_details'];
      lt=getBuName.length;
      for(int q=0;q<getBuName.length;q++){
        billPerBu.add(getBuName[q]['total']);
        groupID = getBuName[q]['buId'];
        displayAdd(groupID);
      }
      stores = getBuName.length;
      // getConFee(lt);
      totalLoading = false;
      isLoading = false;
    });
  }

  Future getBuSegregate() async {
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
      for (int i=0; i<getBu.length; i++) {
      }
      print(getBu);
      print('mao ni ag group id');
      print(groupID);
      // isLoading = false;
    });
    // print(getBu.length);
  }


  Future getConFee(lt) async{
    var res = await db.getConFee();
    isLoading = false;
    if (!mounted) return;
    setState(() {
      getConFeeList = res['user_details'];
      fee = double.parse(getConFeeList[0]['pickup_charge']);
      conFee = fee * lt;
      minimumAmount = double.parse(getConFeeList[0]['minimum_order_amount']);
      getBill(priceGroup, conFee);
      // isLoading = false;
    });
  }

  submitOrder2() async{
    await db.submitOrder2(
      widget.groupValue,
      widget.deliveryDateData,
      widget.deliveryTimeData,
      widget.buData,
      grandTotal,
      widget.pickingFee,
      widget.placeRemarksData,
      widget.pickUpOrDelivery,
      widget.priceGroup,
      widget.tempID
    );
    getSuccessMessage();
  }

  getSuccessMessage() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Thank you for using Alturush delivery",
      confirmBtnColor: Colors.green,
      backgroundColor: Colors.green,
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
          Navigator.of(context).push(_profilePageRoute());
        }
      },
    );
  }

  Future displayAddresses(context) async{
    displayAdd(groupID);
    return showModalBottomSheet(
      transitionAnimationController: controller,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight:  Radius.circular(15),topLeft:  Radius.circular(15)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green[400],
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
                              color: Colors.green[400],
                              width: 1.0,
                              style: BorderStyle.solid),
                          ),
                        ),
                        onPressed:(){
                          Navigator.pop(context);
                          Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new AddNewAddress())).then((val)=>{onRefresh()});
                        },
                        child:Text("+ Add new",
                          style: GoogleFonts.openSans(color:Colors.green[400], fontWeight: FontWeight.bold, fontSize: 14.0),
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
                              activeColor: Colors.green,
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
                                    child: Text('${getItemsData[index]['d_contact']}',style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.normal, color: Colors.black),
                                    ),
                                  ),
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
                ),
              ],
            ),
          );
        });
      }
    );
  }

  @override
  void initState(){
    super.initState();
    gcLoadPriceGroup();
    onRefresh();
    getBuSegregate();
    getPlaceOrderData();
    initController();
    grandTotal = widget.subTotal + widget.pickingFee;
    print(widget.groupValue);
    print(widget.deliveryDateData);
    print(widget.deliveryTimeData);
    print(widget.buData);
    print(widget.totalData);
    print(widget.convenienceData);
    print(widget.placeRemarksData);
    print( widget.pickUpOrDelivery);
    print(widget.priceGroup);
    print(widget.tempID);
    // getBill();
    // getConFee();
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
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.green[400],
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
          title: Text("Summary (Pick-up)",
            style: GoogleFonts.openSans(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Expanded(
              child: Form(
                key: _key,
                child: RefreshIndicator(
                  color: Colors.green,
                  key: refreshKey,
                  onRefresh: onRefresh,
                  child: Scrollbar(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[

                        Container(
                          height: 40,
                          color: Colors.green[300],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: new Text("CUSTOMER ADDRESS",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.0),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(left: 5.0, right: 15.0),
                                child: SizedBox(
                                  height: 30,
                                  width: 175,
                                  child: OutlinedButton.icon(
                                    onPressed: () async{
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String username = prefs.getString('s_customerId');
                                      if(username == null){
                                        // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                                        Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                                      }else{
                                        getPlaceOrderData();
                                        displayAddresses(context).then((val) => {onRefresh()});
                                      }
                                    },
                                    label: Text('MANAGE ADDRESS',  style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 12.0, color: Colors.green)),
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                                      backgroundColor: MaterialStateProperty.all(Colors.white),
                                      overlayColor: MaterialStateProperty.all(Colors.black12),
                                      side: MaterialStateProperty.all(BorderSide(
                                          color: Colors.green,
                                          width: 1.0,
                                          style: BorderStyle.solid),
                                      ),
                                    ),
                                    icon: Wrap(
                                      children: [
                                        Icon(Icons.settings_outlined, color: Colors.green, size: 18,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),


                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                          child: Row(
                            children: <Widget>[
                              Text("Recipient: ",
                                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
                              ),
                              Text("${userName.toString()}",
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          child: Row(
                            children: <Widget>[
                              Text("Contact Number: ",
                                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black54),
                              ),
                              Text("${placeContactNo.toString()}",
                                style: TextStyle(fontSize: 14.0),
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
                              Text("$street, $placeOrderBrg, $placeOrderTown, $province",
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          )
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Row(
                            children: <Widget>[
                              Text("Landmark: ",
                                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black54),
                              ),
                              Flexible(
                                child: Text("$placeRemarks",
                                  style: TextStyle(fontSize: 14.0),
                                  maxLines: 6, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        ),

                        Container(
                          height: 40,
                          color: Colors.grey[200],
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(0),
                              child: Text("TOTAL SUMMARY",
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            ),
                          )
                        ),


                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("No. of Store(s)",
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text('${widget.stores}',
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("No. of Item(s)",
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text("${widget.items}",
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount',
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text('₱ ${oCcy.format(widget.subTotal)}',
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Picking Fee',
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),

                              Text('₱ ${oCcy.format(widget.pickingFee)}',
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          height: 40,
                          color: Colors.grey[200],
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TOTAL AMOUNT TO PAY',
                                  style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.green[400]),
                                ),
                                Text('₱ ${oCcy.format(grandTotal)}',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('PAYMENT METHOD',
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Text('Pay via CASH',
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
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
                          Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                        }else{
                          submitOrder2();
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
                              style: TextStyle(
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


Route _profilePageRoute() {
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

Route _addNewAddress() {
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
