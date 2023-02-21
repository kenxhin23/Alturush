
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import 'db_helper.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homePage.dart';
import 'showDpn.dart';
import 'dart:async';
import 'account_lock/accountLock.dart';
import 'account_lock/enterUsername.dart';

//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class CreateAccountSignIn extends StatefulWidget {
  @override
  _CreateAccountSignIn createState() => _CreateAccountSignIn();
}

class _CreateAccountSignIn extends State<CreateAccountSignIn>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<FormState>();
  final db = RapidA();
  StateSetter _stateSetter;

  DateTime dateTime;
  List userData;
  List townData;
  List barrioData;
  List suffixData;
  List mobileList;
  final findUsername = TextEditingController();
  final _usernameLogIn = TextEditingController();
  final _passwordLogIn = TextEditingController();
  final username = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final suffix = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final birthday = TextEditingController();
  final contactNumber = TextEditingController();
  final province = TextEditingController();
  final town = TextEditingController();
  final barrio = TextEditingController();
  final forgotPassUsername = TextEditingController();
  final otpCode = TextEditingController();

  int townId;
  int barrioId;
  var isLoading = true;
  var userExist = "";
  var emailExist = "";
  var passwordError = "";
  var phoneNumberExist = "";
  var signUpErrorText = "";
  var realMobileNumber ="";
  var mobileNumber="";
  var userID ="";

  static const int fiveMinutes = 3 * 60 * 1000;
  static const int threeMinutes = 2 * 60;
  static const String lastAttemptKey = 'lastAttempt';
  static const String lastAttemptKey2 = 'lastAttempt2';
  static int remainingSeconds = 0;
  int seconds;


  Timer countdownTimer;
  Duration myDuration = Duration(seconds: remainingSeconds);

  Timer countdownTimer2;
  Duration myDuration2 = Duration(seconds: 90);

  int lastAttempt;
  int lastAttempt2;
  int remaining;
  int now;
  int now2;
  int difference;
  int difference2;

  String checkUser;
  String userName;

  bool checkUserName = false;
  bool checkEmail = false;
  bool checkPhoneNumber = false;
  bool checkPassword = false;
  bool _isHidden = true;
  bool boolSignInErrorTextEmail = false;
  bool otp = true;
  bool resend = false;
  bool attempt = false;

  TabController _tabController;

  /// Timer related methods ///
  // Step 3
  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }
  // Step 4
  void stopTimer() {
    setState(() => countdownTimer?.cancel());
  }
  // Step 5
  void resetTimer() {
    stopTimer();
    setState(() => myDuration = Duration(seconds: remainingSeconds));
  }
  // Step 6
  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer?.cancel();
        myDuration = Duration(seconds: 0);
        setState(() {
          attempt = false;
        });
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  /// Timer related methods ///
  // Step 3
  void startTimer2() {
    countdownTimer2 = Timer.periodic(Duration(seconds: 1), (_) => setCountDown2());
  }
  // Step 4
  void stopTimer2() {
    _stateSetter(() => countdownTimer2?.cancel());
  }
  // Step 5
  void resetTimer2() {
    stopTimer();
    _stateSetter(() => myDuration2 = Duration(seconds: 90));
  }
  // Step 6
  void setCountDown2() {
    final reduceSecondsBy = 1;
    _stateSetter(() {
      seconds = myDuration2.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer2?.cancel();
        myDuration2 = Duration(seconds: 90);
        _stateSetter(() {
          otp = true;
          resend = false;
        });
      } else {
        myDuration2 = Duration(seconds: seconds);

      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadTowns();

    province.text = "Bohol";
    _tabController = TabController(vsync: this, length: 2);
  }

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  Future checkUserIfExist(username) async{
    var res = await db.checkUsernameIfExist(username);
    if (!mounted) return;
    setState(() {
      // checkUsernameIfExistVar = res;
      checkUser = res;
      if(res == "true"){
        boolSignInErrorTextEmail = true;
        userName = username;
        findUsername.clear();
      }if(res == "false"){
        if (!mounted) return;
        setState(() {
          boolSignInErrorTextEmail = false;
          signUpErrorText = "Username not found";
        });
      }
      print(checkUser);
    });
  }

  @override
  void dispose() {
    _usernameLogIn.dispose();
    _passwordLogIn.dispose();
    username.dispose();
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    suffix.dispose();
    password.dispose();
    confirmPassword.dispose();
    birthday.dispose();
    contactNumber.dispose();
    province.dispose();
    town.dispose();
    barrio.dispose();
    _tabController.dispose();
    // timer.cancel();
    countdownTimer?.cancel();
    countdownTimer2?.cancel();
    super.dispose();
  }

  Future loadTowns() async {
    var res = await db.getTowns();
    if (!mounted) return;
    setState(() {
      townData = res['user_details'];
      isLoading = false;
    });
  }

  checkUsernameIfExist(text) async {
    if (text.length != 0) {
      var res = await db.checkUsernameIfExist(text);
      if (!mounted) return;
      if (res == "true") {
        setState(() {
          checkUserName = true;
          userExist = "Username is already taken";
        });
      } else {
        setState(() {
          checkUserName = false;
        });
      }
    }
  }

  checkEmailIfExist(text) async {
    if (text.length != 0) {
      var res = await db.checkEmailIfExist(text);
      if (!mounted) return;
      if (res == "true") {
        setState(() {
          checkEmail = true;
          emailExist = "Email is already taken";
        });
      } else {
        setState(() {
          checkEmail = false;
        });
      }
      print(res);
    }
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

  Future loadBarrio() async {
    var res = await db.getBarrioCi(townId.toString());
    if (!mounted) return;
    setState(() {
      barrioData = res['user_details'];
      isLoading = false;
    });
  }

//   Future selectSuffix() async {
//     var res = await db.selectSuffixCi();
// //    var res = await db.selectSuffix();
//     if (!mounted) return;
//     setState(() {
//       suffixData = res['user_details'];
//       isLoading = false;
//     });
//   }

  String validateEmail(String value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty ){
      return 'Enter Email address';
    }
    if (!regex.hasMatch(value)) {
      return 'Enter a valid Email Address';
    }
    if (checkEmail != false) {
      return 'Email is already taken';
    }
      return null;
  }

  void onEnd() {
    // print('onEnd');
  }

  void _togglePassword(){
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  // void selectSuffixDia() async {
  //   FocusScope.of(context).requestFocus(FocusNode());
  //   showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(8.0))),
  //         contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
  //         title: Text(
  //           'Select suffix',
  //         ),
  //         content: Container(
  //           height: 200.0, // Change as per your requirement
  //           width: 300.0, // Change as per your requirement
  //           child: RefreshIndicator(
  //             onRefresh: selectSuffix,
  //             child: Scrollbar(
  //               child: ListView.builder(
  //                 physics: BouncingScrollPhysics(),
  //                 shrinkWrap: true,
  //                 itemCount: suffixData == null ? 0 : suffixData.length,
  //                 itemBuilder: (BuildContext context, int index) {
  //                   return InkWell(
  //                     onTap: () {
  //                       suffix.text = suffixData[index]['suffix'];
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: ListTile(
  //                       title: Text(suffixData[index]['suffix']),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: Colors.grey.withOpacity(0.8),
  //               ),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               town.clear();
  //               barrio.clear();
  //               suffix.clear();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void selectTown() async {
    loadTowns();
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('Select town'),
          content: Container(
            height: 400.0, // Change as per your requirement
            width: 300.0, // Change as per your requirement
            child: RefreshIndicator(
              color: Colors.deepOrangeAccent,
              onRefresh: loadTowns,
              child: Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: townData == null ? 0 : townData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        town.text = townData[index]['town_name'];
                        townId = int.parse(townData[index]['town_id']);
                        loadBarrio();
                        Navigator.of(context).pop();
                      },
                      child: ListTile(
                        title: Text(townData[index]['town_name']),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                town.clear();
                barrio.clear();
              },
            ),
          ],
        );
      },
    );
  }

  void selectBarrio() async {
    loadBarrio();
    FocusScope.of(context).requestFocus(FocusNode());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text(
            'Select barangay',
          ),
          content: Container(
            height: 400.0,
            width: 300.0,
            child: RefreshIndicator(
              color: Colors.deepOrangeAccent,
              onRefresh: loadBarrio,
              child: Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: barrioData == null ? 0 : barrioData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        barrio.text = barrioData[index]['brgy_name'];
                        barrioId = int.parse(barrioData[index]['brgy_id']);
                        Navigator.of(context).pop();
                      },
                      child: ListTile(
                        title: Text(barrioData[index]['brgy_name']),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                barrio.clear();
              },
            ),
          ],
        );
      },
    );
  }

  void dpn() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text('DATA PRIVACY CONSENT', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
          content: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                child: Text("I understand and agree that by providing my personal data or by clicking the applicable icon or button, I am agreeing "
                    "to the Privacy Notice and giving any full consent to Alturas Group of Companies (AGC), its respective subsidiaries, "
                    "affiliates, associated companies and jointly controlled entities as well as its partners and service providers. If any, to "
                    "collect, store, access and/or process any personal data it may provide herein, such as but not limited to my name and "
                    "email address, whether manually or electronically for the period allowed under the applicable law and regulations. "
                    "\n"
                    "\n"
                    "I acknowledge that the collection and processing of my personal data is necessary for the purposes detailed in the "
                    "Privacy Notice. I am aware of my right to be informed, to access, to object, to erasure or blocking, to damages, to file "
                    "a complaint, to rectify and to data portability, and I understand that there are procedures, conditions and exceptions "
                    "to be complied with in order to exercise or invoke such rights.", style: TextStyle(fontSize: 16.0),)),
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
              child: Text('I AGREE', style: TextStyle(fontSize: 16.0, color: Colors.white,fontWeight: FontWeight.bold),),
              onPressed: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(_showDpn());
                // Navigator.of(context).pop();
                saveUser();
              },
            ),
          ],
        );
      },
    );
  }

  Future saveUser() async {
    // String alert;
    // String warning;
    await db.createAccountSample(
        firstName.text,
        lastName.text,
        email.text,
        birthday.text,
        contactNumber.text,
        username.text,
        password.text);


    _tabController.animateTo((_tabController.index + 1) % 2);
    // if (res == 'true') {
    //   Navigator.of(context).pop();
    //   warning = "Notice!";
    //   alert = "Phone number is already exist.";
    //   alertDialog(alert, warning);
    // } else {
    //   Navigator.of(context).pop();
    //   showDialog<void>(
    //     context: context,
    //     barrierDismissible: false, // user must tap button!
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(8.0))
    //         ),
    //         contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
    //         title: Text(
    //           'Success!',
    //           style: TextStyle(fontSize: 18.0),
    //         ),
    //         content: SingleChildScrollView(
    //           child: ListBody(
    //             children: <Widget>[
    //               Center(
    //                 child: Text("You can log in now"),
    //               ),
    //             ],
    //           ),
    //         ),
    //         actions: <Widget>[
    //           FlatButton(
    //             child: Text(
    //               'OK',
    //               style: TextStyle(
    //                 color: Colors.deepOrange,
    //               ),
    //             ),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //               _tabController.animateTo((_tabController.index + 1) % 2);
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
    username.clear();
    firstName.clear();
    lastName.clear();
    email.clear();
    password.clear();
    birthday.clear();
    contactNumber.clear();
    town.clear();
    barrio.clear();
    suffix.clear();
  }

  trapInputs() {
    String alert;
    String warning;
    setState(() {
      if (firstName.text.isEmpty) {
        warning = "Notice!";
        alert = "First name is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (firstName.text.length < 2) {
        warning = "Notice!";
        alert = "Please enter a valid first name";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      // } else if (firstName.text[0] == ' ') {
      //   warning = "Notice!";
      //   alert = "Please enter a valid firstname";
      //   alertDialog(alert, warning);
      //   FocusScope.of(context).requestFocus(FocusNode());
      } else if (lastName.text.isEmpty) {
        warning = "Notice!";
        alert = "Last name is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      // } else if (lastName.text[0] == ' ') {
      //   warning = "Notice!";
      //   alert = "Please enter a valid lastname";
      //   alertDialog(alert, warning);
      //   FocusScope.of(context).requestFocus(FocusNode());
      } else if (lastName.text.length < 2) {
        warning = "Notice!";
        alert = "Please enter a valid last name";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());

      }else if (email.text.isEmpty) {
        warning = "Notice!";
        alert = "Email is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (birthday.text.isEmpty) {
        warning = "Notice!";
        alert = "Birthday is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (checkPhoneNumber == true) {
        warning = "Notice!";
        alert = "Phone number is already taken";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (contactNumber.text.isEmpty) {
        warning = "Notice!";
        alert = "Contact number is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (contactNumber.text.length < 10 ||
          contactNumber.text[0] == '0' ||
          contactNumber.text[0] == '1' ||
          contactNumber.text[0] == '2' ||
          contactNumber.text[0] == '3' ||
          contactNumber.text[0] == '4' ||
          contactNumber.text[0] == '5' ||
          contactNumber.text[0] == '6' ||
          contactNumber.text[0] == '7' ||
          contactNumber.text[0] == '8') {
        warning = "Notice!";
        alert = "Contact number is invalid.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (username.text.isEmpty) {
        warning = "Notice!";
        alert = "Username is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (username.text[0] == ' ') {
        warning = "Notice!";
        alert = "Please enter a valid username";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (checkUserName == true) {
        warning = "Notice!";
        alert = "Username is already taken";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (password.text.isEmpty) {
        warning = "Notice!";
        alert = "Password is empty.";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else if (checkPassword == true) {
        warning = "Notice!";
        alert = "Must be at least 8 characters long with a number, an uppercase letter and a special character";
        alertDialog(alert, warning);
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        FocusScope.of(context).requestFocus(FocusNode());
        dpn();
      }
    });
  }

  alertDialog(alert, warning) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text(
            warning,
            style: TextStyle(fontSize: 18.0),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Center(
                    child: Text(
                      alert,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.deepOrange,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future _getBirthDay() async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime newDateTime = await showRoundedDatePicker(
      height: 260,
      context: context,
      initialDate: DateTime(DateTime.now().year - 13),
      firstDate: DateTime(DateTime.now().year - 70),
      lastDate: DateTime(DateTime.now().year - 13),
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      borderRadius: 8.0,
    );
    if (newDateTime != null) {
      setState(() {
        dateTime = newDateTime;
        birthday.text = DateFormat("yyyy-MM-dd").format(dateTime);
      });
    }
  }

  _signInCheck() {
      FocusScope.of(context).requestFocus(FocusNode());
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    height: 60.0,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.deepOrange),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
      checkLogin();
  }

  var wrongAttempt = 0;
  accountLockout() async {

    db.changeAccountStat(_usernameLogIn.text);
    setState(() {
      Navigator.of(context).pop();
      wrongAttempt = 0;
    });
    var login = true;
    Navigator.of(context).push(accountLock(_usernameLogIn.text, login));
    _usernameLogIn.clear();
    _passwordLogIn.clear();
  }

  Future checkLogin() async {
    String alert;
    String warning;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lastAttempt = prefs.getInt(lastAttemptKey);
    lastAttempt2 = prefs.getInt(lastAttemptKey2);
    print(difference);
    print(lastAttempt);
    print(now);
    print(lastAttempt2);

    var userID = prefs.getString('s_customerId');
    var res = await db.checkLogin(_usernameLogIn.text, _passwordLogIn.text);
    print(res);
    String lastUsername = prefs.getString('username');
    if (res == 'accountblocked') {
      wrongAttempt = 0;
      prefs.clear();
      accountLockout();
    } else {
      if (_usernameLogIn.text != lastUsername.toString()) {
        wrongAttempt = 0;
        prefs.clear();
      }

      if (res == 'wrongusername') {
        wrongAttempt = 0;
        prefs.clear();
        Navigator.of(context).pop();
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "User not found",
          confirmBtnColor: Colors.deepOrangeAccent,
          backgroundColor: Colors.deepOrangeAccent,
          barrierDismissible: false,
          confirmBtnText: 'Okay',
          onConfirmBtnTap: () async {
            Navigator.of(context, rootNavigator: true).pop();
          },
        );
      }
      if (res == 'unverified') {
        wrongAttempt = 0;
        prefs.clear();
        otpCode.clear();
        Navigator.of(context).pop();
        setState(() {
          if (seconds == null) {
            getUserDetails2();
          } else {
            startTimer2();
          }
          // sendOtp();
          sendOTP();
        });

      }

      if (res == 'wrongpass') {
        Navigator.of(context).pop();
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "Your password is incorrect",
          confirmBtnColor: Colors.deepOrangeAccent,
          backgroundColor: Colors.deepOrangeAccent,
          barrierDismissible: false,
          confirmBtnText: 'Okay',
          onConfirmBtnTap: () async {
            Navigator.of(context, rootNavigator: true).pop();
          },
        );
        wrongAttempt += 1;
        prefs.setString('wrongAttempt', "$wrongAttempt");
        prefs.setString('username', _usernameLogIn.text);

        if (wrongAttempt >= 3) {

          // Initialize SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          // Store attempt time
          prefs.setInt(lastAttemptKey, DateTime.now().millisecondsSinceEpoch);
          prefs.setInt(lastAttemptKey2, DateTime.now().second);

          // accountLockout();
          print('locked');
        }
      }
      if (res == 'false') {
        wrongAttempt = 0;
        prefs.clear();
        Navigator.of(context).pop();
        warning = "Notice!";
        alert = "Wrong username and password";
        alertDialog(alert, warning);
      }

      // if (_isNumeric(res) == true) {
      //   wrongAttempt = 0;
      //   var userRes = await db.getUserData(res);
      //   userData = userRes['user_details'];
      //   // print(userData);
      //   SharedPreferences prefs = await SharedPreferences.getInstance();
      //   prefs.clear();
      //   prefs.setString('s_status', 'true');
      //   prefs.setString('s_customerId', userData[0]['d_customerId']);
      //   prefs.setString('s_userNameUs', userData[0]['d_userNameUs']);
      //   prefs.setString('s_firstname', userData[0]['d_firstname']);
      //   prefs.setString('s_lastname', userData[0]['d_lastname']);
      //   prefs.setString('s_contact', userData[0]['d_contact']);
      //   // prefs.setString('s_suffix', userData[0]['d_suffix']);
      //   // prefs.setString('s_townId', userData[0]['d_townId']);
      //   // prefs.setString('s_brgId', userData[0]['d_brgId']);
      //   Navigator.of(context).pop();
      //   Navigator.of(context).pop();
      // }

      // Check if is not null
      if (lastAttempt != null) {
        // Get time now

        setState(() {
          now = DateTime.now().millisecondsSinceEpoch;
          now2 = DateTime.now().second;

          // Get the difference from last login attempt
          difference = now - lastAttempt;
          difference2 = now2 - lastAttempt2;
          remainingSeconds = ((fiveMinutes - difference) / 1000).ceil();
        });

        print('remaining secondes kay $remainingSeconds');


        // Check if 5 minutes passed since last login attempt
        if (difference >= fiveMinutes) {
          // User can try to login again
          prefs.remove(lastAttemptKey);
          if (_isNumeric(res) == true) {
            wrongAttempt = 0;
            var userRes = await db.getUserData(res);
            userData = userRes['user_details'];
            // print(userData);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            prefs.setString('s_status', 'true');
            prefs.setString('s_customerId', userData[0]['d_customerId']);
            prefs.setString('s_userNameUs', userData[0]['d_userNameUs']);
            prefs.setString('s_firstname', userData[0]['d_firstname']);
            prefs.setString('s_lastname', userData[0]['d_lastname']);
            prefs.setString('s_contact', userData[0]['d_contact']);
            // prefs.setString('s_suffix', userData[0]['d_suffix']);
            // prefs.setString('s_townId', userData[0]['d_townId']);
            // prefs.setString('s_brgId', userData[0]['d_brgId']);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        } else {
          attempt = true;
          setState(() {
            if (remainingSeconds != 0){
              resetTimer();
            }

            startTimer();
          });


          print('huwat sa ug $fiveMinutes');
          remaining = lastAttempt + 1000 * 10;

          print(remaining);

          // Still in limit, show error
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: "Too many attempts \n Please try again later",
            confirmBtnColor: Colors.deepOrangeAccent,
            backgroundColor: Colors.deepOrangeAccent,
            barrierDismissible: false,
            confirmBtnText: 'Okay',
            onConfirmBtnTap: () async {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context, rootNavigator: true).pop();
            },
          );
        }
      } else {
        // First try of user login
        if (_isNumeric(res) == true) {
          wrongAttempt = 0;
          var userRes = await db.getUserData(res);
          userData = userRes['user_details'];
          // print(userData);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          prefs.setString('s_status', 'true');
          prefs.setString('s_customerId', userData[0]['d_customerId']);
          prefs.setString('s_userNameUs', userData[0]['d_userNameUs']);
          prefs.setString('s_firstname', userData[0]['d_firstname']);
          prefs.setString('s_lastname', userData[0]['d_lastname']);
          prefs.setString('s_contact', userData[0]['d_contact']);
          // prefs.setString('s_suffix', userData[0]['d_suffix']);
          // prefs.setString('s_townId', userData[0]['d_townId']);
          // prefs.setString('s_brgId', userData[0]['d_brgId']);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }

    }
  }

  sendOTP() {

    return showDialog<void>(

      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return StatefulBuilder(
            builder : (BuildContext context, StateSetter state) {

              _stateSetter = state;
              String strDigits(int n) => n.toString().padLeft(2, '0');
              // final days = strDigits(myDuration.inDays);
              // // Step 7
              final hours = strDigits(myDuration2.inHours.remainder(24));
              final minutes = strDigits(myDuration2.inMinutes.remainder(60));
              final seconds = strDigits(myDuration2.inSeconds.remainder(60));

              return WillPopScope(
                onWillPop: () async{
                  stopTimer2();
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
                              child: new Text("Enter OTP CODE sent to: $mobileNumber",
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
                              child: Padding(
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
                                          resetTimer2();
                                          startTimer2();
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
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: BorderSide(color: Colors.deepOrangeAccent)
                            )
                        ),
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled))
                              return Colors.grey[400];
                            else {
                              return Colors.deepOrangeAccent;
                            }
                            return null; // Use the component's default.
                          },
                        ),

                      ),

                      child: Text(
                        'SUBMIT',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          if (_key.currentState.validate()) {
                            getUserDetails();
                            verifyOtpCode();
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  successMessageOTP(){
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Account Verified",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      onConfirmBtnTap: () async {

        Navigator.of(context).pop();

      },
    );
  }

  verifyOtpCode() async{
    var res = await db.verifyOtpCode(otpCode.text,realMobileNumber, userID);
    if(res == 'true'){
      setState(() {

      });
      otpCode.clear();
      Navigator.of(context, rootNavigator: true).pop();
      successMessageOTP();
      stopTimer2();
      // Navigator.of(context).push(_enterNewPassword(realMobileNumber,widget.login));
    }
    if(res == 'false'){
      wrongOTP();
    }
    print(res);
  }

  wrongOTP() {
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


  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  accountRecovery() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder : (BuildContext context, StateSetter state) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))
              ),
              contentPadding: EdgeInsets.only(top: 5),
              content: Container(
                height: 400.0,
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
                                child: Text("Account Recovery", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                              ),
                            ],
                          )
                      ),
                      Divider(thickness: 1, color: Colors.black54),

                      Padding(padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                        child: new Text("Enter Username",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
                          onChanged: (text) {
                            checkUsernameIfExist(text);
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            errorText: checkUserName == true ? userExist : null,
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
                        checkUserIfExist(findUsername.text);
                        sendOtp();
                        // getUserDetails();
                      }
                    });
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future getUserDetails() async{
    var res = await db.getUserDetails(userName);
    if (!mounted) return;
    setState(() {
      mobileList = res['user_details'];
      realMobileNumber = mobileList[0]['mobile_number'];
      var re = RegExp(r'\d(?!\d{0,2}$)'); // keep last 3 digits
      mobileNumber = realMobileNumber.replaceAll(re, '*'); // ------789
      userID = mobileList[0]['user_id'];
      // print(mobileList);
    });
  }

  Future getUserDetails2() async{
    var res = await db.getUserDetails(_usernameLogIn.text);
    if (!mounted) return;
    setState(() {
      mobileList = res['user_details'];
      realMobileNumber = mobileList[0]['mobile_number'];
      var re = RegExp(r'\d(?!\d{0,2}$)'); // keep last 3 digits
      mobileNumber = realMobileNumber.replaceAll(re, '*'); // ------789
      userID = mobileList[0]['user_id'];
      submitOTPNumber(realMobileNumber);
      print('ang user details kay');
      // print(mobileList);
    });
  }

  Future sendOtp() async{
    otpCode.clear();
    submitOTPNumber(realMobileNumber);
    print('ang number kay $realMobileNumber');
    // print('ang number kay $realMobileNumber');
    // submitOTPNumber(realMobileNumber);
  }

  Future submitOTPNumber(realMobileNumber) async{
    var res = await db.verifyOTP(realMobileNumber);
    print(res);
  }



  @override
  Widget build(BuildContext context) {

    String strDigits(int n) => n.toString().padLeft(2, '0');
    final days = strDigits(myDuration.inDays);
    // Step 7
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));


    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120.0),
          child: AppBar(
            titleSpacing: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.deepOrangeAccent[200], // Status bar
            ),
            backgroundColor: Colors.white,
            elevation: 0.1,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 23,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.deepOrange,
              tabs: [

                Tab(
                  child: Text("Log in",
                    style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                ),

                Tab(
                  child: Text("Sign up",
                    style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Image.asset(
                  'assets/png/alturush_text_logo.png',
                  fit: BoxFit.contain,
                  height: 30,
                ),
              ],
            ),
          ),
        ),
        body:
        isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor:
              new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) : Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [

              //login
              Scrollbar(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[

                    // Padding(
                    //   padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 25.0),
                    //   child:Container(
                    //     height: 50.0,
                    //     child: SignInButton(
                    //       Buttons.FacebookNew,
                    //       text: "Sign in with facebook",
                    //       onPressed: () {
                    //         _facebookSignIn();
                    //       },
                    //     ),
                    //   ),
                    //  ),

                    SizedBox(height: 50),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 5.0),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        controller: _usernameLogIn,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter Username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Username',
                          prefixIcon: Icon(CupertinoIcons.person, color: Colors.black54,),
                          contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.deepOrange.withOpacity(0.8),
                                width: 2.0),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
//                        onFieldSubmitted: (String value) {
//                          FocusScope.of(context).requestFocus(textSecondFocusNode);
//                        },
                      ),
                    ),

                    SizedBox(height: 30),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 5.0),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        obscureText: _isHidden,
                        controller: _passwordLogIn,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(CupertinoIcons.lock, color: Colors.black54,),
                          suffix: InkWell(
                            onTap: _togglePassword,
                            child: Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(_isHidden ? Icons.visibility : Icons.visibility_off, size: 18,),
                            )
                          ),
                          contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.deepOrange.withOpacity(0.8),
                                width: 2.0),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 35.0, 30.0, 30.0),
                      child: SleekButton(

                        onTap: ()
                        {
                          if (_formKey.currentState.validate()) {
                            getUserDetails();
                            userName = _usernameLogIn.text;
                            _signInCheck();
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
                            "Login",
                            style: GoogleFonts.openSans(
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontSize: 19.0),
                          ),
                        ),
                      ),
                    ),


                    Visibility(
                      visible: attempt,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text('Too many login attempts. Please try again after $minutes:$seconds', style: TextStyle(fontSize: 15, color: Colors.redAccent),),
                        ),
                      ),
                    ),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          var login = "false";
                          showAccountRecoveryDialog(context);
                          // Navigator.of(context).push(enterUsername(login));
                        },
                        child: Text("Forgot username/password?",style: TextStyle(color: Colors.black54))
                      ),
                    ),
                  ],
                ),
              ),

              //signUp
              Scrollbar(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[

                    SizedBox(
                      height: 15.0,
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 5.0),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        controller: firstName,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter First Name';
                          }
                          if (value.length<2){
                            return 'Enter a valid First Name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'First Name',
                          contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 25.0),
                          errorStyle: TextStyle(fontSize: 10),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.deepOrange.withOpacity(0.8),
                                width: 2.0),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 15.0,
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 5.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: new TextFormField(
                              textInputAction: TextInputAction.done,
                              cursorColor:
                              Colors.deepOrange.withOpacity(0.8),
                              controller: lastName,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter Last Name';
                                }
                                if (value.length<2){
                                  return 'Enter a valid Last Name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Last Name',
                                contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 25.0),
                                errorStyle: TextStyle(fontSize: 10),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange.withOpacity(0.8), width: 2.0),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15.0),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: new TextFormField(
                              textInputAction: TextInputAction.done,
                              cursorColor:
                              Colors.deepOrange.withOpacity(0.8),
                              controller: email,
                              onChanged: (text) {
                                checkEmailIfExist(text);
                              },
                              validator: (value) => validateEmail(value),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 25.0),
                                errorStyle: TextStyle(fontSize: 10),
                                errorText: checkEmail == true ? emailExist : null,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.deepOrange.withOpacity(0.8), width: 2.0),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15.0),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 5.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25.0),
                        onTap: _getBirthDay,
                        child: IgnorePointer(
                          child: new TextFormField(
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            readOnly: true,
                            controller: birthday,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter Birthday';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Birthday",
                              contentPadding: EdgeInsets.fromLTRB(
                                  15.0, 10.0, 10.0, 25.0),
                              errorStyle: TextStyle(fontSize: 10),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                    Colors.deepOrange.withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 15.0),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 5.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: new TextFormField(
                              maxLength: 10,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                    new RegExp('[.-]'))
                              ],
                              cursorColor: Colors.deepOrange.withOpacity(0.8),
                              controller: contactNumber,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter Mobile Number';
                                }
                                if (contactNumber.text.length < 10 ||
                                    contactNumber.text[0] == '0' ||
                                    contactNumber.text[0] == '1' ||
                                    contactNumber.text[0] == '2' ||
                                    contactNumber.text[0] == '3' ||
                                    contactNumber.text[0] == '4' ||
                                    contactNumber.text[0] == '5' ||
                                    contactNumber.text[0] == '6' ||
                                    contactNumber.text[0] == '7' ||
                                    contactNumber.text[0] == '8')
                                  {
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
                                errorStyle: TextStyle(fontSize: 10),
                                labelText: '+63',
                                labelStyle: TextStyle(color: Colors.black),
                                hintText: ' (ex. 9123456783)',
                                counterText: "",
                                contentPadding: EdgeInsets.fromLTRB(
                                    15.0, 10.0, 10.0, 25.0),
                                errorText: checkPhoneNumber == true
                                    ? phoneNumberExist
                                    : null,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.deepOrange
                                          .withOpacity(0.8),
                                      width: 2.0),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(5.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15.0),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        controller: username,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter Username';
                          }
                          if (value.length < 2) {
                            return 'Enter a valid Username';
                          }
                          if (checkUserName != false){
                            return 'Username is already taken';
                          }
                          return null;
                        },
                        onChanged: (text) {
                          checkUsernameIfExist(text);
                        },
                        decoration: InputDecoration(
                          hintText: 'Username',
                          contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 25.0),
                          errorStyle: TextStyle(fontSize: 10),
                          errorText: checkUserName == true ? userExist : null,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.deepOrange.withOpacity(0.8),
                                width: 2.0),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),

                    SizedBox(height: 15.0),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                      child: new TextFormField(
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepOrange.withOpacity(0.8),
                        obscureText: _isHidden,
                        controller: password,
                        validator: (value) {
                          Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                          RegExp regex = new RegExp(pattern);

                          if (value.isEmpty) {
                            return 'Enter Password';
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
                          hintText: 'Password',
                          suffix: InkWell(
                            onTap: _togglePassword,
                            child: Icon(
                              _isHidden ? Icons.visibility : Icons.visibility_off,),
                          ),
                          contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 25.0),
                          errorStyle: TextStyle(fontSize: 10),
                          errorText: checkPassword == true ? passwordError : null,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.deepOrange.withOpacity(0.8),
                                width: 2.0),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.0),

                    Padding(
                      padding:
                      EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 25.0),
                      child: SleekButton(
                        onTap: () {
                          if (_formKey.currentState.validate()) {
                            dpn();
                          }
                          print(contactNumber.text);
                          print(birthday.text);
                          checkUsernameIfExist(username.text);
                          checkEmailIfExist(email.text);
                          userName = username.text;

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
                            "REGISTER",
                            style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              fontSize: 19.0),
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  showAccountRecoveryDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AccountRecoveryDialog();
      },
    );
  }
}

