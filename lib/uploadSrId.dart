import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sleek_button/sleek_button.dart';
import 'dart:io';
import 'dart:convert';
import 'db_helper.dart';
import 'create_account_signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadSrImage extends StatefulWidget {
  @override
  _UploadSrImage createState() => _UploadSrImage();
}

class _UploadSrImage extends State<UploadSrImage> {
  final db = RapidA();
  final _formKey = GlobalKey<FormState>();
  final _idType = TextEditingController();
  final _name = TextEditingController();
  final _idNumber = TextEditingController();
  final _imageTxt = TextEditingController();
  final picker = ImagePicker();

  File _image;
  File _imageBooklet;

  List<String> selectedImages = [];
  List<String> _loadDiscount = [];
  List<String> _loadDiscountID = [];
  List loadDiscountID;
  List loadDiscount;

  String newFileName;
  String selectedValue;


  var discountId;
  var discountID;
  var id;

  camera() async{
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        newFileName = _image.toString();
        _imageTxt.text = _image.toString().split('/').last;
      }
    });
  }

  bookletCamera() async{
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null){
        _imageBooklet = File(pickedFile.path);
        newFileName = _imageBooklet.toString();
      }
    });
  }

  Future uploadId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if (username == null) {
      await Navigator.of(context).push(_signIn());
    } else {
      loading();
      String base64Image = base64Encode(_image.readAsBytesSync());
      await db.uploadId(discountId,_name.text,_idNumber.text,base64Image);
      Navigator.of(context).pop();
      successMessage();
    }
  }

  Future showDiscount() async{
    var res = await db.showDiscount();
    if (!mounted) return;
    setState(() {
      loadDiscount = res['user_details'];
      for (int i=0;i<loadDiscount.length;i++){
        _loadDiscount.add(loadDiscount[i]['discount_name']);
        _loadDiscountID.add(loadDiscount[i]['id']);
      }
    });
    print(loadDiscount);
    print(_loadDiscount);
    print(_loadDiscountID);
  }

  Future getDiscountID(name) async{
    var res = await db.getDiscountID(name);
    if (!mounted) return;
    setState(() {
      loadDiscountID = res['user_details'];
      print(loadDiscountID[0]['discount_id']);
      discountID = loadDiscountID[0]['discount_id'];
      print(discountID);
    });
  }

  loading(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          content: Container(
            height:50.0, // Change as per your requirement
            width: 10.0, // Change as per your requirement
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            ),
          ),
        );
      },
    );
  }

  successMessage(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
          title: Text(
            "Success!",
            style: TextStyle(fontSize: 18.0),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.fromLTRB(23.0, 0.0, 20.0, 0.0),
                  child:Text(("Discounted ID successfully added")),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.deepOrange,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
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
        title: Text("Upload new ID",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [

                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                    child: Text('Discount Type',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        //Add isDense true and zero Padding.
                        //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        //Add more decoration as you want here
                        //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                      ),
                      isExpanded: true,
                      hint: const Text(
                        'Select Discount Type', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black45,
                      ),
                      iconSize: 30,
                      items: _loadDiscount
                          .map((item) =>
                          DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ))
                          .toList(),
                      // ignore: missing_return
                      validator: (value) {
                        if (value == null) {
                          return 'Please select discount type!';
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                          id = _loadDiscount.indexOf(value);
                          print(id + 1);

                          getDiscountID(selectedValue);
                        });
                        //Do something when changing the item if you want.
                      },
                      onSaved: (value) {
                        selectedValue = value.toString();
                        print(selectedValue);
                      },
                    ),
                  ),

                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                      child: Text('Full Name',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                      controller: _name,
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
                        hintText: 'Full Name ex. (Lastname, Firstname)',
                        hintStyle: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some value!';
                        }
                        return null;
                      },
                    ),
                  ),

                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                      child: Text('ID. Picture',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child:InkWell(
                      onTap: (){
                        FocusScope.of(context).requestFocus(FocusNode());
                        camera();
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange.withOpacity(0.5),
                          controller: _imageTxt,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please capture an image!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'No File Choosen',
                            hintStyle: const TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 25.0),
                            prefixIcon: Icon(Icons.camera_alt_outlined,color: Colors.grey,),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.5),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                    child: Text('ID. Number',style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black54),)
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child:TextFormField(
                      cursorColor: Colors.deepOrange.withOpacity(0.8),
                      controller: _idNumber,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some value!';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'ID. Number',
                        hintStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 25.0),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: Colors.deepOrange.withOpacity(0.7),
                              width: 2.0),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
            child: Row(
              children: <Widget>[

                SizedBox(width: 2.0),

                Flexible(
                  child: SleekButton(
                    onTap: () async {
                      if (_formKey.currentState.validate()) {
                        uploadId();
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
                      child: Text("Save", style:TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 13.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
