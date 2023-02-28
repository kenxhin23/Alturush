import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

      firstname = pickupSummary[0]['firstname'];
      lastname = pickupSummary[0]['lastname'];
      mobileNumber = pickupSummary[0]['mobile_number'];
      if (pickupSummary[0]['house_no'] == null) {
        houseNo = "";
      } else {
        houseNo = pickupSummary[0]['house_no']+" ";
      }

      street = pickupSummary[0]['street'];
      barangay = pickupSummary[0]['barangay'];
      town = pickupSummary[0]['town'];
      zipcode = pickupSummary[0]['zipcode'];
      province = pickupSummary[0]['province'];
      submittedDate = pickupSummary[0]['submitted'];
      DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
      submitted = DateFormat().format(date);

      status = pickupSummary[0]['cancel_status'];
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
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Summary (Pick-up)', style: GoogleFonts.openSans(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ),
        body:
        isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text('TICKET NO.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(widget.ticketNo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text('ORDER SUBMITTED', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('$submitted', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text('CUSTOMER INFORMATION', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
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
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text('CUSTOMER ADDRESS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("$houseNo$street, $barangay, $town, $province $zipcode", style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text('SCHEDULE FOR PICK-UP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),),
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
                              Divider(thickness: 1, color: Colors.deepOrangeAccent,),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${loadSchedule[index]['tenant_name']}',
                                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)
                                    ),
                                  ],
                                ),
                              ),

                              Divider(thickness: 1, color: Colors.deepOrangeAccent,),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Picked-up Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                                    Row(
                                      children: [
                                        Text(pickupStart, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                                        Text(' - ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                                        Text(pickupEnd, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                                      ],
                                    ),

                                  ],
                                ),
                              ),

                              Divider(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('Picked-up Schedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(pickupSched, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                                  )
                                ],
                              ),

                              SizedBox(height: 2),

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Divider(thickness: 1, color: Colors.black54),

                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('ORDER SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                    ),
                  ),

                  Divider(thickness: 1, color: Colors.deepOrangeAccent,),

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

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Text('${loadSchedule[index]['tenant_name']}',
                                      style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)
                                  ),

                                  Text('₱ ${oCcy.format(price)}',
                                      style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)
                                  ),
                                ],
                              ),
                            ),

                            Divider(thickness: 1, color: Colors.deepOrangeAccent),

                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Row(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('TOTAL AMOUNT', style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("$discounted", style: TextStyle(fontSize: 13, color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('₱ ${oCcy.format(grandTotal).toString()}', style: TextStyle(fontSize: 13, color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),

                  Divider(color: Colors.black54),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('AMOUNT TENDER', style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.normal)),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('₱ ${oCcy.format(amountTender).toString()}', style: TextStyle(fontSize: 13, color: Colors.deepOrangeAccent)),
                      ),
                    ],
                  ),

                  Divider(color: Colors.black54),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('CHANGE', style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.normal)),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('₱ ${oCcy.format(change).toString()}', style: TextStyle(fontSize: 13, color: Colors.deepOrangeAccent)),
                      ),
                    ],
                  ),

                  Divider(color: Colors.black54),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('PAYMENT METHOD', style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.normal)),
                          ),
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('CASH', style: TextStyle(fontSize: 13, color: Colors.deepOrangeAccent, fontWeight: FontWeight.normal)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          )
        ],
      )
    );
  }
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