class AccountRecoveryDialog extends StatefulWidget {
  @override
  _AccountRecoveryDialogState createState() => _AccountRecoveryDialogState();
}

class _AccountRecoveryDialogState extends State<AccountRecoveryDialog> {
  final db = RapidA();
  final _key = GlobalKey<FormState>();
  final findUsername = TextEditingController();
  bool boolSignInErrorTextEmail = true;

  List mobileList;
  var signUpErrorText = "";
  var realMobileNumber="";
  String checkUser;
  String userName;

  Future checkUserIfExist(username) async{
    var res = await db.checkUsernameIfExist(username);
    if (!mounted) return;
    setState(() {
      // checkUsernameIfExistVar = res;
      checkUser = res;
      if(res == "true"){
        boolSignInErrorTextEmail = true;
        // Navigator.push(context,
        //   MaterialPageRoute(builder: (context) => OtpDialog(findUsername.text)),
        // );
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => OtpDialog(findUsername.text)));
        // Navigator.of(context).push(OtpDialog(findUsername.text));
        userName = username;
        showOtpDialog(context);
        // Navigator.of(context).pop();
        findUsername.clear();
      }if(res == "false"){
        if (!mounted) return;
        setState(() {
          boolSignInErrorTextEmail = false;
          signUpErrorText = "Username not found";
        });
      }
      // print("imong ig-ampo si $username");
    });
  }

  Future getUserDetails() async{
    var res = await db.getUserDetails(findUsername.text);
    if (!mounted) return;
    setState(() {
      mobileList = res['user_details'];
      realMobileNumber = mobileList[0]['mobile_number'];
      print('real number kay $realMobileNumber');
    });
  }

  Future getUserDetails2() async{
    var res = await db.getUserDetails(findUsername.text);
    if (!mounted) return;
    setState(() {
      mobileList = res['user_details'];
      realMobileNumber = mobileList[0]['mobile_number'];
      print('real number kay $realMobileNumber');
      saveOTPNumber(realMobileNumber);
    });
  }

  Future sendOtp() async{
    // findUsername.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        saveOTPNumber(realMobileNumber);
        print('ang number kay $realMobileNumber');
      });
    });

  }

  Future saveOTPNumber(realMobileNumber) async{
    var res = await db.recoverOTP(realMobileNumber);
    print(res);
  }

  @override
  void initState(){
    // startTimer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

   return AlertDialog(
     shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.all(Radius.circular(8.0))
     ),
     contentPadding: EdgeInsets.only(top: 5),
     content: Container(
       height: 160.0,
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
                     child: Text("Account Recovery", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                   ),
                 ],
               )
             ),

             Divider(thickness: 1, color: Colors.black54),

             Padding(padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
               child: new Text("Enter Username",
                 style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold),
               ),
             ),

             Padding(
               padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
                   contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
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
           print(findUsername.text);
           setState(() {
             // startTimer();
           });
           if (_key.currentState.validate()) {
             checkUserIfExist(findUsername.text);
             // sendOtp();
             getUserDetails2();
           }
         },
       ),
     ],
   );
  }

  showOtpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return OtpDialog(userName);
      },
    );
  }
}

