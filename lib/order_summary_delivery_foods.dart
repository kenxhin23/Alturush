import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_account_signin.dart';
import 'db_helper.dart';

class OrderSummaryDeliveryFoods extends StatefulWidget {
  final ticketNo;
  final ticketId;

  const OrderSummaryDeliveryFoods({Key key, this.ticketNo, this.ticketId}) : super(key: key);
  @override
  _OrderSummaryDeliveryFoodsState createState() => _OrderSummaryDeliveryFoodsState();
}

class _OrderSummaryDeliveryFoodsState extends State<OrderSummaryDeliveryFoods> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");

  List orderSummary;
  List loadTotal;
  List loadDiscount;
  List loadSchedule;
  List loadTotalAmount;
  List loadVehicle;

  final _deliveryDate = TextEditingController();
  final _deliveryTime = TextEditingController();

  double grandTotal = 0.00;
  double total = 0.00;
  double deliveryFee = 0.00;
  double subTotal = 0.00;
  double amountTender = 0.00;
  double change = 0.00;
  double discount;

  var index = 0;
  var isLoading = true;



  String submitted, submittedDate;
  String pickupD, pickupT , pickupDate;
  String firstname;
  String lastname;
  String mobileNumber;
  String houseNo;
  String street;
  String barangay;
  String town;
  String zipcode;
  String province;
  String landmark;
  String discounted;
  String status;
  String paymentMethod;


  Future onRefresh() async {
    getDiscount();
    // getTotal();
    getOrderSummary();
    getPickupSchedule();
    getVehicleType();
    getTotalAmount();
  }
  Future getOrderSummary() async {
    var res = await db.getOrderSummary(widget.ticketId);
    if (!mounted) return;
    setState(() {
      orderSummary = res['user_details'];
      firstname = orderSummary[0]['firstname'];
      lastname = orderSummary[0]['lastname'];
      mobileNumber = orderSummary[0]['mobile_number'];
      if (orderSummary[0]['house_no'] == "" || orderSummary[0]['house_no'] == null) {
        houseNo = "";
      } else {
        houseNo = orderSummary[0]['house_no']+" ";
      }
      street = orderSummary[0]['street'];
      barangay = orderSummary[0]['barangay'];
      town = orderSummary[0]['town'];
      zipcode = orderSummary[0]['zipcode'];
      province = orderSummary[0]['province'];
      landmark = orderSummary[0]['landmark'];

      submittedDate = orderSummary[0]['submitted'];
      DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
      submitted = DateFormat().add_yMMMMd().add_jm().format(date);

      pickupDate = orderSummary[0]['pickup_at'];
      DateTime date2 = DateFormat('yyyy-MM-dd hh:mm:ss').parse(pickupDate);
      pickupD = DateFormat().add_yMMMMd().add_EEEE().format(date2);
      pickupT = DateFormat().add_jm().format(date2);

      _deliveryDate.text = pickupD;
      _deliveryTime.text = pickupT;

      status = orderSummary[0]['cancel_status'];
      print(orderSummary[0]['cancel_status']);
      isLoading = false;
    });
  }

  Future getDiscount() async{
    var res = await db.getDiscount(widget.ticketId);
    if (!mounted) return;
    setState(() {
      getTotal();
      loadDiscount = res['user_details'];

      if (loadDiscount[index]['total_discount'] != null) {
        discount = double.parse(loadDiscount[0]['total_discount']);
        discounted ="(Discounted)";
      } else if (discounted == null) {
        discount = 0.00;
        discounted ="";
      }

      print(discounted);
      isLoading = false;
    });
  }

  Future getTotal() async{
    var res = await db.getTotal(widget.ticketId);
    if (!mounted) return;
    setState(() {

      loadTotal = res['user_details'];
      total = double.parse(loadTotal[0]['total_price']);
      subTotal = double.parse(loadTotal[0]['sub_total']);
      amountTender = double.parse(loadTotal[0]['amount_tender']);
      deliveryFee = double.parse(loadTotal[0]['delivery_charge']);
      paymentMethod = loadTotal[0]['payment_method'];

      if ( subTotal == 0) {
        deliveryFee = 0.00;
        amountTender = 0.00;
      } else {
        grandTotal = total - discount;
        change = amountTender - grandTotal;
      }

      print(paymentMethod);
      isLoading = false;
    });

  }

  Future getPickupSchedule() async{
    var res = await db.getPickupScheduleFoods(widget.ticketId);
    if (!mounted) return;
    setState(() {
      loadSchedule = res['user_details'];
      isLoading = false;
      print(loadSchedule);
    });
  }

  Future getTotalAmount() async {
    var res = await db.getTotalAmount(widget.ticketId);
    if (!mounted) return;
    setState(() {
      loadTotalAmount = res['user_details'];
      isLoading = false;
    });

  }

  Future getVehicleType() async {
    var res = await db.getVehicleType(widget.ticketId);
    if (!mounted) return;
    setState(() {
      loadVehicle = res['user_details'];

      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    print(widget.ticketId);
    onRefresh();
    getDiscount();
    // getTotal();
    getOrderSummary();
    getPickupSchedule();
    getVehicleType();
    getTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrangeAccent, // Status bar
          statusBarIconBrightness: Brightness.light ,  // Only honored in Android M and above
        ),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0.1,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.white,size: 20,
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
        title: Text('Summary (Delivery)', style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ),
      body: isLoading ?

      Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ) :

        Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          Expanded(
            child: RefreshIndicator(
              color: Colors.deepOrangeAccent,
              onRefresh: onRefresh,
              child: Scrollbar(
                  child: ListView(
                    children: [

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text('TICKET NO.',
                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(widget.ticketNo,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text('ORDER SUBMITTED',
                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("$submitted",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text('CUSTOMER INFORMATION',
                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("$firstname $lastname",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("$mobileNumber",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text('DELIVERY ADDRESS',
                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("$houseNo$street, $barangay, $town, $province $zipcode",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text('NEAREST LAND MARK',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("$landmark",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text('SCHEDULE FOR DELIVERY',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Date*",
                              style: GoogleFonts.openSans(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            SizedBox(width: 220, height: 35,
                              child: TextFormField(
                                enabled: false,
                                textInputAction: TextInputAction.done,
                                style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                cursorColor: Colors.deepOrange,
                                controller: _deliveryDate,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.date_range,color: Colors.deepOrangeAccent),
                                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                  focusedBorder:OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Time*", style: GoogleFonts.openSans(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            SizedBox(width: 220,height: 35,
                              child: TextFormField(
                                enabled: false,
                                textInputAction: TextInputAction.done,
                                style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                cursorColor: Colors.deepOrange,
                                controller: _deliveryTime,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.timer_outlined,color: Colors.deepOrangeAccent,),
                                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                  focusedBorder:OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Visibility(
                    visible: status == '1',
                    child: Column(
                      children: <Widget>[
                        OutlinedButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                          ),
                          child: Text("Ticket No. ${widget.ticketNo} has been cancelled.",style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: status == '0',
                    child: Column(
                      children: [

                        Container(
                          height: 40,
                          color: Colors.grey[200],
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('ORDER SUMMARY',
                                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
                              ),
                            ),
                          ),
                        ),

                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: loadSchedule == null? 0: loadSchedule.length,
                          itemBuilder: (BuildContext context, int index) {
                            double price;

                            price = double.parse(loadSchedule[index]['price']);
                            // if (loadSchedule[index]['cancel_status'] == '1') {
                            //   price = 0.00;
                            // } else {
                            //   price = double.parse(loadSchedule[index]['price']);
                            // }
                            // price = double.parse(loadSchedule[index]['price']);

                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Container(
                                    height: 30,
                                    color: Colors.deepOrange[300],
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [

                                        Text('${loadSchedule[index]['tenant_name']}',
                                            style: GoogleFonts.openSans(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.white)
                                        ),

                                        Text('₱ ${oCcy.format(price)}',
                                            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.white)
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(
                          height: 5,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('SUBTOTAL',
                                style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('₱ ${oCcy.format(subTotal)}',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text("RIDER'S FEE",
                                style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('₱ ${oCcy.format(deliveryFee)}',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            )
                          ],
                        ),

                        Container(
                          height: 30,
                          color: Colors.grey[200],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Row(
                                children: [

                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Text('TOTAL AMOUNT',
                                      style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                    child: Text("$discounted",
                                      style: TextStyle(fontSize: 13, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Text('₱ ${oCcy.format(grandTotal)}',
                                  style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('AMOUNT TENDER',
                                style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('₱ ${oCcy.format(amountTender)}',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('CHANGE',
                                style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('₱ ${oCcy.format(change)}',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [

                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Text('PAYMENT METHOD',
                                    style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('$paymentMethod',
                                style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 5,
                        ),

                        Container(
                          height: 40,
                          color: Colors.grey[200],
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('SUGGESTED VEHICLE FOR DELIVERY',
                                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 5,
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                SizedBox(
                                  width: 25,
                                  child: Text('No.',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                  ),
                                ),

                                VerticalDivider(color: Colors.black54),

                                SizedBox(
                                  width: 100,
                                  child: Text('Vehicle Type',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                  ),
                                ),

                                VerticalDivider(color: Colors.black54),

                                SizedBox(
                                  width: 75,
                                  child: Text("Delivery Fee",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Divider(color: Colors.black54),

                        Visibility(
                          visible: subTotal != 0 ? true : false,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: loadVehicle == null ? 0 : loadVehicle.length,
                              itemBuilder: (BuildContext context, int index) {
                                var n = index;
                                n++;

                                return Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [

                                              SizedBox(width: 25,
                                                  child: Text('$n', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black))
                                              ),

                                              VerticalDivider(color: Colors.black54),

                                              SizedBox(width: 100,
                                                  child: Text('${loadVehicle[index]['vehicle_type']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black))
                                              ),

                                              VerticalDivider(color: Colors.black54),

                                              SizedBox(width: 75,
                                                  child: Text("${loadVehicle[index]['riders_fee']}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black))
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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