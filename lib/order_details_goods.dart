import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:intl/intl.dart';
import 'load_bu.dart';
import 'live_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';

class ToDeliverGood extends StatefulWidget {
  final ticketNo;
  final customerId;
  ToDeliverGood({Key key, @required this.ticketNo,this.customerId}) : super(key: key);//
  @override
  _ToDeliver createState() => _ToDeliver();
}

class _ToDeliver extends State<ToDeliverGood> {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  List loadTotal,lGetAmountPerTenant;
  var isLoading = false;
  List loadItems;

  void displayBottomSheet(BuildContext context) async{
    var res = await db.lookItemsSegregate(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      lGetAmountPerTenant = res['user_details'];
    });
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
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                SizedBox(height:10.0),
                Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 0.0, 20.0, 0.0),
                  child:Text("Your stores",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                ),
                Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: lGetAmountPerTenant == null ? 0 : lGetAmountPerTenant.length,
                    itemBuilder: (BuildContext context, int index) {
                      var f = index;
                      f++;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 5.0),
                        child:Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$f. ${lGetAmountPerTenant[index]['bu_name']} ${lGetAmountPerTenant[index]['tenant_name']} ',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                              Text('₱${oCcy.format(int.parse(lGetAmountPerTenant[index]['sumpertenats'].toString()))}',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            ],
                          ),
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

  Future cancelOrder(tomsId) async{
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal:0.0, vertical: 20.0),
          title:Row(
            children: <Widget>[
              Text('Hello',style:TextStyle(fontSize: 18.0),),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child:Center(child:Text("Do you want to cancel this item?")),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close',style: TextStyle(
                color: Colors.green,
              ),),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Proceed',style: TextStyle(
                color: Colors.green,
              ),),
              onPressed: () async{
                cancelOrderSingle(tomsId);
                Navigator.of(context).pop();
                cancelSuccess();
              },
            ),
          ],
        );
      },
    );
  }
  var delCharge;
  var grandTotal;
  Future getTotal() async{
    var res = await db.getTotal(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      loadTotal = res['user_details'];
      if(loadTotal[0]['charge'] == null && loadTotal[0]['grand_total'] ){
        delCharge = 0;
        grandTotal = 0;
        print("opps");
      }else{
        delCharge = loadTotal[0]['charge'];
        grandTotal = loadTotal[0]['grand_total'];
        print("naa");
      }
    });
  }

  Future cancelOrderSingle(tomsId) async{
    // await db.cancelOrderSingleGood(tomsId);
    lookItemsGood();
  }
  cancelSuccess(){
    Fluttertoast.showToast(
        msg: "Your order successfully cancelled",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  Future lookItemsGood() async{
    //var res = await db.lookItems(widget.ticketNo);
    var res = await db.lookItemsGood(widget.ticketNo);
    if (!mounted) return;
    setState(() {
      isLoading = false;
      loadItems = res['user_details'];
//      tPrice = loadItems[0]['d_tot_price'];
//      deliveryCharge = loadItems[0]['d_delivery_charge'];
//      granTotal = double.parse(deliveryCharge)+tPrice;
//      tPrice = int.parse(loadItems[1]['d_tot_price']).toString();
//      deliveryCharge =  int.parse(loadItems[0]['d_delivery_charge']).toString();
//      print(int.parse(loadItems[1]['d_tot_price']).toString());
    });
  }

  var checkIfExists;
  Future checkIfOnGoing() async{
    var res = await db.checkIfOnGoing(widget.ticketNo);
    if(res == 'true'){
      checkIfExists = res;
    }if(res == 'false'){
      checkIfExists = res;
    }

  }

  @override
  void initState() {
    super.initState();
    // lookItemsGood();
    // getTotal();
    checkIfOnGoing();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
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
          title: Text(widget.ticketNo,style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                color: Colors.deepOrangeAccent,
                onRefresh: lookItemsGood,
                child: Scrollbar(
                  child: ListView.builder(
                      itemCount:loadItems == null ? 0 : loadItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {

                          },
                          child: Container(
                            height: 130.0,
                            width: 30.0,
                            child: Card(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                                        child: Container(
                                            width: 80.0,
                                            height: 100.0,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                image: new NetworkImage(loadItems[index]['prod_image']),
                                                fit: BoxFit.scaleDown,
                                              ),
                                            )),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child:Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                                                child:Text(loadItems[index]['prod_name'],textAlign: TextAlign.justify, maxLines: 2, overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.openSans(
                                                      fontStyle:
                                                      FontStyle.normal,
                                                      fontSize: 15.0),
                                                ),
                                              ),
                                              // Padding(
                                              //   padding: EdgeInsets.fromLTRB(15, 0, 5, 5),
                                              //   child: new Text('From: ${loadItems[index]['bu_name']}', overflow: TextOverflow.clip,
                                              //     style: GoogleFonts.openSans(
                                              //         fontStyle:
                                              //         FontStyle.normal,
                                              //         fontSize: 15.0),
                                              //   ),
                                              // ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                    child: new Text(
                                                      "Price: ₱ ${oCcy.format(double.parse(loadItems[index]['total_price']))} ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 15.0,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                                                    child: new Text('Quantity: ${loadItems[index]['d_qty']}',
                                                      style: TextStyle(
                                                        //                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15.0,
                                                        //                                                        color: Colors.deepOrange,
                                                      ),
                                                    ),
                                                  ),
                                                  loadItems[index]['canceled_status'] == '1'?
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                                                    child: OutlinedButton(
                                                      style: TextButton.styleFrom(
                                                        primary: Colors.black, // foreground
                                                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                      ),
                                                      onPressed: null,
                                                      child: Text("Cancelled"),
                                                    ),
                                                  ):
                                                  loadItems[index]['ifexists'] == 'true'?
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                    child: OutlinedButton(
                                                      style: TextButton.styleFrom(
                                                        primary: Colors.black, // foreground
                                                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                      ),
                                                      onPressed: null,
                                                      child: Text("Rider is tagged"),
                                                    ),
                                                  ):Padding(
                                                    padding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                                                    child: OutlinedButton(
                                                      style: TextButton.styleFrom(
                                                        primary: Colors.black, // foreground
                                                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                      ),
                                                      onPressed: (){
                                                        // cancelOrder(loadItems[index]['gc_final_id']);
                                                      },
                                                      child:Text("Cancel this item"),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              elevation: 0,
                              margin: EdgeInsets.all(3),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
            //   child: Row(
            //     children: <Widget>[
            //       Container(
            //         width: MediaQuery.of(context).size.width / 5.5,
            //         child: SleekButton(
            //           onTap: () async{
            //             SharedPreferences prefs = await SharedPreferences.getInstance();
            //             String status = prefs.getString('s_status');
            //             status != null
            //                 ?  displayBottomSheet(context)
            //                 : Navigator.of(context).push(_signIn());
            //           },
            //           style: SleekButtonStyle.flat(
            //             color: Colors.deepOrange,
            //             inverted: false,
            //             rounded: true,
            //             size: SleekButtonSize.big,
            //             context: context,
            //           ),
            //           child: Center(
            //             child: Icon(
            //               Icons.remove_red_eye,
            //               size: 17.0,
            //             ),
            //           ),
            //         ),
            //       ),
            //       SizedBox(
            //         width: 2.0,
            //       ),
            //       Flexible(
            //         child: SleekButton(
            //           onTap: () async {
            //
            //           },
            //           style: SleekButtonStyle.flat(
            //             color: Colors.deepOrange,
            //             inverted: true,
            //             rounded: true,
            //             size: SleekButtonSize.big,
            //             context: context,
            //           ),
            //           child: Center(
            //             // ₱${oCcy.format(int.parse(lGetAmountPerTenant[index]['sumpertenats'].toString()))}
            //             child: Text("Total ₱ ${oCcy.format(int.parse(grandTotal.toString()))}", style:TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 18.0),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Center(
              child:Column(
                children: [

                ],
              ),
            ),

            SizedBox(
              height: 10.0,
            ),
          ],
        ),
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