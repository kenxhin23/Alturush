import 'dart:async';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_button/sleek_button.dart';

import '../create_account_signin.dart';
import '../db_helper.dart';


class MyDialogs {

}

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettings createState() => _ProfileSettings();
}

class _ProfileSettings extends State<ProfileSettings>
    with SingleTickerProviderStateMixin{
  final db = RapidA();
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<FormState>();
  final _keyUpdate = GlobalKey<FormState>();
  TabController _tabController;
  StateSetter _stateSetter;

  final firstName =  TextEditingController();
  final lastName =  TextEditingController();
  final email=  TextEditingController();
  final mobileNumber =  TextEditingController();
  final _number = TextEditingController();
  final _numberUpdate = TextEditingController();
  final otpCode = TextEditingController();

  Timer countdownTimer;
  Duration myDuration = Duration(seconds: 90);
  int seconds;

  bool checkPhoneNumber = false;
  bool editProfile = false;
  bool updateButton = true;
  bool submitButton = false;
  bool otp = true;
  bool resend = false;
  var phoneNumberExist = "";
  var isLoading = true;

  List getMobileNumbers;
  List getAppUser;

  int number;
  String num;
  var mobileNum="";

  Future getMobileNumber() async{
    var res = await db.getMobileNumber();
    if (!mounted) return;
    setState(() {
      getMobileNumbers = res['user_details'];
      for(int q = 0;q<getMobileNumbers.length;q++) {
        if (getMobileNumbers[q]['in_use'] == '1') {
          number = q;
        }
      }
      // print(getMobileNumbers);
      isLoading = false;
    });
  }

  Future getAppUsers() async{
    var res = await db.getAppUsers();
    if (!mounted) return;
    setState(() {
      getAppUser = res['user_details'];
      firstName.text = getAppUser[0]['firstname'];
      lastName.text = getAppUser[0]['lastname'];
      email.text = getAppUser[0]['email'];
      num = getAppUser[0]['mobile_number'];
      var re = RegExp(r'\d(?!\d{0,2}$)'); // keep last 3 digits
      mobileNum = num.replaceAll(re, '*'); // ------789
      mobileNumber.text = num.substring(num.length - 10).toString();
      print(num);
      isLoading = false;
      print('refresh nah');
    });
  }

  checkPhoneIfExist(text) async {
    if (text.length != 0) {
      var res = await db.checkPhoneIfExist(text);
      if (!mounted) return;
      if (res == "true") {
        setState(() {
          checkPhoneNumber = true;
          phoneNumberExist = "Phone number is already in-used";
        });
      } else {
        setState(() {
          checkPhoneNumber = false;
        });
      }
    }
  }

  checkPhoneIfExist2(text) async {
    if (text.length != 0) {
      var res = await db.checkPhoneIfExist(text);
      if (!mounted) return;
      if (res == "true") {
        setState(() {
          checkPhoneNumber = true;
          phoneNumberExist = "Phone number is already in-used";
        });
      } else {
        setState(() {
          checkPhoneNumber = false;
        });
      }
    }
  }

  Future uploadNumber() async{
    await db.uploadNumber(_number.text);
    getMobileNumber();
    successMessage();
  }

  Future updateNumber(id) async{
    await db.updateNumber(id, _numberUpdate.text);
    getMobileNumber();
    successMessage2();
  }

  successMessage(){
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Mobile Number Successfully Added",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      onConfirmBtnTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String username = prefs.getString('s_customerId');
        if (username == null) {
          Navigator.of(context).push(_signIn());
        }
        if (username != null) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  successMessage2(){
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Mobile Number Successfully Updated",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      onConfirmBtnTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String username = prefs.getString('s_customerId');
        if (username == null) {
          Navigator.of(context).push(_signIn());
        }
        if (username != null) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  updateMobileNumber(id,customerId) async{
    await db.updateDefaultNumber(id,customerId);
  }

  Future onRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }
    getMobileNumber();
    getAppUsers();
  }

  @override
  void initState() {
    onRefresh();
    getMobileNumber();
    getAppUsers();
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
    _number.dispose();
  }

  /// Timer related methods ///
  // Step 3
  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }
  // Step 4
  void stopTimer() {
    _stateSetter(() => countdownTimer?.cancel());
  }
  // Step 5
  void resetTimer() {
    stopTimer();
    _stateSetter(() => myDuration = Duration(seconds: 90));
  }
  // Step 6
  void setCountDown() {
    final reduceSecondsBy = 1;
    _stateSetter(() {
      seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer?.cancel();
        myDuration = Duration(seconds: 90);
        _stateSetter(() {
          otp = true;
          resend = false;
        });
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  updateNumberDialog(id, number) async{
    checkPhoneIfExist(number);
    _numberUpdate.text = number.substring(number.length - 10);
    FocusScope.of(context).requestFocus(FocusNode());

    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: StatefulBuilder(builder: (BuildContext context, StateSetter state) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                ),
                contentPadding: EdgeInsets.all(0),
                titlePadding: EdgeInsets.all(0),
                title: Container(
                  height: 140,
                  width: 300,
                  child: Form(
                    key: _keyUpdate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                          child: Text('Mobile Number',
                            style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Divider(thickness: 2, color: Colors.deepOrangeAccent),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: TextFormField(
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  new RegExp('[.-]'))
                            ],
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            controller: _numberUpdate,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter Mobile Number';
                              }
                              if (_numberUpdate.text.length < 10 ||
                                  _numberUpdate.text[0] == '0' ||
                                  _numberUpdate.text[0] == '1' ||
                                  _numberUpdate.text[0] == '2' ||
                                  _numberUpdate.text[0] == '3' ||
                                  _numberUpdate.text[0] == '4' ||
                                  _numberUpdate.text[0] == '5' ||
                                  _numberUpdate.text[0] == '6' ||
                                  _numberUpdate.text[0] == '7' ||
                                  _numberUpdate.text[0] == '8') {
                                return 'Enter a valid Mobile Number';
                              }
                              if (checkPhoneNumber == true){
                                return 'Phone number is already in-used';
                              }
                              return null;
                            },
                            onChanged: (text) {
                              checkPhoneIfExist(text);
                            },
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.7),
                                    width: 2.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              labelText: '+63',
                              labelStyle: TextStyle(color: Colors.black, fontSize: 14),
                              counterText: "",
                              errorText: checkPhoneNumber == true
                                  ? phoneNumberExist
                                  : null,
                              hintStyle: const TextStyle(fontStyle: FontStyle
                                  .normal,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ),
                actions: <Widget>[
                  OutlinedButton(
                    style: TextButton.styleFrom(
                      primary: Colors.black,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                    ),
                    onPressed: () {
                      _numberUpdate.clear();
                      Navigator.pop(context);
                    },
                    child: Text("CLOSE", style: GoogleFonts.openSans(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0),),
                  ),
                  OutlinedButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.deepOrangeAccent,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                    ),
                    onPressed: () {
                      state(() {
                        print(_numberUpdate.text);
                        if (_keyUpdate.currentState.validate()) {
                          updateNumber(id);
                          Navigator.pop(context);
                          _numberUpdate.clear();
                        }
                      });
                    },
                    child: Text("SUBMIT", style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0)
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {}
    );

    // showDialog<void>(
    //   context: context,
    //   barrierDismissible: false, // user must tap button!
    //   builder: (BuildContext context) {
    //     return StatefulBuilder(builder: (BuildContext context, StateSetter state)
    //     {
    //       return AlertDialog(
    //         shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(8.0))
    //         ),
    //         contentPadding: EdgeInsets.all(0),
    //         titlePadding: EdgeInsets.all(0),
    //         title: Container(
    //             height: 140,
    //             width: 300,
    //             child: Form(
    //               key: _keyUpdate,
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Padding(
    //                       padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
    //                       child: Text('Mobile Number',
    //                         style: GoogleFonts.openSans(
    //                             fontStyle: FontStyle.normal,
    //                             fontSize: 15.0,
    //                             fontWeight: FontWeight.bold,
    //                             color: Colors.black54),)
    //                   ),
    //                   Divider(thickness: 2, color: Colors.deepOrangeAccent),
    //                   Padding(
    //                     padding: EdgeInsets.only(left: 10, right: 10, top: 20),
    //                     child: TextFormField(
    //                       maxLength: 10,
    //                       keyboardType: TextInputType.number,
    //                       inputFormatters: [
    //                         FilteringTextInputFormatter.deny(
    //                             new RegExp('[.-]'))
    //                       ],
    //                       cursorColor: Colors.deepOrange.withOpacity(0.8),
    //                       controller: _numberUpdate,
    //                       validator: (value) {
    //                         if (value.isEmpty) {
    //                           return 'Enter Mobile Number';
    //                         }
    //                         if (_numberUpdate.text.length < 10 ||
    //                             _numberUpdate.text[0] == '0' ||
    //                             _numberUpdate.text[0] == '1' ||
    //                             _numberUpdate.text[0] == '2' ||
    //                             _numberUpdate.text[0] == '3' ||
    //                             _numberUpdate.text[0] == '4' ||
    //                             _numberUpdate.text[0] == '5' ||
    //                             _numberUpdate.text[0] == '6' ||
    //                             _numberUpdate.text[0] == '7' ||
    //                             _numberUpdate.text[0] == '8') {
    //                           return 'Enter a valid Mobile Number';
    //                         }
    //                         if (checkPhoneNumber == true){
    //                           return 'Phone number is already in-used';
    //                         }
    //                         return null;
    //                       },
    //                       onChanged: (text) {
    //                         checkPhoneIfExist(text);
    //                       },
    //                       decoration: InputDecoration(
    //                         focusedBorder: OutlineInputBorder(
    //                           borderRadius: BorderRadius.circular(15),
    //                           borderSide: BorderSide(
    //                               color: Colors.deepOrange.withOpacity(0.7),
    //                               width: 2.0),
    //                         ),
    //                         contentPadding: const EdgeInsets.symmetric(
    //                           horizontal: 10,
    //                           vertical: 10,
    //                         ),
    //                         labelText: '+63',
    //                         labelStyle: TextStyle(color: Colors.black, fontSize: 14),
    //                         counterText: "",
    //                         errorText: checkPhoneNumber == true
    //                             ? phoneNumberExist
    //                             : null,
    //                         hintStyle: const TextStyle(fontStyle: FontStyle
    //                             .normal,
    //                             fontSize: 14,
    //                             fontWeight: FontWeight.normal,
    //                             color: Colors.black),
    //                         border: OutlineInputBorder(
    //                           borderRadius: BorderRadius.circular(15),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             )
    //         ),
    //         actions: <Widget>[
    //           OutlinedButton(
    //             style: TextButton.styleFrom(
    //               primary: Colors.black,
    //               shape: new RoundedRectangleBorder(
    //                   borderRadius: new BorderRadius.circular(30.0)),
    //             ),
    //             onPressed: () {
    //               _numberUpdate.clear();
    //               Navigator.pop(context);
    //             },
    //             child: Text("CLOSE", style: GoogleFonts.openSans(
    //                 color: Colors.black54,
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 12.0),),
    //           ),
    //           OutlinedButton(
    //             style: TextButton.styleFrom(
    //               primary: Colors.white,
    //               backgroundColor: Colors.deepOrangeAccent,
    //               shape: new RoundedRectangleBorder(
    //                   borderRadius: new BorderRadius.circular(30.0)),
    //             ),
    //             onPressed: () {
    //               state(() {
    //                 print(_numberUpdate.text);
    //                 if (_keyUpdate.currentState.validate()) {
    //                   updateNumber(id);
    //                   Navigator.pop(context);
    //                   _numberUpdate.clear();
    //                 }
    //               });
    //             },
    //             child: Text("SUBMIT", style: GoogleFonts.openSans(
    //                 color: Colors.white,
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 12.0),),
    //           ),
    //         ],
    //       );
    //     });
    //   },
    // );
  }
  addNumberDialog() async{
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter state)
        {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
            ),
            contentPadding: EdgeInsets.all(0),
            titlePadding: EdgeInsets.all(0),
            title: Container(
              height: 140,
              width: 300,
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                      child: Text('Mobile Number',
                        style: GoogleFonts.openSans(
                          fontStyle: FontStyle.normal,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                      ),
                    ),

                    Divider(thickness: 2, color: Colors.deepOrangeAccent),

                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: TextFormField(
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                              new RegExp('[.-]'))
                        ],
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        controller: _number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter Mobile Number';
                          }
                          if (_number.text.length < 10 ||
                              _number.text[0] == '0' ||
                              _number.text[0] == '1' ||
                              _number.text[0] == '2' ||
                              _number.text[0] == '3' ||
                              _number.text[0] == '4' ||
                              _number.text[0] == '5' ||
                              _number.text[0] == '6' ||
                              _number.text[0] == '7' ||
                              _number.text[0] == '8') {
                            return 'Enter a valid Mobile Number';
                          }
                          if (checkPhoneNumber == true){
                            return 'Phone number is already in-used';
                          }
                          return null;
                        },
                        onChanged: (text) {
                          checkPhoneIfExist2(text);
                        },
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors.deepOrange.withOpacity(0.7),
                                width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          labelText: '+63',
                          labelStyle: TextStyle(color: Colors.black),
                          hintText: '(ex. 9123456783)',
                          counterText: "",
                          errorText: checkPhoneNumber == true
                              ? phoneNumberExist
                              : null,
                          hintStyle: const TextStyle(fontStyle: FontStyle
                              .normal,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),
            actions: <Widget>[

              OutlinedButton(
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _number.clear();
                },
                child: Text("CLOSE", style: GoogleFonts.openSans(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0),),
              ),

              OutlinedButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.deepOrangeAccent,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                ),
                onPressed: () {
                  if (_key.currentState.validate()) {
                    uploadNumber();
                    Navigator.pop(context);
                    _number.clear();
                  }
                },
                child: Text("SUBMIT", style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  successMessageOTP(){
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "You can now update your profile",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      onConfirmBtnTap: () async {

        Navigator.of(context).pop();

      },
    );
  }

  successMessageUpdate(){
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Your profile was successfully Updated",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      onConfirmBtnTap: () async {
        setState(() {
          editProfile = false;
          submitButton = false;
          updateButton = true;
          getAppUsers();
          Navigator.of(context).pop();
        });
      },
    );
  }

  Future updateProfile() async{
    await db.updateProfile(
      firstName.text,
      lastName.text,
      email.text,
      mobileNumber.text);
    successMessageUpdate();
  }

  Future sendOtp() async{
    otpCode.clear();
    saveOTPNumber(num);
  }

  Future saveOTPNumber(realMobileNumber) async{
    var res = await db.updateProfileOTP(realMobileNumber);
    print(res);
    print("ang number kay: $realMobileNumber");
  }

  checkOtpCode() async{
    var res = await db.checkOtpCode(otpCode.text,num);
    if(res == 'true'){
      setState(() {
        editProfile = true;
        updateButton = false;
        submitButton = true;
      });
      otpCode.clear();
      Navigator.of(context, rootNavigator: true).pop();
      successMessageOTP();
      // Navigator.of(context).push(_enterNewPassword(realMobileNumber,widget.login));
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

  sendOTP() {

    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: StatefulBuilder(
              builder : (BuildContext context, StateSetter state) {

                _stateSetter = state;
                String strDigits(int n) => n.toString().padLeft(2, '0');
                // final days = strDigits(myDuration.inDays);
                // // Step 7
                final hours = strDigits(myDuration.inHours.remainder(24));
                final minutes = strDigits(myDuration.inMinutes.remainder(60));
                final seconds = strDigits(myDuration.inSeconds.remainder(60));


                return WillPopScope(
                  onWillPop: () async {
                    stopTimer();
                    return true;
                  },
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                    ),
                    contentPadding: EdgeInsets.only(top: 5),
                    content: Container(
                        height: 250.0,
                        width: 300.0,
                        child: Form(
                          key: _key,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              SizedBox(height: 30,
                                  child: Row(
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        child: Text("Alturush (OTP)", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                                      ),
                                    ],
                                  )
                              ),

                              Divider(thickness: 1, color: Colors.black54),

                              Padding(padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                                child: new Text("Enter OTP CODE sent to: $mobileNum",
                                  style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                child: new TextFormField(
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.deepOrange.withOpacity(0.8),
                                  controller: otpCode,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter OTP code';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    // errorText: checkUserName == true ? userExist : null,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepOrange.withOpacity(0.8),
                                          width: 2.0),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: otp,
                                child:  Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Text("Didn't receive code? ", style: TextStyle(fontSize: 15, color: Colors.black)),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.all(0),
                                        ),
                                        child: Text(
                                          'RESEND OTP',
                                          style: TextStyle(fontSize: 15,
                                            color: Colors.deepOrangeAccent,
                                          ),
                                        ),
                                        onPressed: (){
                                          sendOtp();

                                          state(() {
                                            startTimer();
                                            otp = false;
                                            resend = true;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: resend,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10, top: 15),
                                  child: Row(
                                    children: [
                                      Text('Resend OTP in ',
                                        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 15),
                                      ),
                                      Text('$minutes:$seconds',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ),
                    actions: <Widget>[

                      TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(color: Colors.deepOrangeAccent)
                                )
                            )
                        ),
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          state(() {
                            if (_key.currentState.validate()) {
                              checkOtpCode();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {}
    );

    // return showDialog<void>(
    //   context: context,
    //   barrierDismissible: false, // user must tap button!
    //   builder: (BuildContext context) {
    //     return StatefulBuilder(
    //       builder : (BuildContext context, StateSetter state) {
    //         return AlertDialog(
    //           shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.all(Radius.circular(8.0))
    //           ),
    //           contentPadding: EdgeInsets.only(top: 5),
    //           content: Container(
    //               height: 175.0,
    //               width: 300.0,
    //               child: Form(
    //                 key: _key,
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.start,
    //                   crossAxisAlignment: CrossAxisAlignment.stretch,
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     SizedBox(height: 30,
    //                         child: Row(
    //                           children: [
    //                             Padding(
    //                               padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
    //                               child: Text("Alturush (OTP)", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
    //                             ),
    //                           ],
    //                         )
    //                     ),
    //                     Divider(thickness: 1, color: Colors.black54),
    //
    //
    //                     Padding(
    //                       padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
    //                       child: new TextFormField(
    //                         textInputAction: TextInputAction.done,
    //                         cursorColor: Colors.deepOrange.withOpacity(0.8),
    //                         controller: otpCode,
    //                         validator: (value) {
    //                           if (value.isEmpty) {
    //                             return 'Please enter OTP code';
    //                           }
    //                           return null;
    //                         },
    //                         decoration: InputDecoration(
    //                           contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
    //                           // errorText: checkUserName == true ? userExist : null,
    //                           focusedBorder: OutlineInputBorder(
    //                             borderSide: BorderSide(
    //                                 color: Colors.deepOrange.withOpacity(0.8),
    //                                 width: 2.0),
    //                           ),
    //                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
    //                         ),
    //                       ),
    //                     ),
    //
    //                     Padding(
    //                         padding: EdgeInsets.only(left: 10),
    //                         child: Row(
    //                           children: [
    //                             Text("Didn't receive code? tap", style: TextStyle(fontSize: 15, color: Colors.black)),
    //                             TextButton(
    //                               style: TextButton.styleFrom(
    //                                   padding: EdgeInsets.all(0), alignment: Alignment.centerLeft
    //                               ),
    //                               child: Text(
    //                                 ' here',
    //                                 style: TextStyle(fontSize: 15,
    //                                   color: Colors.deepOrangeAccent,
    //                                 ),
    //                               ),
    //                               onPressed: (){
    //                                 // sendOtp();
    //                               },
    //                             ),
    //                           ],
    //                         )
    //                     )
    //                   ],
    //                 ),
    //               )
    //           ),
    //           actions: <Widget>[
    //             TextButton(
    //               style: ButtonStyle(
    //                   backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
    //                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                       RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.circular(20.0),
    //                           side: BorderSide(color: Colors.deepOrangeAccent)
    //                       )
    //                   )
    //               ),
    //               child: Text(
    //                 'SUBMIT',
    //                 style: TextStyle(
    //                   color: Colors.white,
    //                 ),
    //               ),
    //               onPressed: () {
    //                 state(() {
    //                   if (_key.currentState.validate()) {
    //                     checkOtpCode();
    //                   }
    //                 });
    //               },
    //             ),
    //           ],
    //         );
    //       }
    //     );
    //   },
    // );
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.deepOrange,
          tabs: [
            Tab(
              child: Text(
                "Profile",
                style: GoogleFonts.openSans(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0),
              ),
            ),
            Tab(
              child: Text("Contact Numbers",
                style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
            ),
          ],
        ),
        title: Text("Profile",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0),),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      )  : Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [

            //Profile Tabview
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Expanded(
                  child: RefreshIndicator(
                    color: Colors.deepOrangeAccent,
                    onRefresh: onRefresh,
                    child:Scrollbar(
                      child: ListView(
                        shrinkWrap: true,
                        children: [

                          Padding(
                            padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                            child: new Text("First Name", style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: CupertinoColors.black, fontWeight: FontWeight.bold),
                            ),
                          ),

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            child:TextFormField(
                              enabled: editProfile,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.done,
                              cursorColor: Colors.deepOrange.withOpacity(0.8),
                              controller: firstName,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some value';
                                }
                                return null;
                              },
                              decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.deepOrange.withOpacity(0.8), width: 2.0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                            child: new Text(
                              "Last Name",
                              style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            child:TextFormField(
                              enabled: editProfile,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.done,
                              cursorColor: Colors.deepOrange.withOpacity(0.8),
                              controller: lastName,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some value';
                                }
                                return null;
                              },
                              decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.deepOrange.withOpacity(0.8), width: 2.0),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0),),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                            child: new Text("E-mail Address", style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            child:TextFormField(
                              enabled: editProfile,
                              textInputAction: TextInputAction.done,
                              cursorColor: Colors.deepOrange.withOpacity(0.8),
                              controller: email,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some value';
                                }
                                return null;
                              },
                              decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.deepOrange.withOpacity(0.8), width: 2.0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                            child: new Text("Mobile Number", style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),

                          Padding(
                            padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            child:TextFormField(
                              enabled: editProfile,
                              maxLength: 10,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                    new RegExp('[.-]'))
                              ],
                              cursorColor: Colors.deepOrange.withOpacity(0.8),
                              controller: mobileNumber,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter Mobile Number';
                                }
                                if (mobileNumber.text.length < 10 ||
                                    mobileNumber.text[0] == '0' ||
                                    mobileNumber.text[0] == '1' ||
                                    mobileNumber.text[0] == '2' ||
                                    mobileNumber.text[0] == '3' ||
                                    mobileNumber.text[0] == '4' ||
                                    mobileNumber.text[0] == '5' ||
                                    mobileNumber.text[0] == '6' ||
                                    mobileNumber.text[0] == '7' ||
                                    mobileNumber.text[0] == '8') {
                                  return 'Enter a valid Mobile Number';
                                }
                                if (checkPhoneNumber == true){
                                  return 'Phone number is already in-used';
                                }
                                return null;
                              },
                              onChanged: (text) {
                                checkPhoneIfExist(text);
                              },
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                prefixText: '+63',
                                prefixStyle: TextStyle(color: Colors.black, fontSize: 16),
                                hintText: '(ex. 9123456783)',
                                counterText: "",
                                errorText: checkPhoneNumber == true
                                    ? phoneNumberExist
                                    : null,
                                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(color: Colors.deepOrange.withOpacity(0.8), width: 2.0),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0),),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 2.0,
                      ),
                      Visibility(
                        visible: updateButton,
                        child: Flexible(
                          child: SleekButton(
                            onTap: () {
                              // sendOtp();

                              if (seconds != null) {
                                startTimer();
                              } else {
                                sendOtp();
                              }
                              sendOTP();

                            },
                            style: SleekButtonStyle.flat(
                              color: Colors.deepOrange,
                              inverted: false,
                              rounded: true,
                              size: SleekButtonSize.big,
                              context: context,
                            ),
                            child: Center(
                              child: Text("UPDATE PROFILE", style:TextStyle(fontStyle: FontStyle.normal,fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Visibility(
                        visible: submitButton,
                        child: Flexible(
                          child: SleekButton(
                            onTap: () {
                              updateProfile();
                            },
                            style: SleekButtonStyle.flat(
                              color: Colors.deepOrange,
                              inverted: false,
                              rounded: true,
                              size: SleekButtonSize.big,
                              context: context,
                            ),
                            child: Center(
                              child: Text("SUBMIT", style:TextStyle(fontStyle: FontStyle.normal,fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),

            //Contact Numbers Tabview
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.deepOrangeAccent,
                    onRefresh: getMobileNumber,
                    child: Scrollbar(
                      child: ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: getMobileNumbers == null ? 0 : getMobileNumbers.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: (){
                                  // initState();
                                  // getAppUsers();
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                  child: RadioListTile(
                                    visualDensity: const VisualDensity(
                                      horizontal: VisualDensity.minimumDensity,
                                      vertical: VisualDensity.minimumDensity,
                                    ),
                                    contentPadding: EdgeInsets.all(0),
                                    activeColor: Colors.deepOrangeAccent,
                                    title: Transform.translate(
                                      offset: const Offset(-10, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(height: 30,
                                            child: Padding(
                                                padding: EdgeInsets.only(top: 5),
                                                child: Text('${getMobileNumbers[index]['mobile_number']}',style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black))
                                            ),
                                          ),

                                          Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                children: [
                                                  VerticalDivider(thickness: 1, color: Colors.black54,),
                                                  SizedBox(width: 30,
                                                    child: RawMaterialButton(
                                                      onPressed:
                                                          () async {
                                                        updateNumberDialog(getMobileNumbers[index]['id'], getMobileNumbers[index]['mobile_number']);
                                                      },
                                                      elevation: 1.0,
                                                      child:
                                                      Icon(
                                                        CupertinoIcons.pencil, size: 20.0,
                                                        color: Colors.blueAccent,
                                                      ),
                                                      shape:
                                                      CircleBorder(),
                                                    )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    value: index,
                                    groupValue: number,
                                    onChanged: (newValue) {
                                      setState((){
                                        number = newValue;
                                        // print(getMobileNumbers[index]['id']);
                                        // print(getMobileNumbers[index]['customer_id']);
                                        updateMobileNumber(getMobileNumbers[index]['id'], getMobileNumbers[index]['customer_id']);
                                      });
                                      Future.delayed(const Duration(milliseconds: 250), () {
                                        setState(() {
                                          getAppUsers();
                                        });
                                      });
                                    },
                                  ),
                                ),
                              );
                            }
                          ),
                        ],
                      )
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 2.0,
                      ),
                      Flexible(
                        child: SleekButton(
                          onTap: () async {
                            addNumberDialog();
                            // FocusScope.of(context).requestFocus(FocusNode());
                            // showAddNumber(context);
                          },
                          style: SleekButtonStyle.flat(
                            color: Colors.deepOrange,
                            inverted: false,
                            rounded: true,
                            size: SleekButtonSize.big,
                            context: context,
                          ),
                          child: Center(
                            child: Text("ADD", style:TextStyle(fontStyle: FontStyle.normal,fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


Route _signIn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        CreateAccountSignIn(),
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