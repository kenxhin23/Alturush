import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppQrCode extends StatefulWidget {
  @override
  _AppQrCode createState() => _AppQrCode();
}

class _AppQrCode extends State<AppQrCode> {



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0),),
      ),
      body: Center(
        child: Image.asset(
          'assets/png/sample_alturush_qrcode.png',
          fit: BoxFit.contain,
          height: 500,
        ),
      ),
    );
  }

}