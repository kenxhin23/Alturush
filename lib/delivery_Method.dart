import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'submit_delivery.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'submit_pickup.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PlaceOrder extends StatefulWidget {
  @override
  _PlaceOrder createState() => _PlaceOrder();
}

class _PlaceOrder extends State<PlaceOrder>    with SingleTickerProviderStateMixin {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final changeFor = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  final placeOrderTown = TextEditingController();
  final placeOrderBrg = TextEditingController();
  final placeContactNo = TextEditingController();
  final placeRemarks = TextEditingController();
  final street = TextEditingController();
  final houseNo = TextEditingController();
  final deliveryDate = TextEditingController();
  final deliveryTime = TextEditingController();
  final changeForPickup = TextEditingController();
  final especialInstruction = TextEditingController();
  double subtotal = 0;
  List getBu;
  List getTenant;
  List getItemsData;
  List placeOrder;
  List getOrder;
  List getSubtotal;
  List barrioData;
  List getAllowLoc;
  List getTenantLimit;
  List checkFee;
  var isLoading = true;
  var townId;
  var barrioId;
  double deliveryCharge = 0;
  double grandTotal = 0;
  DateTime selectedDate = DateTime.now();
  int buCount = 1;

  //date and time for pick up
  var val;
  var businessUnit = {};
  var date;
  var timeFrom;
  var timeTo;
  var indexArr = [];
  var options={};
  var btnText;
  var test = [];
  var timeCount;
  var _globalTime,_globalTime2;
  var optional = "";
  var _today;
  String changeForFinal;



//   submitPickUp() async {
// //    print(businessUnit);
// //    print(date);
// //    print(timeFrom);
// //    print(timeTo);
// //    print(options);
// //    print(businessUnit);
// //    var save = {};
// //
// //      save['data'] = businessUnit;
// //      print(options);
// //   await db.savePickup(options);
// //    submitPickUpRoute();
//     if (getBu.length == options.length || changeForPickup.text == "") {
//       FocusScope.of(context).requestFocus(FocusNode());
//       Navigator.of(context).push(_submitOrder(options,groupValue,changeForPickup.text,subtotal));
//     }
//     else {
//       showDialog<void>(
//         context: context,
//         builder: (BuildContext context) {
//           return  AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(8.0))
//             ),
//             contentPadding: EdgeInsets.symmetric(horizontal:1.0, vertical: 20.0),
//             title:Row(
//               children: <Widget>[
//                 Text('Notice',style:TextStyle(fontSize: 18.0),),
//               ],
//             ),
//             content: SingleChildScrollView(
//               child: ListBody(
//                 children: <Widget>[
//                   Padding(
//                     padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
//                     child:Center(child:Text("Please set up delivery date in every store")),
//                   ),
//
//                 ],
//               ),
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 child: Text('Done',style: TextStyle(
//                   color: Colors.deepOrange,
//                 ),),
//                 onPressed: () async{
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

  Future getPlaceOrderData() async{
    getTrueTime();
    var res = await db.getPlaceOrderData();
    var res1 = await db.checkAllowedPlace();
    var res2 = await db.checkFee();
    checkFee = res2['user_details'];
    if (!mounted) return;
    setState(() {
      placeOrder = res['user_details'];
      placeContactNo.text = placeOrder[0]['d_contact'];
      placeOrderBrg.text = placeOrder[0]['d_brgName'];
      deliveryCharge = double.parse(checkFee[0]['d_charge_amt']);
      if(res1 == 'false'){
        placeOrderTown.text = "";
        placeOrderBrg.text = "";
      }
      else{
        placeOrderTown.text = placeOrder[0]['d_townName'];
        placeOrderBrg.text = placeOrder[0]['d_brgName'];
        grandTotal = subtotal + deliveryCharge;
        townId = int.parse(getAllowLoc[0]['d_towd_id']);
        barrioId = int.parse(placeOrder[0]['d_brgId']);

      }
    });
  }

  Future getOrderData() async{
    var res = await db.getOrderData();
    if (!mounted) return;
    setState(() {
      getOrder = res['user_details'];
    });
  }

  Future refresh() async{
    getAllowedLoc();
    getPlaceOrderData();
  }

  Future getAllowedLoc() async{
    var res = await db.getAllowedLoc();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      getAllowLoc = res['user_details'];
    });
  }

//  Future trapTenantLimit() async{
//    var res = await db.trapTenantLimit();
//    if (!mounted) return;
//    setState(() {
//      isLoading = false;
//      getTenantLimit = res['user_details'];
//
//    });
//  }