class OtpDialog extends StatefulWidget {
  final String username;

  const OtpDialog(this.username);

  // String username;
  // const OtpDialog(this.username, {String username});


  @override
  _OtpDialogState createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {

  final db = RapidA();
  final _key = GlobalKey<FormState>();
  final otpCode = TextEditingController();
  List mobileList;
  var mobileNumber="";
  var realMobileNumber="";

  Timer countdownTimer;
  Duration myDuration = Duration(seconds: 90);
  bool resendOtp = true;
  bool resendOtpIn = false;

  checkOtpCode() async{
    var res = await db.checkOtpCode(otpCode.text,realMobileNumber);
    if(res == 'true'){
      otpCode.clear();
      newPasswordDialog(context);
      // Navigator.of(context).push(_enterNewPassword(realMobileNumber,widget.login));
    }
    if(res == 'false'){
      alertDialog();
    }
  }

  Future getUserDetails() async{
    var res = await db.getUserDetails(widget.username);
    if (!mounted) return;
    setState(() {
      mobileList = res['user_details'];
      mobileNumber = mobileList[0]['mobile_number'];
      realMobileNumber = mobileList[0]['mobile_number'];
      var re = RegExp(r'\d(?!\d{0,2}$)'); // keep last 3 digits
      mobileNumber = mobileNumber.replaceAll(re, '*'); // ------789
      print(widget.username);
    });
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

  Future sendOtp() async{
    otpCode.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        saveOTPNumber(realMobileNumber);
      });
    });

  }

  Future saveOTPNumber(realMobileNumber) async{
    var res = await db.recoverOTP(realMobileNumber);
    print("$res");
  }


  @override
  void initState() {
    getUserDetails();
    sendOtp();
    super.initState();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  /// Timer related methods ///
  // Step 3
  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }
  // Step 4
  void stopTimer() {
    setState(() => countdownTimer?.cancel());
  }
  // Step 5
  void resetTimer() {
    stopTimer();
    setState(() => myDuration = Duration(seconds: 90));
  }
  // Step 6
  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer?.cancel();
        myDuration = Duration(seconds: 90);
        setState(() {
          resendOtp = true;
          resendOtpIn = false;
        });
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    String strDigits(int n) => n.toString().padLeft(2, '0');
    // final days = strDigits(myDuration.inDays);
    // // Step 7
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return AlertDialog(
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
                      child: Text("Confirmation", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                    ),
                  ],
                )
              ),
              Divider(thickness: 1, color: Colors.black54),

              Padding(padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                child: new Text("Enter OTP CODE sent to: $mobileNumber",
                  style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0),
                ),
              ),

              // Padding(
              //   padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
              //   child: new Text("OTP Code",
              //     style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold),
              //   ),
              // ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: new TextFormField(
                  textInputAction: TextInputAction.done,
                  cursorColor: Colors.deepOrange.withOpacity(0.8),
                  controller: otpCode,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter OTP Code';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'OTP Code',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.deepOrange.withOpacity(0.8),
                          width: 2.0),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                  ),
                ),
              ),

              Visibility(
                visible: resendOtp,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text("Didn't receive code?", style: TextStyle(fontSize: 15, color: Colors.black)),
                      SizedBox(width: 100,
                        child: TextButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(color: Colors.transparent)
                                  )
                              )
                          ),
                          child: Text(' RESEND OTP',
                            style: TextStyle(fontSize: 15,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          onPressed: (){
                            sendOtp();
                            setState(() {
                              startTimer();
                              resendOtp = false;
                              resendOtpIn = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Visibility(
                visible: resendOtpIn,
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

            if (_key.currentState.validate()) {
              checkOtpCode();
            }

          },
        ),
      ],
    );
  }

  newPasswordDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return showPasswordDialog(realMobileNumber);
      },
    );
  }
}

