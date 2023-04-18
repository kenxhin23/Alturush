import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_account_signin.dart';
import 'db_helper.dart';

class OrderSummaryPickupFoods extends StatefulWidget {
  final ticketNo;
  final ticketId;
  const OrderSummaryPickupFoods({Key key, this.ticketNo, this.ticketId}) : super(key: key);
  @override
  _OrderSummaryPickupFoodsState createState() => _OrderSummaryPickupFoodsState();
}

class _OrderSummaryPickupFoodsState extends State<OrderSummaryPickupFoods> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final _deliveryDate = TextEditingController();
  final _deliveryTime = TextEditingController();


  double grandTotal = 0.00;
  double subTotal = 0.00;
  double total = 0.00;
  double amountTender = 0.00;
  double change = 0.00;
  double discount;

  var isLoading = true;
  var index = 0;


  List pickupSummary;
  List loadTotal;
  List loadDiscount;
  List loadSchedule;

  String submitted, submittedDate;
  String firstname;
  String lastname;
  String mobileNumber;
  String houseNo;
  String street;
  String barangay;
  String town;
  String province;
  String zipcode;
  String pickupStart, pickupTimeStart;
  String pickupEnd, pickupTimeEnd;
  String pickupSched, pickupSchedDate;
  String discounted;
  String status;
  String cancelStatus;



  Future onRefresh() async {
    getPickupSummary();
    // getTotal();
    getDiscount();
    getPickupSchedule();
  }

  Future getPickupSummary() async {
    var res = await db.getPickupSummaryFoods(widget.ticketId);
    if (!mounted) return;
    setState(() {
      pickupSummary = res['user_details'];

      firstname     = pickupSummary[0]['firstname'];
      lastname      = pickupSummary[0]['lastname'];
      mobileNumber  = pickupSummary[0]['mobile_number'];
      if (pickupSummary[0]['house_no'] == null) {
        houseNo     = "";
      } else {
        houseNo     = "${pickupSummary[0]['house_no']} ";
      }

      street        = pickupSummary[0]['street'];
      barangay      = pickupSummary[0]['barangay'];
      town          = pickupSummary[0]['town'];
      zipcode       = pickupSummary[0]['zipcode'];
      province      = pickupSummary[0]['province'];
      submittedDate = pickupSummary[0]['submitted'];
      DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
      submitted     = DateFormat().format(date);
      status        = pickupSummary[0]['cancel_status'];

      print('status sa cancel');
      print(status);
      isLoading = false;
    });
  }

  Future getDiscount() async{
    var res = await db.getDiscount(widget.ticketId);
    if (!mounted) return;
    setState(() {
      getTotal();
      loadDiscount = res['user_details'];

      if (loadDiscount[index]['total_discount'] != null){
        discount = double.parse(loadDiscount[0]['total_discount']);
        discounted ="(Discounted)";
      } else {
        discount = 0.00;
        discounted ="";
      }

      print(loadDiscount);
      isLoading = false;
    });
  }

  Future getTotal() async{
    var res = await db.getTotal2(widget.ticketId);
    if (!mounted) return;
    setState(() {
      // grandTotal = 0.0;
      loadTotal = res['user_details'];
      total = double.parse(loadTotal[index]['total_price']);
      subTotal = double.parse(loadTotal[index]['sub_total']);
      amountTender = double.parse(loadTotal[index]['amount_tender']);
      change = double.parse(loadTotal[index]['change']);
      grandTotal = total - discount;
      if (total == 0) {
        amountTender = 0.00;
        change = 0.00;
      } else {
        change = amountTender - grandTotal;
      }

      // print(loadTotal);
      isLoading = false;
    });
  }

  Future getPickupSchedule() async{
    var res = await db.getPickupScheduleFoods(widget.ticketId);
    if (!mounted) return;
    setState(() {
      loadSchedule = res['user_details'];
      // print(loadSchedule);
      isLoading = false;
    });
  }

  @override
  void initState(){
    super.initState();
    onRefresh();
    getPickupSummary();
    // getTotal();
    getDiscount();
    getPickupSchedule();

    DateTime now = DateTime.now();
    String formattedTime = DateFormat().add_jms().format(now);
    // print(now);
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
        title: Text('Summary (Pick-up)',
          style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ),
        body:
        isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              color: Colors.deepOrangeAccent,
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: false,
                  children: [

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text('TICKET NO.',
                        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(widget.ticketNo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text('ORDER SUBMITTED',
                        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('$submitted', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text('CUSTOMER INFORMATION',
                        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("$firstname $lastname", style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
                    ),

                    SizedBox(height: 5),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("$mobileNumber", style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text('CUSTOMER ADDRESS',
                        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("$houseNo$street, $barangay, $town, $province $zipcode", style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text('SCHEDULE FOR PICK-UP',
                        style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: loadSchedule == null ? 0 : loadSchedule.length,
                      itemBuilder: (BuildContext context, int index) {

                        pickupTimeStart = loadSchedule[index]['time_start'];
                        DateTime start = DateFormat("hh:mm").parse(pickupTimeStart);
                        pickupStart = DateFormat().add_jm().format(start);
                        // print(pickupStart);

                        pickupTimeEnd = loadSchedule[index]['time_end'];
                        DateTime end = DateFormat("hh:mm").parse(pickupTimeEnd);
                        pickupEnd = DateFormat().add_jm().format(end);
                        // print(pickupEnd);

                        pickupSchedDate = loadSchedule[index]['time_pickup'];
                        DateTime pickup = DateFormat("yyyy-MM-dd H:mm").parse(pickupSchedDate);
                        pickupSched = DateFormat().add_yMMMMd().add_jm().format(pickup);
                        // print(pickupSched);

                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                height: 30,
                                color: Colors.deepOrange[300],
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${loadSchedule[index]['tenant_name']}',
                                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white)
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
                                    Text('Picked-up Time',
                                      style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                    Row(
                                      children: [
                                        Text(pickupStart,
                                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                        ),
                                        Text(' - ',
                                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                        ),
                                        Text(pickupEnd,
                                          style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('Picked-up Schedule',
                                      style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(pickupSched,
                                      style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: 2,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          itemCount: loadSchedule == null ? 0 : loadSchedule.length,
                          itemBuilder: (BuildContext context, int index) {
                            double price;
                            price = double.parse(loadSchedule[index]['price']);
                            // if (loadSchedule[index]['cancel_status'] == '1') {
                            //   price = 0.00;
                            // } else {
                            //   price = double.parse(loadSchedule[index]['price']);
                            // }
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
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text("$discounted", style: TextStyle(fontSize: 13, color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('₱ ${oCcy.format(grandTotal).toString()}',
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
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('₱ ${oCcy.format(amountTender).toString()}',
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
                              child: Text('₱ ${oCcy.format(change).toString()}',
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
                                    style: GoogleFonts.openSans(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('CASH',
                                style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
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
