

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../create_account_signin.dart';


class OrderTimeFrameDeliveryGoods extends StatefulWidget {
  final ticket;
  final ticketId;
  final mop;
  final acroname;
  final bunit_name;
  final bu_id;

  const OrderTimeFrameDeliveryGoods({Key key, this.ticket, this.ticketId, this.mop, this.acroname, this.bunit_name, this.bu_id}) : super(key: key);
  @override
  _OrderTimeFrameDeliveryGoodsState createState() => _OrderTimeFrameDeliveryGoodsState();
}

class _OrderTimeFrameDeliveryGoodsState extends State<OrderTimeFrameDeliveryGoods> {


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
    print(widget.mop);
    print(widget.acroname);
    print(widget.bunit_name);
    print(widget.bu_id);

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
        title: Text('Order Time Frame (Delivery)', style: GoogleFonts.openSans(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16.0),
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