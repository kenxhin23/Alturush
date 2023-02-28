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

  var townId, barrioId;
  var stores;
  var items;
  var index = 0;

  int shipping;

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
      isLoading = false;
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
      isLoading = false;
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
      isLoading = false;
    });
  }

  Future loadCart() async {
    var res = await db.gcLoadCartData();
    if (!mounted) return;
    setState(() {
      loadCartData = res['user_details'];
      items = loadCartData.length;
      // print(loadCartData);
      isLoading = false;
    });
  }

  Future getBill(priceGroup, conFee) async{
    var res = await db.getBill(priceGroup);
    if (!mounted) return;
    setState((){
      totalLoading = false;
      getBillList = res['user_details'];
      bill = double.parse(getBillList[0]['d_subtotal']);
      grandTotal = bill+(conFee);
      totalLoading = false;
      isLoading = false;
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
      getConFee(lt);
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
      isLoading = false;
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
      isLoading = false;
    });
  }

  submitOrder2() async{
    await db.submitOrder2(
      widget.groupValue,
      widget.deliveryDateData,
      widget.deliveryTimeData,
      widget.buData,
      widget.grandTotal,
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

                        Text("Select your address",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.green)),

                        OutlinedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20))),
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                            overlayColor: MaterialStateProperty.all(Colors.black12),
                            side: MaterialStateProperty.all(BorderSide(
                              color: Colors.green,
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
                    )
                  )
                ),

                Divider(thickness: 1, color: Colors.green),

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
                                        padding: EdgeInsets.only(top: 5,),
                                        child: Text('${getItemsData[index]['firstname']} ${getItemsData[index]['lastname']}',style: TextStyle(fontSize: 14, color: Colors.black),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Text('${getItemsData[index]['street_purok']}, ${getItemsData[index]['d_brgName']}, \n${getItemsData[index]['d_townName']}, '
                                            '${getItemsData[index]['zipcode']}, ${getItemsData[index]['d_province']}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.black54)),
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
    super.initState();
    gcLoadPriceGroup();
    onRefresh();
    getBuSegregate();
    getPlaceOrderData();
    initController();
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
            statusBarColor: Colors.green[300], // Status bar
          ),
          backgroundColor: Colors.white,
          elevation: 0.1,
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Summary (Pick-up)",style: GoogleFonts.openSans(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 18.0),),
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

                        Divider(thickness: 1, color: Colors.green),

                        SizedBox(height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                child: new Text("CUSTOMER ADDRESS",
                                  style: TextStyle(color: Colors.green, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 14.0),
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
                                      backgroundColor: MaterialStateProperty.all(Colors.green),
                                      overlayColor: MaterialStateProperty.all(Colors.black12),
                                      side: MaterialStateProperty.all(BorderSide(
                                        color: Colors.green,
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
                          )
                        ),

                        Divider(thickness: 1, color: Colors.green),

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

                        Divider(thickness: 1, color: Colors.green),

                        SizedBox(height: 30,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                            child: Text("TOTAL SUMMARY", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.green)),
                          ),
                        ),

                        Divider(thickness: 1, color: Colors.green),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('No. of Store(s)',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                              Text('${widget.stores}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
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

                              Text('${widget.items}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                              Text('₱ ${oCcy.format(widget.subTotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Picking Fee',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),

                              Text('₱ ${oCcy.format(widget.pickingFee)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.normal)),
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

                              Text('₱ ${oCcy.format(widget.grandTotal)}',style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14.0, fontWeight: FontWeight.bold)),
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

                        Divider(thickness: 1, color: Colors.green),
                      ],
                    ),
                  )
                ),
              ),
              // child:Scrollbar(
              //   child: ListView(
              //     children: [
              //       totalLoading
              //           ? Padding(
              //         padding:EdgeInsets.fromLTRB(20.0,20.0, 5.0, 20.0),
              //         child: Center(
              //           child: CircularProgressIndicator(
              //             valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
              //           ),
              //         ),
              //       ) : Wrap(
              //         direction: Axis.horizontal,
              //         children:[
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Padding(
              //                 padding:EdgeInsets.fromLTRB(20.0, 7.0, 5.0, 5.0),
              //                 child: new Text("Picking Fee:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
              //               ),
              //               Padding(
              //                 padding:EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 5.0),
              //                 child: new Text("₱ ${oCcy.format(conFee*lt)}", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
              //               ),
              //             ],
              //           ),
              //
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Padding(
              //                 padding:EdgeInsets.fromLTRB(20.0, 7.0, 5.0, 5.0),
              //                 child: new Text("Total:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
              //               ),
              //               Padding(
              //                 padding:EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 5.0),
              //                 child: new Text("₱ ${oCcy.format(bill)}", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
              //               ),
              //             ],
              //           ),
              //
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Padding(
              //                 padding:EdgeInsets.fromLTRB(20.0, 7.0, 5.0, 5.0),
              //                 child: new Text("Grand Total:", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
              //               ),
              //
              //               Padding(
              //                 padding:EdgeInsets.fromLTRB(20.0, 7.0, 20.0, 5.0),
              //                 child: new Text("₱ ${oCcy.format(grandTotal)}", style: TextStyle(color: Colors.black87.withOpacity(0.8),fontStyle: FontStyle.normal,fontSize: 20.0),),
              //               ),
              //            ],
              //           ),
              //          ],
              //         ),
              //         Divider(
              //           color: Colors.black87.withOpacity(0.8),
              //         ),
              //
              //         ListView.builder(
              //         physics: BouncingScrollPhysics(),
              //         shrinkWrap: true,
              //         itemCount: widget.buNameData == null ? 0: widget.buNameData.length,
              //         itemBuilder: (BuildContext context, int index) {
              //             // return Text(widget.buNameData[index]);
              //             return Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //
              //                   Padding(
              //                     padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
              //                     child: new Text(widget.buNameData[index], style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 22.0),),
              //                   ),
              //                   Padding(
              //                     padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
              //                     child: new Text("Total: ₱ ${widget.totalData[index]}", style: TextStyle(fontStyle: FontStyle.normal,fontSize: 20.0),),
              //                   ),
              //                   Padding(
              //                     padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
              //                     child: new Text("Picking fee: "+conFee.toString(), style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 20.0),),
              //                   ),
              //                   Padding(
              //                     padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
              //                     child: new Text("Pick up date: ${widget.deliveryDateData[index]} : ${widget.deliveryTimeData[index]}" , style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 20.0),),
              //                   ),
              //                   // Padding(
              //                   //   padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
              //                   //   child: new Text("Remarks ${widget.placeRemarksData[index]}", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 20.0),),
              //                   // ),
              //                   // Padding(
              //                   //   padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
              //                   //   child: new Text(widget.placeRemarks[index], style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 18.0),),
              //                   // ),
              //                 ]);
              //               }
              //             ),
              //             Padding(
              //               padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
              //               child: new Text("MOP : ${widget.modeOfPayment}", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 20.0),
              //               ),
              //             ),
              //
              //
              //     ],
              //   ),
              // ),
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
                          Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new CreateAccountSignIn())).then((val)=>{onRefresh()});
                          // Navigator.of(context).push(_signIn());
                        }else{
                          print(widget.groupValue);
                          print(widget.deliveryDateData);
                          print(widget.deliveryTimeData);
                          print(widget.buData);
                          print(widget.subTotal);
                          print(widget.pickingFee);
                          print(widget.placeRemarksData);
                          print(widget.pickUpOrDelivery);
                          submitOrder2();

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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.paperplane),
                            SizedBox(width: 5),
                            Text("CHECKOUT",
                              style: TextStyle(
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
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
