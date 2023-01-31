import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_button/sleek_button.dart';
import '../db_helper.dart';
import 'package:arush/create_account_signin.dart';

class EnterNewPassword extends StatefulWidget {
  final realMobileNumber;
  final login;
  EnterNewPassword({Key key, @required this.login, this.realMobileNumber}) : super(key: key);
  @override
  _EnterNewPassword createState() => _EnterNewPassword();
}

class _EnterNewPassword extends State<EnterNewPassword> {
  final db = RapidA();

  final newPassWord = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  var t;
  String warning;
  String alert;
  bool checkPassword = false;
  bool _isHidden = true;
  var passwordError = "";

  ///save new password
  Future changePassword() async{
    await db.changePassword(newPassWord.text,widget.realMobileNumber);

    alertDialog();
  }

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  ///alert dialog for multiple use
  alertDialog() {
    return
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Your password has been changed successfully",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      confirmBtnText: 'Okay',
      onConfirmBtnTap: () async {
        if(t == true){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }if(t == 'false'){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
    );
  }

  void _togglePassword(){
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  void initState(){
    t=widget.login;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Reset password",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0),), systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      ///display main page or body of the app
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Expanded(
            child:Scrollbar(
              child: Form(
                key: _key,
                child: ListView(
                  children: [

                    Padding(padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: new Text(
                        "Enter new password",
                        style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        obscureText: _isHidden,
                        controller: newPassWord,
                        validator: (value) {
                          Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                          RegExp regex = new RegExp(pattern);

                          if (value.isEmpty) {
                            return 'Please enter password';
                          } else {
                            if (!regex.hasMatch(value))
                              return 'Must be 8 characters long with uppercase and special character';
                          }
                          return null;
                        },
                        onChanged: (text) {
                          if (validateStructure(text) == false) {
                            setState(() {
                              checkPassword = true;
                              passwordError = "Must be 8 characters long with uppercase and special character";
                            });
                          } else {
                            setState(() {
                              checkPassword = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          suffix: InkWell(
                            onTap: _togglePassword,
                            child: Icon(
                              _isHidden ? Icons.visibility : Icons.visibility_off,),
                          ),
                          contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 25.0),
                          errorStyle: TextStyle(fontSize: 10),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.deepOrange.withOpacity(0.8),
                                width: 2.0),
                          ),
                          errorText: checkPassword == true ? passwordError : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
            child: SleekButton(
              onTap: () {

                if (_key.currentState.validate()) {
                  changePassword();
                }
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
                  "RESET PASSWORD",
                  style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}

///route to another page or widget,(same as Intent in java)
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