  Future loadBarrio() async {
//    var res = await db.getBarrio(townId);
//    if (!mounted) return;
//    setState(() {
//      barrioData = res;
//    });
  }

  Future getSubTotal() async{
    var res = await db.getSubTotal();
    if (!mounted) return;
    setState(() {
      getSubtotal = res['user_details'];
      subtotal = double.parse(getSubtotal[0]['d_subtotal']);
    });
  }

  Future getBuSegregate() async{
    var res = await db.getBuSegregate();
    if (!mounted) return;
    setState(() {
      getBu = res['user_details'];
    });
  }


  Future getTenantSegregate() async{
    var res = await db.getTenantSegregate();
    if (!mounted) return;
    setState(() {
      getTenant = res['user_details'];
    });
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
                      return Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 5.0),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
//                            Text('$f. ${getItemsData[index]['d_bu_name']} - ${getItemsData[index]['d_tenant']} ',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
//                            Text('₱${oCcy.format(double.parse(getItemsData[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                            Text('$f. ${getItemsData[index]['d_prodName']} ',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                            Text('₱${getItemsData[index]['d_price']}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                            Text(' x ${getItemsData[index]['d_quantity']}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
                          ],
                        ),
//                          child: Text('$f. ${lGetAmountPerTenant[index]['d_bu_name']} - ${lGetAmountPerTenant[index]['d_tenant']}  ₱${oCcy.format(double.parse(lGetAmountPerTenant[index]['d_subtotalPerTenant']))}',style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),

                      );

                    },
                  ),
                ),
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

  void selectTown() async {
//    loadTowns();
//    loadBarrio();
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

    var res = await db.getAllowedLoc();
    if (!mounted) return;
    setState(() {
      isLoading = false;
      getAllowLoc = res['user_details'];
    });
    Navigator.pop(context);
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select town'),
          content: Container(
            height: 400.0, // Change as per your requirement
            width: 300.0, // Change as per your requirement
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getAllowLoc == null ? 0 : getAllowLoc.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        placeOrderBrg.clear();
                        townId = int.parse(getAllowLoc[index]['d_towd_id']);
//                          *getBu.length
                        loadBarrio();
                        placeOrderTown.text = getAllowLoc[index]['d_town'];
                        deliveryCharge = double.parse(getAllowLoc[index]['d_charge_amt']);
                        grandTotal = subtotal + deliveryCharge;
                      });
                      Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(getAllowLoc[index]['d_town']),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
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

  void selectBarrio() async {

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

    var res = await db.getBarrioCi(townId);
    if (!mounted) return;
    setState(() {
      barrioData = res['user_details'];
    });
    Navigator.pop(context);
//    loadBarrio();
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Center(
            child: Text(
              'Select barangay',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          content: Container(
            height: 400.0,
            width: 300.0,
            child: RefreshIndicator(
              onRefresh: loadBarrio,
              child: Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: barrioData == null ? 0 : barrioData.length,
                  itemBuilder: (BuildContext context, int index) {

                    return InkWell(
                      onTap: () {

                        placeOrderBrg.text = barrioData[index]['brgy_name'];
                        barrioId = int.parse(barrioData[index]['brgy_id']);

                        Navigator.of(context).pop();
                      },
                      child: ListTile(
                        title: Text(barrioData[index]['brgy_name']),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                placeOrderBrg.clear();
              },
            ),
          ],
        );
      },
    );
  }

  Future toRefresh() async{
    getOrderData();
    getSubTotal();
  }

  submitPlaceOrder(){
    String x = changeFor.text;
    String str = x;
    changeForFinal = str.replaceAll(',', '');
    FocusScope.of(context).requestFocus(FocusNode());
    if(getTenantLimit?.isNotEmpty ?? true){
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
              "Hello!",
              style: TextStyle(fontSize: 18.0),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding:EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                    child:Center(child:Text(("This order must have a minimum amount of ₱${oCcy.format(300)} per tenant please check the tenant's subtotal, thank you."))),
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
    } else if(_today == false && deliveryTime.text.isEmpty){
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
//                      padding:EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
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
    }
    else if(deliveryDate.text.isEmpty ||placeOrderTown.text.isEmpty || placeOrderBrg.text.isEmpty || placeContactNo.text.isEmpty || placeRemarks.text.isEmpty || placeContactNo.text.length < 10 || changeFor.text.isEmpty)
    {
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
                    child: Text("Some fields invalid or empty"),
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
    }
    else {
      // Navigator.of(context).push(_submitOrder(changeFor.text,townId,barrioId,placeContactNo.text,placeOrderTown.text,placeOrderBrg.text,street.text,houseNo.text,placeRemarks.text,changeForFinal,deliveryCharge,grandTotal,deliveryDate.text,deliveryTime.text,groupValue));
    }
  }

  List trueTime;
  getTrueTime() async{
    var res = await db.getTrueTime();
    if (!mounted) return;
    setState(() {
      trueTime = res['user_details'];

    });
  }

  @override
  void initState(){
    super.initState();
    getPlaceOrderData();
    getOrderData();
    getSubTotal();
    getAllowedLoc();
    getBuSegregate();
    getTenantSegregate();
//    trapTenantLimit();
    getLastStreet();
    _tabController = TabController(vsync: this, length: 2);
  }
  TabController _tabController;
  getLastStreet() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    street.text =  prefs.getString('street');
    houseNo.text = prefs.getString('houseNo');
    placeRemarks.text = prefs.getString('placeRemark');
  }

  @override
  void dispose() {
    super.dispose();
    placeContactNo.dispose();
    placeRemarks.dispose();
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

      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 0.1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text("Checkout",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              indicatorColor: Colors.deepOrange,
              tabs: [
                Tab(
                  child: Text(
                    "Delivery",
                    style: GoogleFonts.openSans(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0),
                  ),
                ),
                Tab(
                  child: Text(
                    "Pick up",
                    style: GoogleFonts.openSans(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0),
                  ),
                ),
              ],
            ),
          ),
          body: isLoading
              ? Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
          ) :
          TabBarView(
            controller: _tabController,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child:Scrollbar(
                      child: RefreshIndicator(
                        onRefresh: toRefresh,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[

                            Visibility(
                              visible: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                    child: new Text("*Please enter complete address for this delivery*", style: GoogleFonts.openSans(color: Colors.deepOrange, fontStyle: FontStyle.normal,fontSize: 12.0),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 3, 5, 5),
                                    child: new Text("Town *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(3.0),
                                      onTap: (){
                                        FocusScope.of(context).requestFocus(FocusNode());
//                                    placeOrderBrg.clear();
                                        selectTown();
                                      },
                                      child: IgnorePointer(
                                        child: new TextFormField(
                                          textInputAction: TextInputAction.done,
                                          cursorColor: Colors.deepOrange,
                                          controller: placeOrderTown,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.business,color: Colors.grey,),
                                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
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
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("Barangay *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(3.0),
                                      onTap: (){
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        placeOrderTown.text.isEmpty ? print('no town selected') : selectBarrio();
                                      },
                                      child: IgnorePointer(
                                        child: new TextFormField(
                                          textInputAction: TextInputAction.done,
                                          cursorColor: Colors.deepOrange,
                                          controller: placeOrderBrg,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.home,color: Colors.grey,),
                                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
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
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("Phone Number *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width:screenSize/5.5,
                                          child: new TextFormField(
                                            cursorColor: Colors.deepOrange,
                                            enabled: false,
                                            decoration: InputDecoration(
                                              hintText:"+63",
                                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                              focusedBorder:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                              ),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Flexible(
                                          //BlacklistingTextInputFormatter
                                          child: new TextFormField(
                                            maxLength: 10,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.deny(new RegExp('[.-]'))],
                                            cursorColor: Colors.deepOrange,
                                            controller: placeContactNo,
                                            decoration: InputDecoration(
                                              counterText: "",
                                              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                              focusedBorder:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                              ),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                            ),
//                                        focusNode: textSecondFocusNode,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("Street *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,
                                      controller: street,
                                      decoration: InputDecoration(

                                        prefixIcon: Icon(Icons.streetview,color: Colors.grey,),
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("House number(optional)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                                      controller: houseNo,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.confirmation_number,color: Colors.grey,),
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("Landmark *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,

                                      controller: placeRemarks,
                                      decoration: InputDecoration(
                                        hintText:"E.g Near at plaza",
                                        prefixIcon: Icon(Icons.place,color: Colors.grey,),
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("Delivery date *", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: InkWell(
                                      onTap: (){
                                        getTrueTime();
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        showDialog<void>(
                                          context: context,
//                                        barrierDismissible: false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                                              ),
                                              title: Text("Set date for delivery",style: TextStyle(fontSize: 15.0),),
                                              contentPadding:
                                              EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                              content: Container(
                                                height:290.0, // Change as per your requirement
                                                width: 360.0, // Change as per your requirement
                                                child: Scrollbar(
                                                  child:ListView.builder(
                                                    physics: BouncingScrollPhysics(),
//                                                  shrinkWrap: true,
                                                    itemCount: 4,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      String tom = "";
                                                      int n = 0;
                                                      n = index;
                                                      if(n==0){
                                                        tom = "(Today)";
                                                      }

                                                      var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                      var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                      final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                      final String formatted = formatter.format(d2);
                                                      return InkWell(
                                                        onTap: (){
                                                          deliveryDate.text =formatted;
                                                          Navigator.of(context).pop();
                                                          if(index == 0){
                                                            setState(() {
                                                              optional = "(Optional)";
                                                              _today = true;
                                                              timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"19:30")).inHours;
                                                              timeCount = timeCount.abs();
                                                              _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
                                                              _globalTime2 = _globalTime.hour;
                                                            });
                                                          }
                                                          else{
                                                            setState(() {
                                                              optional = "(Required)";
                                                              _today = false;
                                                              timeCount = 12;
                                                              _globalTime = new DateTime.now();
                                                              _globalTime2 = 07;
                                                            });
                                                          }

                                                        },
                                                        child: Column(
                                                          children: [
                                                            Divider(color: Colors.transparent,),
                                                            Container(
                                                              child:ListTile(
                                                                title: Text('${formatted.toString()} $tom',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 20.0),),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                    },
                                                  ),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    'Clear',
                                                    style: TextStyle(
                                                      color: Colors.deepOrange,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    deliveryDate.clear();
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: IgnorePointer(
                                        child: new TextFormField(
                                          textInputAction: TextInputAction.done,
                                          cursorColor: Colors.deepOrange,
                                          controller: deliveryDate,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.date_range,color: Colors.grey,),
                                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
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
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("Delivery time $optional", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: InkWell(
                                      onTap: (){
                                        getTrueTime();
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        showDialog<void>(
                                          context: context,
//                                          barrierDismissible: false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                                              ),
                                              title: Text("Set date for delivery",style: TextStyle(fontSize: 15.0),),
                                              contentPadding:
                                              EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                              content: Container(
                                                height:290.0, // Change as per your requirement
                                                width: 360.0, // Change as per your requirement
                                                child: Scrollbar(
                                                  child:  ListView.builder(
                                                      physics: BouncingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount:  timeCount,
                                                      itemBuilder: (BuildContext context, int index1) {
                                                        int t = index1;
                                                        t++;
//                                                              var d1 = DateTime.parse(trueTime[0]['date_today']);
                                                        final now =  _globalTime;
                                                        final dtFrom = DateTime(now.year, now.month, now.day, _globalTime2+t, 0+30, now.minute, now.second);
                                                        final dtTo = DateTime(now.year, now.month, now.day, 8+t, 0+30);
                                                        final format = DateFormat.jm();  //"6:00 AM"
                                                        String from = format.format(dtFrom);
                                                        String to = format.format(dtTo);
                                                        return InkWell(
                                                          onTap: (){
                                                            deliveryTime.text = from;
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Container(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Row (
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
                                                                        child: Text('${from.toString()}',style: TextStyle(fontSize: 16.0),),
                                                                      ),
                                                                    ]
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    'Clear',
                                                    style: TextStyle(
                                                      color: Colors.deepOrange,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    deliveryTime.clear();
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: IgnorePointer(
                                        child: new TextFormField(
                                          textInputAction: TextInputAction.done,
                                          cursorColor: Colors.deepOrange,
                                          controller: deliveryTime,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.timelapse,color: Colors.grey,),
                                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
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
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("In case the product is out of stock", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  _myRadioButton(
                                    title: "Cancel the entire order",
                                    value: 0,
                                    onChanged: (newValue) => setState((){
                                      groupValue = newValue;

                                    }),
                                  ),

                                  _myRadioButton(
                                    title: "Remove it from my order",
                                    value: 1,
                                    onChanged: (newValue) => setState((){
                                      groupValue = newValue;

                                    }),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child:ExpansionTileCard(
                                      elevation:0.0,
                                      baseColor:Colors.transparent,
                                      title: Text('Subtotal: ₱ ${oCcy.format(subtotal)}',style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,10.0),
                                              child: new Text("*click tenant to view your item(s)*", style: GoogleFonts.openSans(color: Colors.deepOrange, fontStyle: FontStyle.normal,fontSize: 12.0),),
                                            ),

                                          ],
                                        ),

                                        ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:  getBu == null ? 0 : getBu.length,
                                            itemBuilder: (BuildContext context, int index0) {
//                                            test = getBu[index0]['d_bu_name'];
                                              int num = index0;
                                              num++;
                                              return Container(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,10.0),
                                                      child: Text('$num. ${getBu[index0]['d_bu_name'].toString()}',style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold ,fontSize: 15.0)),
                                                    ),
//                                              Padding(
//                                                padding: EdgeInsets.fromLTRB(17.0,0.0, 0.0,10.0),
//                                                child: Text('${getBu[index0]['d_tenant'].toString()}',style: TextStyle(fontSize: 15.0)),
//                                              ),
                                                    ListView.builder(
                                                        physics: BouncingScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:  getTenant == null ? 0 : getTenant.length,
                                                        itemBuilder: (BuildContext context, int index) {
                                                          return Visibility(
                                                            visible: getTenant[index]['d_buid'] != getBu[index0]['d_bu_id'] ? false : true,
                                                            child: Container(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Padding(
                                                                    padding: EdgeInsets.fromLTRB(20.0,0.0, 20.0,1.0),
                                                                    child: OutlinedButton(
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
                                                                      // borderSide: BorderSide(color: Colors.white),
                                                                      // highlightedBorderColor: Colors.deepOrange,
                                                                      // highlightColor: Colors.transparent,
//                                                                    child: Text('${getTenant[index]['d_tenantName']} ₱${oCcy.format(double.parse(getTenant[index]['d_subtotal']))}'),
                                                                      child:Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text('${getTenant[index]['d_tenantName']}'),
                                                                          Text('₱${oCcy.format(double.parse(getTenant[index]['d_subtotal']))}'),
                                                                        ],
                                                                      ),
                                                                      // color: Colors.grey.withOpacity(0.1),
                                                                      // shape: RoundedRectangleBorder(
                                                                      //     borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                                                      onPressed: (){
                                                                        displayBottomSheet(context,getTenant[index]['d_tenantId'],getBu[index0]['d_bu_name'],getTenant[index]['d_tenantName']);
//                                                                      displayOrder(getTenant[index]['d_tenantId']);
                                                                      },
                                                                    ),
//                                                                    child: Text(getTenant[index]['d_tenantId'] , style: TextStyle(fontStyle: FontStyle.normal,fontSize: 16.0),),

                                                                  ),

                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.fromLTRB(49.0, 7.0, 5.0, 5.0),
                                    child: new Text("Rider's fee: ₱ ${ oCcy.format(deliveryCharge)}", style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding:EdgeInsets.fromLTRB(49.0, 7.0, 5.0, 5.0),
                                    child: new Text("Total Amount: ₱ ${ oCcy.format(grandTotal).toString()}", style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("Customer tender(ie.4,000.00)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,
                                      controller: changeFor,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),


                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: SleekButton(
                            onTap: () async {
                              submitPlaceOrder();

                            },
                            style: SleekButtonStyle.flat(
                              color: Colors.deepOrange,
                              inverted: false,
                              rounded: true,
                              size: SleekButtonSize.big,
                              context: context,
                            ),
                            child: Center(
                              child: Text(
                                "Next",
                                style: GoogleFonts.openSans(
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child:Scrollbar(
                          child: RefreshIndicator(
                              onRefresh: toRefresh,
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                                    child: new Text("*Please enter desired date & time for pick up*", style: GoogleFonts.openSans(color: Colors.deepOrange, fontStyle: FontStyle.normal,fontSize: 12.0),),
                                  ),

                                  ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:  getBu == null ? 0 : getBu.length,
                                      itemBuilder: (BuildContext context, int index0) {
//                                  test = getBu[index0]['d_bu_name'];

                                        var num = index0;
                                        num++;
                                        return Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child:  Padding(
                                                      padding: EdgeInsets.fromLTRB(17.0,10.0, 0.0,10.0),
                                                      child: Text('$num. ${getBu[index0]['d_bu_name'].toString()}',style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold ,fontSize: 15.0)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(10.0,10.0, 14.0,10.0),
                                                    child: OutlinedButton(
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
                                                      // highlightedBorderColor: Colors.deepOrange,
                                                      // highlightColor: Colors.transparent,
                                                      // child: Text("SET",style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 13.0)),
                                                      // borderSide: BorderSide(color: Colors.deepOrange),
                                                      // shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                      onPressed: () async{
//                                                  businessUnit[index0]['d_bu_id'] = getBu[index0]['d_bu_id'];
//                                                  businessUnit.add(10);
                                                        showDialog<void>(
                                                          context: context,
                                                          barrierDismissible: false, // user must tap button!
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                                                              ),
                                                              title: Text("Set date & time for pick up",style: TextStyle(fontSize: 15.0),),
                                                              contentPadding:
                                                              EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
                                                              content: Container(
                                                                height:350.0, // Change as per your requirement
                                                                width: 360.0, // Change as per your requirement
                                                                child: Scrollbar(
                                                                  child:ListView.builder(
                                                                    shrinkWrap: true,
                                                                    itemCount: 4,
                                                                    itemBuilder: (BuildContext context, int index) {
                                                                      String tom = "";
                                                                      int n = 0;
                                                                      n = index;
                                                                      if(n==0){
                                                                        tom = "(Today)";
                                                                      }
                                                                      var d1 = new DateTime.now();
                                                                      var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                                      final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                                      final String formatted = formatter.format(d2);
                                                                      return Column(
                                                                        children: [
                                                                          Divider(),
                                                                          Container(
                                                                            child:ListTile(
                                                                              title: Text('${formatted.toString()} $tom',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 20.0),),
                                                                            ),
                                                                          ),

                                                                          ListView.builder(
                                                                              physics: BouncingScrollPhysics(),
                                                                              shrinkWrap: true,
                                                                              itemCount:  10,
                                                                              itemBuilder: (BuildContext context, int index1) {

                                                                                int t = index1;
                                                                                t++;
                                                                                final now = new DateTime.now();
                                                                                final dtFrom = DateTime(now.year, now.month, now.day, 07+t, 0+30, now.minute, now.second);
                                                                                final dtTo = DateTime(now.year, now.month, now.day, 8+t, 0+30);
                                                                                final format = DateFormat.jm();  //"6:00 AM"
                                                                                String from = format.format(dtFrom);
                                                                                String to = format.format(dtTo);
                                                                                return InkWell(
                                                                                  onTap: (){
                                                                                    setState(() {
                                                                                      date = formatted;
                                                                                      timeFrom = from;
                                                                                      timeTo = to;
                                                                                      val = index;
                                                                                      options[getBu[index0]['d_bu_id']]='$date'' ''$timeFrom';

                                                                                      Navigator.of(context).pop();
                                                                                    });
                                                                                  },
                                                                                  child: Container(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: <Widget>[
                                                                                        Row (
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: <Widget>[
                                                                                              Padding(

                                                                                                padding: EdgeInsets.fromLTRB(30.0,20.0, 0.0,20.0),
                                                                                                child: Text('${from.toString()} - $to',style: TextStyle(fontSize: 16.0),),
                                                                                              ),

                                                                                            ]
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
                                                                          ),

                                                                        ],
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
//                                                        actions: <Widget>[
//                                                          FlatButton(
//                                                            child: Text(
//                                                              'Close',
//                                                              style: TextStyle(
//                                                                color: Colors.deepOrange,
//                                                              ),
//                                                            ),
//                                                            onPressed: () {
//
//                                                              Navigator.of(context).pop();
//                                                            },
//                                                          ),
//                                                          FlatButton(
//                                                            child: Text(
//                                                              'Ok',
//                                                              style: TextStyle(
//                                                                color: Colors.deepOrange,
//                                                              ),
//                                                            ),
//                                                            onPressed: () {
//                                                              options[getBu[index0]['d_bu_id']]='$date'' ''$timeFrom';
//                                                              Navigator.of(context).pop();
//                                                            },
//                                                          ),
//                                                        ],
                                                            );
                                                          },
                                                        );

                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ListView.builder(
                                                  physics: BouncingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:  getTenant == null ? 0 : getTenant.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return Visibility(
                                                      visible: getTenant[index]['d_buid'] != getBu[index0]['d_bu_id'] ? false : true,
                                                      child: Container(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: EdgeInsets.fromLTRB(15.0,0.0, 0.0,1.0),
                                                              child: TextButton(
                                                                style: TextButton.styleFrom(
                                                                  primary: Colors.blue,
                                                                  onSurface: Colors.red,
                                                                ),
                                                                child: Text('${getTenant[index]['d_tenantName']} ₱${oCcy.format(double.parse(getTenant[index]['d_subtotal']))}'),
                                                                onPressed: (){
                                                                  displayOrder(getTenant[index]['d_tenantId']);
                                                                },
                                                              ),
//                                                                    child: Text(getTenant[index]['d_tenantId'] , style: TextStyle(fontStyle: FontStyle.normal,fontSize: 16.0),),

                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                  ),

                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("Customer tender(ie.4,000.00)", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                                    child: new TextFormField(
                                      textInputAction: TextInputAction.done,
                                      cursorColor: Colors.deepOrange,
                                      controller: changeForPickup,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                      ),
                                    ),
                                  ),


                                  Padding(
                                    padding: EdgeInsets.fromLTRB(35, 30, 5, 5),
                                    child: new Text("In case the product is out of stock", style: GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 15.0),),
                                  ),
                                  _myRadioButton(
                                    title: "Cancel the entire order",
                                    value: 0,
                                    onChanged: (newValue) => setState((){
                                      groupValue = newValue;

                                    }),
                                  ),

                                  _myRadioButton(
                                    title: "Remove it from my order",
                                    value: 1,
                                    onChanged: (newValue) => setState((){
                                      groupValue = newValue;

                                    }),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding:EdgeInsets.fromLTRB(49.0, 7.0, 5.0, 5.0),
                                    child: new Text("Total Amount: ₱ ${ oCcy.format(grandTotal).toString()}", style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 20.0),),
                                  ),
                                ],
                              )
                          )
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: SleekButton(
                            onTap: () {
                              // Navigator.of(context).push(_submitOrder(changeForPickup.text,townId,barrioId,placeContactNo.text,placeOrderTown,placeOrderBrg,street,houseNo,placeRemarks.text,changeFor,deliveryCharge,grandTotal,deliveryDate,deliveryTime,groupValue));
                            },

                            style: SleekButtonStyle.flat(
                              color: Colors.deepOrange,
                              inverted: false,
                              rounded: true,
                              size: SleekButtonSize.big,
                              context: context,
                            ),
                            child: Center(
                              child: Text(
                                "Next",
                                style: GoogleFonts.openSans(
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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


// Route _submitOrder(changeForText,townId,barrioId,contactNo,placeOrderTown,placeOrderBrg,street,houseNo,placeRemark,changeFor,deliveryCharge,grandTotal,deliveryDate,deliveryTime,groupValue) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => SubmitOrder(changeForText:changeForText,townId:townId,barrioId:barrioId,contactNo:contactNo,placeOrderTown:placeOrderTown,placeOrderBrg:placeOrderBrg,street:street,houseNo:houseNo,placeRemark:placeRemark,deliveryCharge:deliveryCharge,grandTotal:grandTotal,deliveryDate:deliveryDate,deliveryTime:deliveryTime,groupValue:groupValue),
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

//
// Route submitPickUpRoute(options,groupValue,changeForPickup,subtotal) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => SubmitPickUp(orders:options,groupValue:groupValue,changeForPickup:changeForPickup,subtotal:subtotal),
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