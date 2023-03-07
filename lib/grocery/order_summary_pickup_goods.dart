

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../create_account_signin.dart';
import '../db_helper.dart';

class OrderSummaryPickupGoods extends StatefulWidget {
  final ticket;
  final ticketId;

  const OrderSummaryPickupGoods({Key key, this.ticket, this.ticketId}) : super(key: key);
  @override
  _OrderSummaryPickupGoodsState createState() => _OrderSummaryPickupGoodsState();
}

class _OrderSummaryPickupGoodsState extends State<OrderSummaryPickupGoods> {

  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  var isLoading = true;

  List pickupSummary;
  List loadSchedule;
  List loadTotal;
  List loadPickupTIme;

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

  double grandTotal = 0.00;
  double total = 0.00;
  double pickingFee = 0.00;
  double subTotal = 0.00;
  double amountTender = 0.00;
  double change = 0.00;
  double discount;

  Future onRefresh() async {
    getPickupSummary();
    getPickupSchedule();
    getTotal();
    getPickupTime();
  }

  Future getPickupTime() async {
    var res = await db.getPickupTime();
    if (!mounted) return;
    setState(() {
      loadPickupTIme = res['user_details'];
      print(res);

      pickupTimeStart = loadPickupTIme[0]['time_start'];
      DateTime start = DateFormat("hh:mm").parse(pickupTimeStart);
      pickupStart = DateFormat().add_jm().format(start);

      pickupTimeEnd = loadPickupTIme[0]['time_end'];
      DateTime end = DateFormat("hh:mm").parse(pickupTimeEnd);
      pickupEnd = DateFormat().add_jm().format(end);
      print(pickupStart);
      print(pickupEnd);
    });
  }

  Future getPickupSummary() async {
    var res = await db.getPickupSummaryGoods(widget.ticketId);
    if (!mounted) return;
    setState(() {
      pickupSummary = res['user_details'];

      firstname = pickupSummary[0]['firstname'];
      lastname = pickupSummary[0]['lastname'];
      mobileNumber = pickupSummary[0]['mobile_number'];
      if (pickupSummary[0]['house_no'] == null) {
        houseNo = "";
      } else {
        houseNo = "${pickupSummary[0]['house_no']} ";
      }

      street = pickupSummary[0]['street'];
      barangay = pickupSummary[0]['barangay'];
      town = pickupSummary[0]['town'];
      zipcode = pickupSummary[0]['zipcode'];
      province = pickupSummary[0]['province'];
      submittedDate = pickupSummary[0]['submitted'];
      DateTime date = DateFormat('yyyy-MM-dd hh:mm:ss').parse(submittedDate);
      submitted = DateFormat().format(date);

      status = pickupSummary[0]['cancelled_status'];
      print(pickupSummary);
      isLoading = false;
    });
  }

  Future getPickupSchedule() async{
    var res = await db.getPickupScheduleGoods(widget.ticketId);
    if (!mounted) return;
    setState(() {
      loadSchedule = res['user_details'];
      print(loadSchedule);
      isLoading = false;
    });
  }

  Future getTotal() async {
    var res = await db.getTotalGoods(widget.ticketId);
    if (!mounted) return;
    setState(() {
      loadTotal = res['user_details'];
      subTotal = oCcy.parse(loadTotal[0]['sub_total']);
      pickingFee = oCcy.parse(loadTotal[0]['picking_charge']);
      grandTotal = subTotal + pickingFee;
      amountTender = oCcy.parse(loadTotal[0]['amount_tender']);
      change = oCcy.parse(loadTotal[0]['change']);
      print(loadTotal);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    onRefresh();
    // getPickupSummary();
    // getPickupSchedule();
    // getTotal();
    print(widget.ticket);
    print(widget.ticketId);

  }

  @override
  void dispose() {
    super.dispose();
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
        title: Text('Summary (Pickup)', style: GoogleFonts.openSans(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.0),
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
            child: RefreshIndicator(
              color: Colors.green,
              onRefresh: onRefresh,
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
                      child: Text(widget.ticket, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
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
                        //
                        // pickupTimeStart = loadSchedule[index]['time_start'];
                        // DateTime start = DateFormat("hh:mm").parse(pickupTimeStart);
                        // pickupStart = DateFormat().add_jm().format(start);
                        // // print(pickupStart);
                        //
                        // pickupTimeEnd = loadSchedule[index]['time_end'];
                        // DateTime end = DateFormat("hh:mm").parse(pickupTimeEnd);
                        // pickupEnd = DateFormat().add_jm().format(end);
                        // print(pickupEnd);

                        pickupSchedDate = loadSchedule[index]['time_pickup'];
                        DateTime pickup = DateFormat("yyyy-MM-dd H:mm").parse(pickupSchedDate);
                        pickupSched = DateFormat().add_yMMMMd().add_jm().format(pickup);
                        // print(pickupSched);

                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(thickness: 1, color: Colors.green,),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${loadSchedule[index]['bu_name']}',
                                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.green)
                                    ),
                                  ],
                                ),
                              ),

                              Divider(thickness: 1, color: Colors.green,),

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
                          child: Text("Ticket No. ${widget.ticket} has been cancelled.",style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: status == '0',
                    child: Column(
                      children: <Widget>[
                        Divider(thickness: 1, color: Colors.black54),

                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('ORDER SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                          ),
                        ),

                        Divider(thickness: 1, color: Colors.green),

                        SizedBox(height: 5),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('SUBTOTAL', style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.normal)),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('₱ ${oCcy.format(subTotal)}', style: TextStyle(fontSize: 13, color: Colors.green)),
                            )
                          ],
                        ),

                        Divider(color: Colors.black54),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text("PICKING FEE", style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.normal)),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('₱ ${oCcy.format(pickingFee)}', style: TextStyle(fontSize: 13, color: Colors.green)),
                            )
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
                                  child: Text('TOTAL AMOUNT', style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)),
                                ),

                                // Padding(
                                //   padding: EdgeInsets.only(left: 5),
                                //   child: Text("discounted", style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                                // ),
                              ],
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('₱ ${oCcy.format(grandTotal)}', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
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
                              child: Text('₱ ${oCcy.format(amountTender)}', style: TextStyle(fontSize: 13, color: Colors.green)),
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
                              child: Text('₱ ${oCcy.format(change)}', style: TextStyle(fontSize: 13, color: Colors.green)),
                            ),
                          ],
                        ),
                        // Divider(color: Colors.black54),
                        //
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Row(
                        //       children: [
                        //         Padding(
                        //           padding: EdgeInsets.only(left: 10),
                        //           child: Text('PAYMENT METHOD', style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.normal)),
                        //         ),
                        //       ],
                        //     ),
                        //
                        //     Padding(
                        //       padding: EdgeInsets.symmetric(horizontal: 10),
                        //       child: Text('CASH', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.normal)),
                        //     ),
                        //   ],
                        // ),
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
