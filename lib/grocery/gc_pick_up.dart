import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';
import 'package:intl/intl.dart';
import 'package:sleek_button/sleek_button.dart';
import 'gc_pick_up_final.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:arush/create_account_signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GcPickUp extends StatefulWidget {
  final stores;
  final items;
  final subTotal;
  final pickingFee;
  final grandTotal;
  final priceGroup;
  final tempID;
  final townID;

  const GcPickUp({Key key, this.stores, this.items, this.subTotal, this.pickingFee, this.grandTotal, this.priceGroup, this.tempID, this.townID}) : super(key: key);

  @override
  _GcPickUp createState() => _GcPickUp();
}

class _GcPickUp extends State<GcPickUp> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");

  List<TextEditingController> _deliveryDate = [];
  List<TextEditingController> _deliveryTime = [];
  List<TextEditingController> placeRemarks = [];
  List<TextEditingController> _specialInstruction = [];

  List<String> billPerBu = [];
  List<String> deliveryTimeData = [];
  List<String> deliveryDateData = [];
  List<String> totalData = [];
  List<String> convenienceData = [];
  List<String> placeRemarksData = [];
  List<String> specialInstruction = [];
  List<String> buData = [];
  List<String> buNameData = [];
  List<String> cont = [];
  List<String> _option = ['Cancel Item','Cancel Order'];

  List getGcItemsList = [];
  List getBillList = [];
  List getConFeeList = [];
  List getBuName = [];
  List trueTime = [];
  List loadPriceGroup = [];
  List loadCartData = [];

  String priceG;
  String priceGroup;
  String selectedValue;
  String option;

  final _modeOfPayment = TextEditingController();
  final _amountTender = TextEditingController();
  final discount = TextEditingController();

  var isLoading = true;
  var totalLoading = true;
  var _globalTime,_globalTime2;
  var timeCount;
  var tCount;
  var bill = 0.0;
  var conFee = 0.0;
  var grandTotal = 0.0;
  var minimumAmount = 0.0;
  var lt = 0;
  var items = 0;
  var stock = 0;
  var time;
  var d1;

  Future getTrueTime() async{
    var res = await db.getTrueTime();
    if (!mounted) return;
    setState(() {
      trueTime = res['user_details'];

      tCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"15:00:00")).inHours;
      print(tCount);

      if (tCount >= 0) {
        print('next day');
        d1 = DateTime.parse(trueTime[0]['next_day']);
        time = false;
      } else if (tCount < 0){
        d1 = DateTime.parse(trueTime[0]['date_today']);
        time = true;
        print('date today');
      }
      print(time);
      print(trueTime);
    });
  }

  Future getBill(priceGroup) async{
    var res = await db.getConFee();
    isLoading = false;
    if (!mounted) return;
    setState(() {
      getConFeeList = res['user_details'];
      conFee = double.parse(getConFeeList[0]['pickup_charge']);
      minimumAmount = double.parse(getConFeeList[0]['minimum_order_amount']);

    });

    var res1 = await db.getBill(priceGroup);
    if (!mounted) return;
    setState((){

      getBillList = res1['user_details'];
      bill = double.parse(getBillList[0]['d_subtotal']);
      grandTotal = bill+(conFee*lt);
      totalLoading = false;
    });
  }

  Future billNotAbove() async{
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
              height: 100,
              width: 100,
              child: SvgPicture.asset("assets/svg/groceries.svg"),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[

                Padding(
                  padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child:Center(
                    child:Text("Minimum order must exceed ₱${oCcy.format(minimumAmount)} on each store.",textAlign: TextAlign.center, maxLines: 3,style:TextStyle(fontSize: 18.0),),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[

            TextButton(
              child: Text('Close',style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future onRefresh() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String username = prefs.getString('s_customerId');
    // if(username == null){
    //   Navigator.of(context).push(_signIn());
    // }
    print('ni refresh na');
    gcLoadPriceGroup();
    getTrueTime();
    loadCart2();
  }

  Future gcLoadPriceGroup() async {
    var res = await db.gcLoadPriceGroup();
    if (!mounted) return;
    setState(() {
      loadPriceGroup = res['user_details'];
      for (int i=0;i<loadPriceGroup.length;i++) {

      }
      priceGroup = loadPriceGroup[0]['price_group'];
      getBill(priceGroup);

      isLoading = false;
    });
  }

  // Future loadCart() async {
  //   var res = await db.gcLoadCartData();
  //   if (!mounted) return;
  //   setState(() {
  //     loadCartData = res['user_details'];
  //     items = loadCartData.length;
  //
  //     isLoading = false;
  //   });
  // }

  Future loadCart2() async {
    var res = await db.gcLoadCartData2(widget.tempID);
    if (!mounted) return;
    setState(() {
      loadCartData = res['user_details'];
      items = loadCartData.length;

      isLoading = false;
    });
  }

  // Future gcGroupByBu() async{
  //   var res = await db.gcGroupByBu(widget.priceGroup);
  //   if (!mounted) return;
  //   setState((){
  //     getBuName = res['user_details'];
  //     lt=getBuName.length;
  //     for(int q=0;q<lt;q++){
  //       billPerBu.add(getBuName[q]['total']);
  //       buData.add(getBuName[q]['buId']);
  //       buNameData.add(getBuName[q]['buName']);
  //       totalData.add(getBuName[q]['total']);
  //       convenienceData.add(conFee.toString());
  //     }
  //   });
  // }

  Future gcGroupByBu2() async{
    var res = await db.gcGroupByBu2(widget.priceGroup, widget.tempID);
    if (!mounted) return;
    setState((){
      getBuName = res['user_details'];
      lt=getBuName.length;
      for(int q=0;q<lt;q++){
        billPerBu.add(getBuName[q]['total']);
        buData.add(getBuName[q]['buId']);
        buNameData.add(getBuName[q]['buName']);
        totalData.add(getBuName[q]['total']);
        convenienceData.add(conFee.toString());
      }
    });
    print(lt);
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

  updateCartIcoos(id, stk) async {
    print('na update na');
    await db.updateCartIcoos(id, stk);
  }

  modeOfPayment(_modeOfPayment){
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
                    _modeOfPayment.text = "CASH ON PICK UP";
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage("assets/mop/cod.png"),
                      ),
                      title: Text("CASH ON PICK UP"),
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
  void initState(){
    super.initState();
    onRefresh();
    gcLoadPriceGroup();
    gcGroupByBu2();
    loadCart2();
    // getConFee();
    // getTrueTime();
    // gcGroupByBu();
    // getBill();
    // gcLoadPriceGroup();
    stock = 0;

    print(widget.stores);
    print(widget.items);
    print(widget.subTotal);
    print(widget.pickingFee);
    print(widget.grandTotal);
    print(widget.priceGroup);
    print(widget.tempID);
   ;
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
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async{
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
          title: Text("Review Checkout Form (Pick-up)",style: GoogleFonts.openSans(fontSize: 16.0, fontWeight: FontWeight.bold, color:Colors.white),
          ),
        ),
        body: isLoading
          ? Center(
        child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ) : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          Expanded(
            child: Form(
              key: _key,
              child: RefreshIndicator(
                color: Colors.green,
                onRefresh: onRefresh,
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: getBuName == null ? 0 : getBuName.length,
                    itemBuilder: (BuildContext context, int index){
                      _deliveryDate.add(new TextEditingController());
                      _deliveryTime.add(new TextEditingController());
                      _specialInstruction.add(new TextEditingController());
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [


                            Container(
                              height: 40,
                              color: Colors.green[300],
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text(getBuName[index]['buName'], style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 40,
                              color: Colors.green[100],
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Product Details',
                                      style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                    Text('Total Price',
                                      style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Divider(color: Colors.black54),

                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: loadCartData == null ? 0 : loadCartData.length,
                              itemBuilder: (BuildContext context, int index0) {
                                if (loadCartData[index0]['icoos'] == '0') {
                                  option = "Cancel Item";
                                } else {
                                  option = "Cancel Order";
                                }

                                return Visibility(
                                  visible: loadCartData[index0]['buCode'] != getBuName[index]['buId'] ? false : true,
                                  child: Container(
                                    height: 120,
                                    child: Card( color: Colors.transparent,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.all(0.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    CachedNetworkImage(
                                                      imageUrl:  loadCartData[index0]['product_image'],
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
                                                      placeholder: (context, url,) => const CircularProgressIndicator(color: Colors.grey),
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
                                                      child: Text("₱ ${loadCartData[index0]['price_price'].toString()}",
                                                        style: TextStyle(fontSize: 13, color: Colors.black54),
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
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 2,
                                                              text: TextSpan(
                                                                style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                                                text: loadCartData[index0]['product_name'],
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(0, 2, 15, 0),
                                                          child: Text("₱ ${loadCartData[index0]['total_price']}",
                                                            style: TextStyle(fontSize: 13, color: Colors.black87),
                                                          ),
                                                        )
                                                      ],
                                                    ),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding: EdgeInsets.fromLTRB(5, 5, 15, 5),
                                                          child: Text('Quantity: ${loadCartData[index0]['cart_qty']}',
                                                            style: GoogleFonts.openSans(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                                                          ),
                                                        ),

                                                        Padding(
                                                            padding: EdgeInsets.only(right: 10, top: 5),
                                                            child: Container(
                                                              padding: EdgeInsets.all(0),
                                                              width: 95,
                                                              child: DropdownButtonFormField(
                                                                decoration: InputDecoration(
                                                                  isDense: true,
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5),
                                                                    borderSide: BorderSide(color: Colors.green.withOpacity(0.8), width: 1),
                                                                  ),
                                                                  contentPadding: const EdgeInsets.only(left: 5, right: 0),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(5),
                                                                  ),
                                                                ),
                                                                borderRadius: BorderRadius.circular(5),
                                                                isExpanded: false,
                                                                hint: Text('Cancel Item', style: GoogleFonts.openSans(fontSize: 12.0, color: Colors.black54),
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
                                                                        child: Text(item,
                                                                          style: GoogleFonts.openSans(fontSize: 11.0, color: Colors.black54),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                )
                                                                    .toList(),
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    selectedValue = value;
                                                                    stock = _option.indexOf(value);

                                                                    print(loadCartData[index0]['cart_id']);
                                                                    print(stock);

                                                                    updateCartIcoos(loadCartData[index0]['cart_id'], stock);
                                                                  });
                                                                },
                                                              ),
                                                            )
                                                        )
                                                      ],
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
                                    child: Text('Total Amount',
                                      style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black54),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Text('₱ ${getBuName[index]['total']}',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Divider(thickness: 2, color: Colors.grey[200]),

                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                              child: new Text("Setup Date & Time for Pick-up",
                                style: GoogleFonts.openSans(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 5, 5),
                              child: new Text("Pick-up date*",
                                style: GoogleFonts.openSans(fontSize: 13.0, color: Colors.black),
                              ),
                            ),

                            Padding(
                              padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                              child: InkWell(
                                onTap: (){

                                  _deliveryTime[index].clear();

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
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(15.0),
                                              ),
                                            ),
                                            titlePadding: const EdgeInsets.all(0),
                                            title: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.green[400],
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15), topLeft: Radius.circular(15),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(left: 15, top: 10),
                                                child: Text("Set date for this pick-up",
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

                                                        var d2 = new DateTime(d1.year, d1.month, d1.day + n);
                                                        ///for datebase
                                                        final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                                        final String formatted = formatter.format(d2);
                                                        ///for app display
                                                        final DateFormat formatter2 = DateFormat('MMMM d, y, EEEE');
                                                        final String formatted2 = formatter2.format(d2);
                                                        return InkWell(
                                                          onTap: (){

                                                            while(deliveryDateData.length > getBuName.length-1){
                                                              deliveryDateData.removeAt(index);
                                                            }
                                                            _deliveryDate[index].text = formatted2;
                                                            deliveryDateData.insert(index, _deliveryDate[index].text);

                                                            Navigator.of(context).pop();
                                                            if(index1 == 0){
                                                              setState(() {
                                                                if (time == true) {
                                                                  timeCount = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']).difference(DateTime.parse(trueTime[0]['date_today']+" "+"15:00:00")).inHours;
                                                                  timeCount = timeCount.abs();
                                                                  _globalTime = DateTime.parse(trueTime[0]['date_today']+" "+trueTime[0]['hour_today']);
                                                                  _globalTime2 = _globalTime.hour;
                                                                  if (_globalTime2 >= 15) {
                                                                    timeCount = 0;
                                                                  }
                                                                } else {
                                                                  timeCount = DateTime.parse(trueTime[0]['next_day']+" "+"07:00:00").difference(DateTime.parse(trueTime[0]['next_day']+" "+"15:00:00")).inHours;
                                                                  timeCount = timeCount.abs();
                                                                  _globalTime = DateTime.parse(trueTime[0]['next_day']+" "+"07:00:00");
                                                                  _globalTime2 = _globalTime.hour;
                                                                  if (_globalTime2 >= 15) {
                                                                    timeCount = 0;
                                                                  }
                                                                }
                                                              });
                                                            }else{
                                                              setState(() {
                                                                timeCount = 8;
                                                                _globalTime = new DateTime.now();
                                                                _globalTime2 = 07;
                                                                // _deliveryDate.clear();
                                                              });
                                                            }
                                                            print(time);
                                                            print(timeCount);
                                                            print(_globalTime2);
                                                          },
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Row (
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
                                                    backgroundColor: MaterialStateProperty.all(Colors.green[400]),
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20.0),
                                                        side: BorderSide(color: Colors.green[400]),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text('Clear',
                                                    style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    _deliveryDate[index].clear();
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
                                    controller: _deliveryDate[index],
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please select pick-up date';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.date_range,color: Colors.green[400]),
                                      contentPadding: EdgeInsets.all(0),
                                      focusedBorder:OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.green[400], width: 2.0),
                                      ),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 5, 5),
                              child: new Text("Pick-up time*",
                                style: GoogleFonts.openSans(fontSize: 13.0, color: Colors.black),
                              ),
                            ),

                            Padding(
                              padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                              child: InkWell(
                                onTap: (){

                                  getTrueTime();
                                  if(_deliveryDate[index].text.isEmpty){
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
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0),
                                                ),
                                              ),
                                              titlePadding: const EdgeInsets.all(0),
                                              title: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.green[400],
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(15), topLeft: Radius.circular(15),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 15, top: 10),
                                                  child: Text("Set time for this pick-up",
                                                    style: GoogleFonts.openSans(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              content: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),

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
                                                          final format = DateFormat.jm();
                                                          final formatt = DateFormat.Hm(); //"6:00 AM"
                                                          String from = format.format(dtFrom);
                                                          String fromm = formatt.format(dtFrom);

                                                          return InkWell(
                                                            onTap: (){
                                                              while(deliveryTimeData.length > getBuName.length-1){
                                                                deliveryTimeData.removeAt(index);
                                                              }

                                                              _deliveryTime[index].text = from;
                                                              deliveryTimeData.insert(index, _deliveryTime[index].text);

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
                                                      backgroundColor: MaterialStateProperty.all(Colors.green),
                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20.0),
                                                          side: BorderSide(color: Colors.green),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text('Clear',
                                                      style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                    onPressed: () {
                                                      _deliveryTime[index].clear();
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
                                      pageBuilder: (context, animation1, animation2) {});

                                  }
                                },
                                child: IgnorePointer(
                                  child: new TextFormField(
                                    textInputAction: TextInputAction.done,
                                    style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                    cursorColor: Colors.green,
                                    controller: _deliveryTime[index],
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please select pick-up time';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(CupertinoIcons.time, color: Colors.green[400]),
                                      contentPadding: EdgeInsets.all(0),
                                      focusedBorder:OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.green[400], width: 2.0),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
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
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.done,
                                cursorColor: Colors.green,
                                controller: _specialInstruction[index],
                                style: GoogleFonts.openSans(fontSize: 13),
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintStyle: GoogleFonts.openSans(fontSize: 13),
                                  hintText:"Special instruction",
                                  contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
                                  focusedBorder:OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
                    onTap: () async{
                      FocusScope.of(context).requestFocus(FocusNode());
                      List<String> w = [];
                      placeRemarksData.clear();

                      if (_key.currentState.validate()) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString('s_customerId');
                        if(username == null){
                          Navigator.of(context).push(_signIn()).then((val)=>{onRefresh()});
                        }else{
                          Navigator.of(context).push(_gcPickUpFinal(
                              groupValue,
                              deliveryDateData,
                              deliveryTimeData,
                              buNameData,
                              buData,
                              totalData,
                              convenienceData,
                              specialInstruction,
                              _modeOfPayment.text,
                              widget.stores,
                              widget.items,
                              widget.subTotal,
                              widget.pickingFee,
                              widget.grandTotal,
                              widget.priceGroup,
                              widget.tempID
                          )).then((val)=>{onRefresh()});
                          // Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new GcPickUpFinal(
                          //     pickUpOrDelivery  : '1',
                          //     groupValue        : groupValue,
                          //     deliveryDateData  : deliveryDateData,
                          //     deliveryTimeData  : deliveryTimeData,
                          //     buNameData        : buNameData,
                          //     buData            : buData,
                          //     totalData         : totalData,
                          //     convenienceData   : convenienceData,
                          //     placeRemarksData  : specialInstruction,
                          //     modeOfPayment     : _modeOfPayment.text,
                          //     stores            : widget.stores,
                          //     items             : widget.items,
                          //     subTotal          : widget.subTotal,
                          //     pickingFee        : widget.pickingFee,
                          //     grandTotal        : widget.grandTotal,
                          //     priceGroup        : widget.priceGroup,
                          //     tempID            : widget.tempID
                          // ))).then((val)=>{onRefresh()});
                        }
                      }


                      for (int i=0; i<getBuName.length; i++){
                        while(specialInstruction.length > getBuName.length-1){
                          specialInstruction.removeAt(i);
                        }
                        specialInstruction.insert(i, "'${_specialInstruction[i].text}'");
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
                            child: Text(
                              "NEXT",
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
      activeColor: Colors.green,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(title),
    ),
  );
}

Route _gcPickUpFinal(
  groupValue,
  deliveryDateData,
  deliveryTimeData,
  buNameData,
  buData,
  totalData,
  convenienceData,
  placeRemarksData,
  modeOfPayment,
  stores,
  items,
  subTotal,
  pickingFee,
  grandTotal,
  priceGroup,
  tempID,
){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcPickUpFinal(
      pickUpOrDelivery  : '1',
      groupValue        : groupValue,
      deliveryDateData  : deliveryDateData,
      deliveryTimeData  : deliveryTimeData,
      buNameData        : buNameData,
      buData            : buData,
      totalData         : totalData,
      convenienceData   : convenienceData,
      placeRemarksData  : placeRemarksData,
      modeOfPayment     : modeOfPayment,
      stores            : stores,
      items             : items,
      subTotal          : subTotal,
      pickingFee        : pickingFee,
      grandTotal        : grandTotal,
      priceGroup        : priceGroup,
      tempID            : tempID,
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
