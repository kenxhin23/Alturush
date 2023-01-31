import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import '../db_helper.dart';
import 'package:arush/create_account_signin.dart';
import 'accountLock.dart';

class EnterUsername extends StatefulWidget {
  final login;
  EnterUsername({Key key, @required this.login,}) : super(key: key);
  @override
  _EnterUsername createState() => _EnterUsername();
}

class _EnterUsername extends State<EnterUsername> {
  final db = RapidA();

  final findUsername = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  List mobileList;
  bool boolSignInErrorTextEmail = false;
  var signUpErrorText = "";
  var realMobileNumber="";

  ///check if user exist
  Future checkUsernameIfExist(username) async{
    var res = await db.checkUsernameIfExist(username);
    if (!mounted) return;
    setState(() {
      // checkUsernameIfExistVar = res;
      if(res == "true"){
        boolSignInErrorTextEmail = true;
        Navigator.of(context).push(accountLock(findUsername.text ,widget.login));
        findUsername.clear();
      }if(res == "false"){
        if (!mounted) return;
        setState(() {
          boolSignInErrorTextEmail = false;
          signUpErrorText = "Username not found";
        });
      }
    });
  }

  ///get user details
  Future getUserDetails() async{
    var res = await db.getUserDetails(findUsername.text);
    if (!mounted) return;
    setState(() {
      mobileList = res['user_details'];
      realMobileNumber = mobileList[0]['mobile_number'];
      print('real number kay $realMobileNumber');
    });
  }

  ///send to receive otp code
  Future sendOtp() async{
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        saveOTPNumber(realMobileNumber);
      });
    });

    print('ang number kay $realMobileNumber');
  }

  ///send or save entered otp code
  Future saveOTPNumber(realMobileNumber) async{
    db.recoverOTP(realMobileNumber);
  }

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
        title: Text("Account Recovery",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      ///display the main page or body of the app
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Expanded(
            child:Scrollbar(
              child: Form(
                key: _key,
                child: ListView(
                  children: [

                    Padding(padding: EdgeInsets.fromLTRB(25, 20, 5, 5),
                      child: new Text("Enter Username",
                        style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        controller: findUsername,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 25.0),
                          errorText: boolSignInErrorTextEmail == false ? signUpErrorText : null,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange.withOpacity(0.8),
                              width: 2.0),
                          ),
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
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            child: SleekButton(
              onTap: () {
                if (_key.currentState.validate()) {
                  // changePassword();
                  checkUsernameIfExist(findUsername.text);
                  sendOtp();
                  getUserDetails();
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
                  "SUBMIT",
                  style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: 16.0, fontWeight: FontWeight.bold,
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

///route to another page or widget,(same as Intent in java)
Route accountLock(_usernameLogIn,login){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AccountLock(usernameLogIn:_usernameLogIn,login:login),
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
