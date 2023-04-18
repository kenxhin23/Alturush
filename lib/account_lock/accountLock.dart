import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import '../db_helper.dart';
import 'enterNewPassword.dart';

class AccountLock extends StatefulWidget {
  final usernameLogIn;
  final login;

  AccountLock({Key key, @required this.usernameLogIn, this.login}) : super(key: key);
  @override
  _AccountLock createState() => _AccountLock();
}

class _AccountLock extends State<AccountLock> {
  final db = RapidA();
  final otpCode = TextEditingController();
  List mobileList;
  var mobileNumber="";
  var realMobileNumber="";
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  String warning = "";
  String alert = "";

///check if input OTP is correct or not
  checkOtpCode() async{
    var res = await db.checkOtpCode(otpCode.text,realMobileNumber);
    if(res == 'true'){
      otpCode.clear();
        Navigator.of(context).push(_enterNewPassword(realMobileNumber,widget.login));
    }
    if(res == 'false'){
      alertDialog();
    }
  }

  alertDialog() {
    return CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      text: "Invalid OTP code, please check and try again.",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      confirmBtnText: 'Okay',
      onConfirmBtnTap: () async {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }

  ///retrieve users mobile number
  Future getUserDetails() async{
    var res = await db.getUserDetails(widget.usernameLogIn);
    if (!mounted) return;
    setState(() {
      mobileList = res['user_details'];
      mobileNumber = mobileList[0]['mobile_number'];
      realMobileNumber = mobileList[0]['mobile_number'];
      var re = RegExp(r'\d(?!\d{0,2}$)'); // keep last 3 digits
      mobileNumber = mobileNumber.replaceAll(re, '*'); // ------789
      sendOtp();
    });
  }

  Future sendOtp() async{
    // otpCode.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        saveOTPNumber(realMobileNumber);
      });
    });
  }

  Future saveOTPNumber(realMobileNumber) async{
    var res = await db.recoverOTP(realMobileNumber);
    print(res);
  }


  @override
  void initState(){
    getUserDetails();

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
        title: Text("Account Recovery",
          style: GoogleFonts.openSans(
            color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0,
          ),
        ),
      ),

      ///display the main page or body of the app
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          Expanded(
            child:Scrollbar(
              child: Form(
                key: _key,
                child: ListView(
                  children: [

                    Padding(padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: new Text("OTP has been sent to your mobile number:",
                        style: TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 15.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: new Text("$mobileNumber, please enter it below",
                        style: TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 15.0),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(right: 15.0, left: 15.0, top: 45),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        controller: otpCode,
                        validator: (value){
                          if (value.isEmpty) {
                            return 'Please enter the OTP code';
                          }
                          return null;
                        },
                        decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange.withOpacity(0.8),
                              width: 2.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Didn't receive code? tap",
                            style: TextStyle(
                              fontSize: 15, color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 35,
                            child: TextButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(color: Colors.transparent),
                                  ),
                                ),
                              ),
                              child: Text('here',
                                style: TextStyle(fontSize: 15,
                                  color: Colors.deepOrangeAccent, decoration: TextDecoration.underline,
                                ),
                              ),
                              onPressed: (){
                                sendOtp();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding:EdgeInsets.fromLTRB(40, 20, 40, 0),
                      child:Container(
                        width: 50.0,
                        // child: FlatButton(
                        //   disabledColor: Colors.grey,
                        //   child: Text('Send OTP code'),
                        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        //   onPressed: (){
                        //     setState(() {
                        //       sendOtp();
                        //     });
                        //   },
                        // ),


                        // child: OutlineButton(
                        //   borderSide: BorderSide(color: Colors.deepOrange),
                        //   highlightedBorderColor: Colors.deepOrange,
                        //   highlightColor: Colors.transparent,
                        //   shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        //   onPressed: (){
                        //       setState(() {
                        //         sendOtp();
                        //         // Fluttertoast.showToast(
                        //         //     msg: "OTP is sent to your phone number",
                        //         //     toastLength: Toast.LENGTH_SHORT,
                        //         //     gravity: ToastGravity.BOTTOM,
                        //         //     timeInSecForIosWeb: 2,
                        //         //     backgroundColor: Colors.black.withOpacity(0.7),
                        //         //     textColor: Colors.white,
                        //         //     fontSize: 16.0
                        //         // );
                        //       });
                        //   },
                        //   child: Text("Send OTP code"),
                        // ),
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
                FocusScope.of(context).requestFocus(FocusNode());
                if (_key.currentState.validate()) {
                  // Navigator.of(context).push(_gcPickUpFinal(groupValue,_deliveryTime.text,_deliveryDate.text,_modeOfPayment.text));
                  checkOtpCode();
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
                  style: TextStyle(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///route to another page or widget,(same as Intent in java)
Route _enterNewPassword(realMobileNumber,login) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EnterNewPassword(realMobileNumber:realMobileNumber,login:login),
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


