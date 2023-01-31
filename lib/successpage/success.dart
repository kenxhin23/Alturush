import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:arush/create_account_signin.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Success extends StatefulWidget {
  @override
  _Success createState() => _Success();
}

class _Success extends State<Success> {
  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(
      //   brightness: Brightness.light,
      //   // backgroundColor: Colors.light,
      //   elevation: 0.1,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.black,size: 23,),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   title: Text("Back",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child:Scrollbar(
              child: ListView(
                children: [
                  Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     SizedBox(
                       height: screenHeight/5,
                     ),
                     Container(
                       height: 150,
                       width: 500,
                       child: SvgPicture.asset("assets/svg/confetti.svg"),
                     ),
                     SizedBox(
                       height: screenHeight/15,
                     ),
                     Center(
                       child: Text("Hi, there.",style: GoogleFonts.openSans(color:Colors.black54,fontSize: 25.0,),),
                     ),
                     Padding(
                       padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                       child: Text("Thanks for checking out Alturush Delivery we hope our products can make your day a little more enjoyable.",textAlign: TextAlign.justify,style: GoogleFonts.openSans(color:Colors.black54,fontSize: 18.0,),),
                     ),
                     Padding(
                       padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                       child: Text("Try to login to verify your account",textAlign: TextAlign.justify,style: GoogleFonts.openSans(color:Colors.black54,fontSize: 18.0,),),
                     ),
                   ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
              child: SleekButton(
                onTap: () {
                  // Navigator.of(context).push(loginPage());
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
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
                    "Log in now",
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontStyle: FontStyle.normal,fontSize: 14.0),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}


Route loginPage() {
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