class showPasswordDialog extends StatefulWidget {
  final String mobile_number;

  const showPasswordDialog(this.mobile_number);

@override
_showPasswordDialogState createState() => _showPasswordDialogState ();
}

class _showPasswordDialogState  extends State<showPasswordDialog> {

  final db = RapidA();
  final _key = GlobalKey<FormState>();
  final newPassWord = TextEditingController();
  final confirmPassWord = TextEditingController();
  var t;

  String warning;
  String alert;
  var passwordError = "";
  bool checkPassword = false;

  Future changePassword() async{
    await db.changePassword(newPassWord.text, widget.mobile_number);
    warning = "Good job!";
    alert = "Password updated successfully";
    alertDialog();
  }

  alertDialog() {
    return
      CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Password updated successfully",
      confirmBtnColor: Colors.deepOrangeAccent,
      backgroundColor: Colors.deepOrangeAccent,
      barrierDismissible: false,
      onConfirmBtnTap: () async {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }
  bool _isHidden = true;
  void _togglePassword(){
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))
      ),
      contentPadding: EdgeInsets.only(top: 5),
      content: Container(
          height: 275.0,
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
                          child: Text("Reset Password", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                        ),
                      ],
                    )
                ),

                Divider(thickness: 1, color: Colors.black54),

                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                  child: new Text("New password", style: TextStyle(
                    fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: new TextFormField(
                    textInputAction: TextInputAction.done,
                    cursorColor: Colors.deepOrange.withOpacity(0.8),
                    controller: newPassWord,
                    obscureText: _isHidden,
                    validator: (value) {
                      Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                      RegExp regex = new RegExp(pattern);

                      if (value.isEmpty) {
                        return 'Please enter new password';
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
                      contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      errorStyle: TextStyle(fontSize: 9),
                      errorText: checkPassword == true ? passwordError : null,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.deepOrange.withOpacity(0.8),
                            width: 2.0),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                  child: new Text("Confirm password", style: TextStyle(
                    fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: new TextFormField(
                    textInputAction: TextInputAction.done,
                    cursorColor: Colors.deepOrange.withOpacity(0.8),
                    controller: confirmPassWord,
                    obscureText: _isHidden,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter confirm password';
                      }
                      if (value != newPassWord.text) {
                        return "Password didn't match";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: 9),
                      contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
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

            if (_key.currentState.validate()) {
              changePassword();
              // checkOtpCode();
            }
          },
        ),
      ],
    );
  }
}

Route _showDpn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ShowDpn(),
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

Route accountLock(_usernameLogIn, login) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        AccountLock(usernameLogIn: _usernameLogIn, login: login),
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

Route enterUsername(login) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EnterUsername(login: login),
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

