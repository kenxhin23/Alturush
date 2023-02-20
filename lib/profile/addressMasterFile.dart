import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:arush/db_helper.dart';
import '../create_account_signin.dart';
import 'addNewAddress.dart';
import 'editAddress.dart';

class AddressMasterFile extends StatefulWidget {
  @override
  _AddressMasterFile createState() => _AddressMasterFile();
}

class _AddressMasterFile extends State<AddressMasterFile> {
  final db = RapidA();

  List loadAddressList;
  bool isLoading = true;
  bool exist = false;
  int shipping;
  // bool exist = true;

  Future loadAddress() async{
   var res = await db.loadAddress();
    if (!mounted) return;
    setState(() {

      loadAddressList = res['user_details'];
      isLoading = false;
      for(int q = 0;q<loadAddressList.length;q++) {
        if (loadAddressList[q]['shipping'] == '1') {
          shipping = q;
        }
      }
      if (loadAddressList.isNotEmpty) {
        print(loadAddressList[0]['d_townName']);
      }
    });
    print(res);
  }

  updateDefaultShipping(id,customerId) async{
    await db.updateDefaultShipping(id,customerId);
  }

  deleteAddress(id) async{
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          contentPadding: EdgeInsets.all(0),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: EdgeInsets.only(left: 10, top: 10),
                  child: Text('Hello!',style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 20))
              ),
              Divider(thickness: 1, color: Colors.deepOrangeAccent),
              SizedBox(height: 15,),
              SingleChildScrollView(
                child:Padding(
                    padding:EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: Text("Do you want to delete this address?",style: TextStyle(color: Colors.black54, fontWeight: FontWeight.normal, fontSize: 16))
                ),
              ),
              SizedBox(height: 15,),
            ],
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
                'Cancel',
                style: TextStyle(
                  color: Colors.deepOrangeAccent,
                ),
              ),
              onPressed: (){
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
                'Proceed',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async{
                Navigator.of(context).pop();
                await db.deleteAddress(id);
                loadAddress();
              },
            ),
          ],
        );
      },
    );
  }

  Future checkIfHasId() async{
    var res = await db.checkIfHasAddresses();
    if (!mounted) return;
    setState(() {
      if(res == 'true'){
        exist = true;
      }else{
        exist = false;
      }
    });
  }

  Future onRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }
    loadAddress();
    checkIfHasId();
  }

  @override
  void initState() {
    onRefresh();
    loadAddress();
    checkIfHasId();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrangeAccent[200], // Status bar
        ),
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Your Addresses",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 16.0),),
      ),
      body:isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
      ):
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Expanded(
            child:RefreshIndicator(
              color: Colors.deepOrangeAccent,
              onRefresh: onRefresh,
              child: Scrollbar(
                child: ListView(
                  children: [

                    if (exist == false) Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight / 3.0),
                        child: Center(
                          child:Column(
                            children: <Widget>[
                              Container(
                                height: 100,
                                width: 100,
                                child: SvgPicture.asset("assets/svg/inbox.svg"),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text("You have no addresses yet",style: TextStyle(fontSize: 19,),),
                            ],
                          ),
                        ),
                      ) else ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: loadAddressList == null ? 0 : loadAddressList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var q = index;
                        q++;
                        return InkWell(
                          onTap: () {

                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: RadioListTile(
                              visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity,
                              ),
                              contentPadding: EdgeInsets.all(0),
                              activeColor: Colors.deepOrange,
                              title: Transform.translate(
                                  offset: const Offset(-10, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Padding(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text('${loadAddressList[index]['firstname']} ${loadAddressList[index]['lastname']}',style: TextStyle(fontSize: 16, color: Colors.black),),
                                          ),

                                          Padding(
                                            padding: EdgeInsets.only(top: 5, bottom: 5, right: 5),
                                            child: Text('${loadAddressList[index]['street_purok']}, ${loadAddressList[index]['d_brgName']}, ${loadAddressList[index]['d_townName']}, '
                                              '${loadAddressList[index]['zipcode']}, ${loadAddressList[index]['d_province']}' , overflow: TextOverflow.ellipsis, maxLines: 5, style: TextStyle(fontSize: 14, color: Colors.black54),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    IntrinsicHeight(
                                      child: Row(
                                        children: [

                                          SizedBox(width: 20,
                                            child: RawMaterialButton(
                                              onPressed:
                                                  () async {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditAddress(idd: loadAddressList[index]['id'], cusId: loadAddressList[index]['d_customerId'])),
                                                );
                                              },
                                              elevation: 1.0,
                                              child:
                                              Icon(CupertinoIcons.pencil, size: 20.0, color: Colors.blueAccent,
                                              ),
                                              shape:
                                              CircleBorder(),
                                            )
                                          ),

                                          VerticalDivider(thickness: 1, color: Colors.black54),

                                          Padding(
                                            padding: EdgeInsets.only(right: 0),
                                            child: SizedBox(width: 20,
                                              child: RawMaterialButton(
                                                onPressed:
                                                    () async {
                                                  deleteAddress(loadAddressList[index]['id']);
                                                },
                                                elevation: 1.0,
                                                child:
                                                Icon(
                                                  CupertinoIcons.delete, size: 20.0,
                                                  color: Colors.redAccent,
                                                ),
                                                shape:
                                                CircleBorder(),
                                              )
                                            ),
                                          )
                                        ],
                                      )
                                    )
                                  ],
                                ),
                              ),
                              value: index,
                              groupValue: shipping,
                              onChanged: (newValue) {
                                setState((){
                                  shipping = newValue;
                                  print(loadAddressList[index]['id']);
                                  print(loadAddressList[index]['d_customerId']);
                                  updateDefaultShipping(loadAddressList[index]['id'], loadAddressList[index]['d_customerId']);
                                });
                              },
                            ),
                          ),
                          // This will show up when the user performs dismissal action
                            // It is a red background and a trash icon
                          //   background: Container(
                          //       decoration: BoxDecoration(
                          //           color: Colors.red,
                          //           borderRadius: BorderRadius.all(Radius.circular(5))
                          //       ),
                          //       margin: const EdgeInsets.symmetric(horizontal: 10),
                          //       alignment: Alignment.centerRight,
                          //       child: Padding(
                          //         padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                          //         child: const Icon(
                          //           Icons.delete,
                          //           color: Colors.white,
                          //         ),)
                          //
                          //   ),
                          // )
                        );
                        // return InkWell(
                        //   onTap: (){
                        //
                        //   },
                        //   child: Padding(padding:EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                        //     child: Padding(padding:EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                        //       child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: <Widget>[
                        //           Padding(padding:EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
                        //             child:Column(crossAxisAlignment: CrossAxisAlignment.start,
                        //               children: [
                        //                 Text('$q. ${loadIdList[index]['firstname']} ${loadIdList[index]['lastname']}',style: TextStyle(fontSize: 20,),),
                        //                 Text('    ${loadIdList[index]['d_townName']}, ${loadIdList[index]['d_brgName']}',style: TextStyle(fontSize: 20,),),
                        //                 Text('    ${loadIdList[index]['street_purok']}',style: TextStyle(fontSize: 20,),),
                        //                 Text('    ${loadIdList[index]['d_contact']}',style: TextStyle(fontSize: 20,),),
                        //
                        //                 ButtonBar(
                        //                   children: <Widget>[
                        //                     OutlineButton(
                        //                       child: Stack(
                        //                       children: <Widget>[
                        //                           Align(alignment: Alignment.bottomRight, child: Icon(Icons.delete_outline_outlined,color: Colors.black)
                        //                           )
                        //                         ],
                        //                       ),
                        //                       highlightedBorderColor: Colors.black,
                        //                       highlightColor: Colors.transparent,
                        //                       shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        //                       onPressed: () {
                        //                         deleteAddress(loadIdList[index]['id']);
                        //                       },
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //           // ButtonBar(
                        //           //   children: <Widget>[
                        //           //     // OutlineButton(
                        //           //     //   highlightedBorderColor: Colors.black,
                        //           //     //   highlightColor: Colors.transparent,
                        //           //     //   shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        //           //     //   child: Icon(Icons.edit_outlined,color: Colors.black,),
                        //           //     //   onPressed: () {
                        //           //     //
                        //           //     //   },
                        //           //     // ),
                        //           //     OutlineButton(
                        //           //       child: Stack(
                        //           //         children: <Widget>[
                        //           //           Align(
                        //           //             alignment: Alignment.topRight,
                        //           //               child: Icon(Icons.delete_outline_outlined,color: Colors.black)
                        //           //           )
                        //           //         ],
                        //           //       ),
                        //           //       highlightedBorderColor: Colors.black,
                        //           //       highlightColor: Colors.transparent,
                        //           //       shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                        //           //       onPressed: () {
                        //           //          deleteAddress(loadIdList[index]['id']);
                        //           //       },
                        //           //     ),
                        //           //   ],
                        //           // ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Row(children: <Widget>[

              SizedBox(width: 2.0,
              ),

                Flexible(child: SleekButton(
                  onTap: () async {
                      await Navigator.of(context).push(addNewAddress());
                      loadAddress();
                      checkIfHasId();
                    },
                    style: SleekButtonStyle.flat(
                      color: Colors.deepOrange,
                      inverted: false,
                      rounded: true,
                      size: SleekButtonSize.big,
                      context: context,
                    ),
                    child: Center(
                      child: Text("ADD ADDRESS", style:TextStyle(fontStyle: FontStyle.normal,fontSize: 18.0, fontWeight: FontWeight.bold),
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

Route addNewAddress() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AddNewAddress(),
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

Route editAddress() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EditAddress(),
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
