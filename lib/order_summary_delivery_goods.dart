

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_account_signin.dart';

class OrderSummaryDeliveryGoods extends StatefulWidget {

  final ticket;
  final ticketId;

  const OrderSummaryDeliveryGoods({Key key, this.ticket, this.ticketId}) : super(key: key);
  @override
  _OrderSummaryDeliveryGoodsState createState() => _OrderSummaryDeliveryGoodsState();
}

class _OrderSummaryDeliveryGoodsState extends State<OrderSummaryDeliveryGoods> {


  Future onRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }

  }

  @override
  void initState() {
    super.initState();
    onRefresh();
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
        title: Text('Summary (Delivery)', style: GoogleFonts.openSans(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.0),
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
