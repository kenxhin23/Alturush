import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arush/db_helper.dart';
import '../homePage.dart';
import 'addNewAddress.dart';
import 'package:flutter/cupertino.dart';
import 'package:arush/create_account_signin.dart';

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettings createState() => _AccountSettings();
}

class _AccountSettings extends State<AccountSettings>
    with SingleTickerProviderStateMixin{
  final db = RapidA();
  final _formKey = GlobalKey<FormState>();
  TextEditingController password = TextEditingController();
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController newUsername = TextEditingController();
  TabController _tabController;

  var userExist = "";
  var passwordError = "";

  bool checkPassword = false;
  bool _isHidden1 = true;
  bool _isHidden2 = true;
  bool _isHidden3 = true;
  bool _isHidden4 = true;
  bool checkUserName = false;
  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  void _togglePassword1(){
    setState(() {
      _isHidden1 = !_isHidden1;
    });
  }

  void _togglePassword2(){
    setState(() {
      _isHidden2 = !_isHidden2;
    });
  }

  void _togglePassword3(){
    setState(() {
      _isHidden3 = !_isHidden3;
    });
  }

  void _togglePassword4(){
    setState(() {
      _isHidden4 = !_isHidden4;
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

  @override
  void initState() {

    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }
  @override
  void dispose() {
    password.dispose();
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    newUsername.dispose();
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  changeUsername() async{
    var res = await db.updateUsername(password.text,newUsername.text);
    if (!mounted) return;
    setState(() {
      if(res == 'wrongPass'){
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "Your current password is incorrect",
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
          onCancelBtnTap: () async {
          }
        );
      } else if (res == 'userTaken') {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "Username is already taken",
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
          onCancelBtnTap: () async {
          }
        );
      } else {
        CoolAlert.show(
          context: context,
          showCancelBtn: true,
          type: CoolAlertType.success,
          text: "Your username has been changed successfully",
          confirmBtnColor: Colors.deepOrangeAccent,
          backgroundColor: Colors.deepOrangeAccent,
          barrierDismissible: false,
          confirmBtnText: 'Later',
          onConfirmBtnTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String username = prefs.getString('s_customerId');
            if (username == null) {
              Navigator.of(context).push(_signIn());
            }
            if (username != null) {
              Navigator.of(context).pop();
              password.clear();
              newUsername.clear();
            }
          },
          cancelBtnText: 'Log-out',
          onCancelBtnTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(createAccountSignInRoute());
          }
        );
      }
    });

    print(res);
  }

  changePassword() async{
    var res = await db.updatePassword(currentPassword.text,newPassword.text);
    if (!mounted) return;
    setState(() {
      if(res == 'wrongPass'){

        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "Your current password is incorrect",
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
          onCancelBtnTap: () async {
          }
        );
      } else if (res == 'samePass') {

        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: "Please enter a new password",
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
          onCancelBtnTap: () async {
          }
        );
      } else {
        CoolAlert.show(
          context: context,
          showCancelBtn: true,
          type: CoolAlertType.success,
          text: "Your password has been changed successfully",
          confirmBtnColor: Colors.deepOrangeAccent,
          backgroundColor: Colors.deepOrangeAccent,
          barrierDismissible: false,
          confirmBtnText: 'Later',
          onConfirmBtnTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String username = prefs.getString('s_customerId');
            if (username == null) {
              Navigator.of(context).push(_signIn());
            }
            if (username != null) {
              Navigator.of(context).pop();
              currentPassword.clear();
              newPassword.clear();
              confirmPassword.clear();
            }
          },
          cancelBtnText: 'Log-out',
          onCancelBtnTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(createAccountSignInRoute());
          }
        );
      }
      print(res);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrangeAccent, // Status bar
          statusBarIconBrightness: Brightness.light ,  // Only honored in Android M and above
        ),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.white, size: 20,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: Text("Username",
                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
              ),
            ),
            Tab(
              child: Text("Password",
                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white),
              ),
            ),
          ],
        ),
        title: Text("Account Settings",
          style: GoogleFonts.openSans(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 16.0),
        ),
      ),
      body:
      Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [

            ///Change Username
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Expanded(
                  child:Scrollbar(
                    child: ListView(
                      shrinkWrap: true,
                      children: [

                        Row(
                          children: [

                            Padding(
                              padding: EdgeInsets.only(left: 5, top: 10, bottom:  10),
                              child: Icon(CupertinoIcons.person, size: 25, color: Colors.deepOrange[300]),
                            ),

                            Padding(
                              padding: EdgeInsets.only(left: 5, top: 15, bottom: 10),
                              child: Text('Change Username',
                                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                          child: new Text("Current Password",
                            style: GoogleFonts.openSans(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                          child:TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            obscureText: _isHidden1,
                            controller: password,
                            style: GoogleFonts.openSans(fontSize: 14),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter Current Password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 25.0),
                              hintText: 'Current Password',
                              hintStyle: GoogleFonts.openSans(color: Colors.black38, fontSize: 15),
                              suffix: InkWell(
                                onTap: _togglePassword1,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(_isHidden1 ? Icons.visibility : Icons.visibility_off, size: 18),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 1.0),

                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
                          child: new Text("New Username",
                            style: GoogleFonts.openSans(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                          child:TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            controller: newUsername,
                            style: GoogleFonts.openSans(fontSize: 14),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter New Username';
                              }
                              if (value.length < 2) {
                                return 'Enter a valid Username';
                              }
                              // if (checkUserName != false){
                              //   return 'Username is already taken';
                              // }
                              return null;
                            },
                            onChanged: (text) {
                              setState(() {
                                checkUsernameIfExist(text);
                              });
                            },
                            decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 25.0),
                              hintText: 'New Username',
                              hintStyle: GoogleFonts.openSans(color: Colors.black38, fontSize: 15),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    children: <Widget>[

                      SizedBox(width: 2.0),

                      Flexible(
                        child: SleekButton(
                          onTap: () {
                           if (_formKey.currentState.validate()) {
                             changeUsername();
                           }
                          },
                          style: SleekButtonStyle.flat(
                            color: Colors.deepOrange,
                            inverted: false,
                            rounded: false,
                            size: SleekButtonSize.normal,
                            context: context,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.paperplane, size: 20),
                                Text(" SUBMIT",
                                  style:GoogleFonts.openSans(fontStyle: FontStyle.normal,fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            ///Change Password
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Expanded(
                  child:Scrollbar(
                    child: ListView(
                      shrinkWrap: true,
                      children: [

                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 5, top: 10, bottom:  10),
                              child: Icon(CupertinoIcons.lock, size: 25, color: Colors.deepOrange[300]),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5, top: 15, bottom: 10),
                              child: Text('Change Password',
                                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54),
                              ),
                            )
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 15, 5, 5),
                          child: new Text("Current Password",
                            style: GoogleFonts.openSans(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                          child:TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            obscureText: _isHidden2,
                            controller: currentPassword,
                            style: GoogleFonts.openSans(fontSize: 14),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter Current Password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 25.0),
                              errorStyle: TextStyle(fontSize: 10),
                              hintText: 'Current Password',
                              hintStyle: GoogleFonts.openSans(color: Colors.black38, fontSize: 15),
                              suffix: InkWell(
                                onTap: _togglePassword2,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(_isHidden2 ? Icons.visibility : Icons.visibility_off, size: 18,),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 1.0),

                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
                          child: new Text("New Password",
                            style: GoogleFonts.openSans(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                          child:TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            obscureText: _isHidden3,
                            controller: newPassword,
                            style: GoogleFonts.openSans(fontSize: 14),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                              RegExp regex = new RegExp(pattern);

                              if (value.isEmpty) {
                                return 'Enter New Password';
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
                            decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 25.0),
                              hintText: 'New Password',
                              errorStyle: TextStyle(fontSize: 10),
                              hintStyle: GoogleFonts.openSans(color: Colors.black38, fontSize: 15),
                              errorText: checkPassword == true ? passwordError : null,
                              suffix: InkWell(
                                  onTap: _togglePassword3,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(_isHidden3 ? Icons.visibility : Icons.visibility_off, size: 18,),
                                  )
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(35, 10, 5, 5),
                          child: new Text(
                            "Confirm Password",
                            style: GoogleFonts.openSans(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),

                        Padding(
                          padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                          child:TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.deepOrange.withOpacity(0.8),
                            obscureText: _isHidden4,
                            controller: confirmPassword,
                            style: GoogleFonts.openSans(fontSize: 14),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter Confirm Password';
                              }
                              if (value != newPassword.text) {
                                return 'New Password and Confirm Password does not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 25.0),
                              errorStyle: TextStyle(fontSize: 10),
                              hintText: 'Confirm Password',
                              hintStyle: GoogleFonts.openSans(color: Colors.black38, fontSize: 15),
                              suffix: InkWell(
                                onTap: _togglePassword4,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(_isHidden4 ? Icons.visibility : Icons.visibility_off, size: 18,),
                                )
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.8),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                          onTap: () {
                            if(_formKey.currentState.validate()) {
                              changePassword();
                            }
                          },
                          style: SleekButtonStyle.flat(
                            color: Colors.deepOrange,
                            inverted: false,
                            rounded: false,
                            size: SleekButtonSize.normal,
                            context: context,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.paperplane, size: 20),
                                Text(" SUBMIT",
                                  style:GoogleFonts.openSans(fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                              ],
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
        )
      )
    );
  }
}

Route createAccountSignInRoute() {
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

Route _signIn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        CreateAccountSignIn(),
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

