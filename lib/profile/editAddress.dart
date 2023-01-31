import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../create_account_signin.dart';
import '../db_helper.dart';

class EditAddress extends StatefulWidget {
  final idd;
  final cusId;

  const EditAddress({this.idd, this.cusId});

  @override
  _EditAddress createState() => _EditAddress();
}

class _EditAddress extends State<EditAddress> {
  final db = RapidA();
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final firstName =  TextEditingController();
  final lastName =  TextEditingController();
  final mobileNum =  TextEditingController();
  final province = TextEditingController();
  final town = TextEditingController();
  final barangay = TextEditingController();
  final buildingType = TextEditingController();
  final houseUnit =  TextEditingController();
  final streetPurok=  TextEditingController();
  final landMark =  TextEditingController();
  final otherNotes =  TextEditingController();
  final zipcode= TextEditingController();

  List<String> _options = ['Home', 'Office'];
  List getProvinceData;
  List getTownData;
  List getBarangayData;
  List getBuildingData;
  List addresses;
  String addressType;
  String addType;
  String hint;
  int provinceId;
  int townID;
  int barangayID;
  int buildingID;
  int option;


  // selectBuildingType() async{
  //   var res = await db.selectBuildingType();
  //   if (!mounted) return;
  //   setState(() {
  //     getBuildingData = res['user_details'];
  //   });
  //   FocusScope.of(context).requestFocus(FocusNode());
  //   showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(8.0))
  //         ),
  //         contentPadding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
  //         title: Text('Building type',),
  //         content: Container(
  //           height: 90.0,
  //           width: 300.0,
  //           child: Scrollbar(
  //             child: ListView.builder(
  //               physics: BouncingScrollPhysics(),
  //               shrinkWrap: true,
  //               itemCount: getBuildingData == null ? 0 : getBuildingData.length,
  //               itemBuilder: (BuildContext context, int index) {
  //                 return InkWell(
  //                   onTap:(){
  //                     buildingType.text = getBuildingData[index]['buildingName'];
  //                     buildingID = int.parse(getBuildingData[index]['buildingID']);
  //                     print(getBuildingData[index]['buildingID']);
  //
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: ListTile(
  //                     title: Text(getBuildingData[index]['buildingName']),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text(
  //               'Close',
  //               style: TextStyle(
  //                 color: Colors.grey.withOpacity(0.8),
  //               ),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text(
  //               'Clear',
  //               style: TextStyle(
  //                 color: Colors.grey.withOpacity(0.8),
  //               ),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               buildingType.clear();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  // }

  selectProvince() async{
    var res = await db.getProvince();
    if (!mounted) return;
    setState(() {
      getProvinceData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());

    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                ),
                contentPadding: EdgeInsets.all(0),
                content: Container(
                  height: 130.0,
                  width: 300.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Padding(padding: EdgeInsets.only(left: 10, top: 10),
                          child: Text('Select Province',style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 18))
                      ),

                      Divider(thickness: 1, color: Colors.deepOrangeAccent),

                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            padding: EdgeInsets.all(0),
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: getProvinceData == null ? 0 : getProvinceData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap:(){
                                  province.text = getProvinceData[index]['prov_name'];
                                  provinceId = int.parse(getProvinceData[index]['prov_id']);
                                  town.clear();
                                  barangay.clear();
                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: SizedBox(height: 30,
                                        child: ListTile(
                                          title: Text(getProvinceData[index]['prov_name']),
                                        ),
                                      )
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ]
                  ),
                ),
                actions: <Widget>[

                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.deepOrangeAccent)
                        )
                      )
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),

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
                      'Clear',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      province.clear();
                      town.clear();
                      barangay.clear();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
    // showDialog<void>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(8.0))
    //       ),
    //       contentPadding: EdgeInsets.all(0),
    //       content: Container(
    //         height: 130.0,
    //         width: 300.0,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Padding(padding: EdgeInsets.only(left: 10, top: 10),
    //                 child: Text('Select Province',style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 18))
    //             ),
    //             Divider(thickness: 1, color: Colors.deepOrangeAccent),
    //             Expanded(
    //               child: Scrollbar(
    //                 child: ListView.builder(
    //                   physics: BouncingScrollPhysics(),
    //                   shrinkWrap: true,
    //                   itemCount: getProvinceData == null ? 0 : getProvinceData.length,
    //                   itemBuilder: (BuildContext context, int index) {
    //                     return InkWell(
    //                       onTap:(){
    //                         province.text = getProvinceData[index]['prov_name'];
    //                         provinceId = int.parse(getProvinceData[index]['prov_id']);
    //                         town.clear();
    //                         barangay.clear();
    //                         Navigator.of(context).pop();
    //                       },
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Padding(
    //                               padding: EdgeInsets.only(bottom: 10),
    //                               child: SizedBox(height: 30,
    //                                 child: ListTile(
    //                                   title: Text(getProvinceData[index]['prov_name']),
    //                                 ),
    //                               )
    //                           )
    //                         ],
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               ),
    //             )
    //           ]
    //         ),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           style: ButtonStyle(
    //             backgroundColor: MaterialStateProperty.all(Colors.transparent),
    //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //               RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(20.0),
    //                 side: BorderSide(color: Colors.deepOrangeAccent)
    //               )
    //             )
    //           ),
    //           child: Text(
    //             'Close',
    //             style: TextStyle(
    //               color: Colors.deepOrangeAccent,
    //             ),
    //           ),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //         TextButton(
    //           style: ButtonStyle(
    //             backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
    //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //               RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(20.0),
    //                 side: BorderSide(color: Colors.deepOrangeAccent)
    //               )
    //             )
    //           ),
    //           child: Text(
    //             'Clear',
    //             style: TextStyle(
    //               color: Colors.white,
    //             ),
    //           ),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //             province.clear();
    //             town.clear();
    //             barangay.clear();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  selectTown() async{
    var res = await db.selectTown(provinceId.toString());
    if (!mounted) return;
    setState(() {

      getTownData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());

    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                ),
                contentPadding: EdgeInsets.all(0),
                content: Container(
                  height: 300.0,
                  width: 300.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Padding(padding: EdgeInsets.only(left: 10, top: 10),
                          child: Text('Select Town',style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 18))
                      ),

                      Divider(thickness: 1, color: Colors.deepOrangeAccent),

                      Expanded(
                        child: Scrollbar(
                          child: Padding(
                            padding: EdgeInsets.all(0),
                            child: ListView.builder(
                              padding: EdgeInsets.all(0),
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: getTownData == null ? 0 : getTownData.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap:(){
                                    town.text = getTownData[index]['town_name'];
                                    townID = int.parse(getTownData[index]['town_id']);
                                    zipcode.text = (getTownData[index]['zipcode']);
                                    barangay.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: SizedBox(height: 30,
                                          child: ListTile(
                                            title: Text(getTownData[index]['town_name']),
                                          ),
                                        )
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[

                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.deepOrangeAccent)
                        )
                      )
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),

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
                      'Clear',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      town.clear();
                      barangay.clear();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});


    // showDialog<void>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(8.0))
    //       ),
    //       contentPadding: EdgeInsets.all(0),
    //       content: Container(
    //         height: 300.0,
    //         width: 300.0,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Padding(padding: EdgeInsets.only(left: 10, top: 10),
    //                 child: Text('Select Town',style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 18))
    //             ),
    //             Divider(thickness: 1, color: Colors.deepOrangeAccent),
    //             Expanded(
    //               child: Scrollbar(
    //                 child: Padding(
    //                   padding: EdgeInsets.all(0),
    //                   child: ListView.builder(
    //                     physics: BouncingScrollPhysics(),
    //                     shrinkWrap: true,
    //                     itemCount: getTownData == null ? 0 : getTownData.length,
    //                     itemBuilder: (BuildContext context, int index) {
    //                       return InkWell(
    //                         onTap:(){
    //                           town.text = getTownData[index]['town_name'];
    //                           townID = int.parse(getTownData[index]['town_id']);
    //                           zipcode.text = (getTownData[index]['zipcode']);
    //                           barangay.clear();
    //                           Navigator.of(context).pop();
    //                         },
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Padding(
    //                                 padding: EdgeInsets.only(bottom: 10),
    //                                 child: SizedBox(height: 30,
    //                                   child: ListTile(
    //                                     title: Text(getTownData[index]['town_name']),
    //                                   ),
    //                                 )
    //                             )
    //                           ],
    //                         ),
    //                       );
    //                     },
    //                   ),
    //                 )
    //               ),
    //             ),
    //           ],
    //         ),
    //
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           style: ButtonStyle(
    //             backgroundColor: MaterialStateProperty.all(Colors.transparent),
    //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //               RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(20.0),
    //                 side: BorderSide(color: Colors.deepOrangeAccent)
    //               )
    //             )
    //           ),
    //           child: Text(
    //             'Close',
    //             style: TextStyle(
    //               color: Colors.deepOrangeAccent,
    //             ),
    //           ),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //         TextButton(
    //           style: ButtonStyle(
    //             backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
    //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //               RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(20.0),
    //                   side: BorderSide(color: Colors.deepOrangeAccent)
    //               )
    //             )
    //           ),
    //           child: Text(
    //             'Clear',
    //             style: TextStyle(
    //               color: Colors.white,
    //             ),
    //           ),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //             town.clear();
    //             barangay.clear();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  selectBarangay() async{
    var res = await db.selectBarangay(townID.toString());
    if (!mounted) return;
    setState(() {

      getBarangayData = res['user_details'];
    });
    FocusScope.of(context).requestFocus(FocusNode());

    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                ),
                contentPadding: EdgeInsets.all(0),
                content: Container(
                  height: 300.0,
                  width: 300.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Padding(padding: EdgeInsets.only(left: 10, top: 10),
                          child: Text('Select Barangay',style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 18))
                      ),

                      Divider(thickness: 1, color: Colors.deepOrangeAccent),


                      Expanded(
                        child: Scrollbar(
                          child:ListView.builder(
                            padding: EdgeInsets.all(0),
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: getBarangayData == null ? 0 : getBarangayData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap:(){
                                  barangay.text = getBarangayData[index]['brgy_name'];
                                  barangayID = int.parse(getBarangayData[index]['brgy_id']);

                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: SizedBox(height: 30,
                                        child: ListTile(
                                          title: Text(getBarangayData[index]['brgy_name']),
                                        ),
                                      )
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ]
                  )
                ),
                actions: <Widget>[

                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.deepOrangeAccent)
                        )
                      )
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),

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
                      'Clear',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      barangay.clear();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
    // showDialog<void>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(8.0))
    //       ),
    //       contentPadding: EdgeInsets.all(0),
    //       content: Container(
    //         height: 300.0,
    //         width: 300.0,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Padding(padding: EdgeInsets.only(left: 10, top: 10),
    //                 child: Text('Select Barangay',style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 18))
    //             ),
    //             Divider(thickness: 1, color: Colors.deepOrangeAccent),
    //             Expanded(
    //               child: Scrollbar(
    //                 child:ListView.builder(
    //                   physics: BouncingScrollPhysics(),
    //                   shrinkWrap: true,
    //                   itemCount: getBarangayData == null ? 0 : getBarangayData.length,
    //                   itemBuilder: (BuildContext context, int index) {
    //                     return InkWell(
    //                       onTap:(){
    //                         barangay.text = getBarangayData[index]['brgy_name'];
    //                         barangayID = int.parse(getBarangayData[index]['brgy_id']);
    //
    //                         Navigator.of(context).pop();
    //                       },
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Padding(
    //                               padding: EdgeInsets.only(bottom: 10),
    //                               child: SizedBox(height: 30,
    //                                 child: ListTile(
    //                                   title: Text(getBarangayData[index]['brgy_name']),
    //                                 ),
    //                               )
    //                           )
    //                         ],
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               ),
    //             )
    //           ]
    //         )
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           style: ButtonStyle(
    //             backgroundColor: MaterialStateProperty.all(Colors.transparent),
    //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //               RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(20.0),
    //                 side: BorderSide(color: Colors.deepOrangeAccent)
    //               )
    //             )
    //           ),
    //           child: Text(
    //             'Close',
    //             style: TextStyle(
    //               color: Colors.deepOrangeAccent,
    //             ),
    //           ),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //         TextButton(
    //           style: ButtonStyle(
    //             backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
    //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //               RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(20.0),
    //                 side: BorderSide(color: Colors.deepOrangeAccent)
    //               )
    //             )
    //           ),
    //           child: Text(
    //             'Clear',
    //             style: TextStyle(
    //               color: Colors.white,
    //             ),
    //           ),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //             barangay.clear();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  Future updateNewAddress() async{
    await db.updateNewAddress(
      widget.idd,
      firstName.text,
      lastName.text,
      mobileNum.text,
      houseUnit.text,
      streetPurok.text,
      landMark.text,
      otherNotes.text,
      barangayID,
      addressType);
    successMessage();
  }

  String towns;
  var index = 0;
  Future loadAddress() async{
    var res = await db.loadAddresses(widget.idd, widget.cusId);
    if (!mounted) return;
    setState(() {
      addresses = res['user_details'];

      firstName.text = addresses[index]['firstname'];
      lastName.text = addresses[index]['lastname'];
      mobileNum.text = addresses[index]['d_contact'];
      province.text = addresses[index]['d_province'];
      provinceId = int.parse(addresses[index]['d_province_id']);
      town.text = addresses[index]['d_townName'];
      townID = int.parse(addresses[index]['d_townId']);
      barangay.text = addresses[index]['d_brgName'];
      barangayID = int.parse(addresses[index]['d_brgId']);
      zipcode.text = addresses[index]['zipcode'];
      addressType = addresses[index]['add_type'];
      streetPurok.text = addresses[index]['street_purok'];
      houseUnit.text = addresses[index]['complete_add'];
      landMark.text = addresses[index]['land_mark'];
      otherNotes.text = addresses[index]['other_notes'];

      hint = addressType;
      print(addressType);
      isLoading = false;
    });
  }

  successMessage(){
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: "Billing Address Successfully Updated",
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
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  void initState() {
    loadAddress();
    addressType = hint;
    print(addressType);
    print(widget.idd);
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
        title: Text("Update Address",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0),),
      ),
      body: isLoading
      ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ):Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Expanded(
            child: Form(
              key: _formKey,
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("Firstname",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold)
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child:TextFormField(
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
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("Lastname",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child:TextFormField(
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
                              borderSide: BorderSide(
                                  color: Colors.deepOrange
                                      .withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("Mobile number",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child:TextFormField(
                          maxLength: 11,
                          keyboardType: TextInputType.number,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: mobileNum,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            if (value.length != 11 || mobileNum.text[0]!='0' ||  mobileNum.text[1]!='9') {
                              return 'Please enter valid phone number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            hintText: "Ex.(09506122842)",
                            hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 0, 5, 5),
                        child: new Text("Other Notes",
                          style: TextStyle(fontStyle: FontStyle.normal,fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child: new TextFormField(
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange,
                          controller: otherNotes,
                          maxLines: 4,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                            focusedBorder:OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("Province",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child: GestureDetector(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            selectProvince();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: province,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some value';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                  hintText: "Select Province",
                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("City/Municipality",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child: GestureDetector(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            if(province.text.isEmpty){
                              Fluttertoast.showToast(
                                  msg: "Please select a province",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.black.withOpacity(0.7),
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }else{
                              selectTown();

                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: town,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some value';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                  hintText: 'City/Municipality',
                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(250),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("Zipcode",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child: Container(
                          color: Colors.transparent,
                          child: IgnorePointer(
                            child: TextFormField(
                              cursorColor: Colors.deepOrange.withOpacity(0.8),
                              controller: zipcode,
                              enabled: false,
                              decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide(
                                      color: Colors.deepOrange.withOpacity(0.8),
                                      width: 2.0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(250),),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("Barangay",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child:GestureDetector(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            if(town.text.isEmpty){
                              Fluttertoast.showToast(
                                  msg: "Please select a town",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.black.withOpacity(0.7),
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }else{
                              selectBarangay();
                            }

                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.deepOrange.withOpacity(0.8),
                                controller: barangay,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some value';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                                  hintText: "Select Barangay",
                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepOrange.withOpacity(0.8),
                                        width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("House/Unit #, Bldg Name, Blk or Lot #.",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child:TextFormField(
                          textCapitalization: TextCapitalization.words,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: houseUnit,
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("Street/Road Name",
                          style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child:TextFormField(
                          textCapitalization: TextCapitalization.words,
                          cursorColor: Colors.deepOrange.withOpacity(0.8),
                          controller: streetPurok,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            return null;
                          },
                          decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(
                                  color: Colors.deepOrange.withOpacity(0.8),
                                  width: 2.0),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("Nearest Land Mark",
                          style: TextStyle(fontStyle: FontStyle.normal,fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold)
                        ),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        child: new TextFormField(
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          cursorColor: Colors.deepOrange,
                          controller: landMark,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some value';
                            }
                            return null;
                          },
                          maxLines: 4,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 25.0),
                            focusedBorder:OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(35, 10, 5, 0),
                        child: new Text("Select a label of your address",
                          style: TextStyle(fontStyle: FontStyle.normal,fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold)
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 10, top: 10, bottom: 10),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            //Add isDense true and zero Padding.
                            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                            // isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            //Add more decoration as you want here
                            //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                          ),
                          isExpanded: true,
                          hint: Padding(
                            padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                            child: Text('$hint',
                                style: TextStyle(fontStyle: FontStyle.normal,fontSize: 15.0, fontWeight: FontWeight.normal, color: Colors.black)
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 30,
                          items: _options
                              .map((item) =>
                              DropdownMenuItem<String>(
                                  value: item,
                                  child: Container(
                                    width: 100,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(item,
                                      style: TextStyle(fontStyle: FontStyle.normal, fontSize: 15.0, fontWeight: FontWeight.normal, color: Colors.black),
                                    ),
                                  )
                              )
                          ).toList(),
                          // ignore: missing_return
                          onChanged: (value) {
                            addressType = value;
                            setState(() {
                              addressType = value;
                              // option = _options.indexOf(value)+1;
                              print(addressType);
                            });
                            //Do something when changing the item if you want.
                          },
                          onSaved: (value) {
                            addressType = value.toString();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
                    onTap: () async {
                      if(_formKey.currentState.validate()) {
                        updateNewAddress();
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.paperplane),
                          Text("SUBMIT",
                            style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ],
                      )
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
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