import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import '../db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../create_account_signin.dart';
import 'package:intl/intl.dart';
import 'gc_search.dart';

class ViewItem extends StatefulWidget {
  final prodId;
  final prodName;
  final image;
  final itemCode;
  final price;
  final uom;
  final uomId;
  final buCode;

  ViewItem({Key key, @required this.prodId, this.prodName,this.image,this.itemCode,this.price,this.uom,this.uomId,this.buCode}) : super(key: key);
  @override
  _ViewItem createState() => _ViewItem();
}

class _ViewItem extends State<ViewItem>  {
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final itemCount = TextEditingController();

  int _counter = 1;
  List getUomList;

  var imageLoading = true;
  var priceTemp;
  var uomTemp;
  var isLoading = true;
//  bool _isLogged = false;

  int uomDataGroupValue;
  double price;
  String uom;
  String uomID;
  String uomPrice;

  Future getUom() async{
    var res = await db.getUom(widget.itemCode);
    if (!mounted) return;
    setState(() {
      getUomList = res['user_details'];
      for(int i=0;i<getUomList.length;i++){
        price = double.parse(getUomList[i]['price_with_vat']);
        if (price == oCcy.parse(widget.price)){
          uomID = getUomList[i]['uom_id'];
          uom = getUomList[i]['UOM'];
          uomDataGroupValue = i;
          print(uomID);
          print(uom);
        }
        // print(price);
        // print(widget.price);
      }
      // print(getUomList);
      isLoading = false;
    });
  }

  Future addToCart() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    } else {

      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Successfully added to Cart",
        confirmBtnColor: Colors.green,
        backgroundColor: Colors.green,
        barrierDismissible: false,
        onConfirmBtnTap: () async {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
      await db.addToCartGc(
        widget.buCode,
        widget.prodId,
        widget.itemCode,
        uom,
        uomID,
        _counter
      );
    }
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      itemCount.text = _counter.toString();
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _incrementCounter(){
    setState((){
      _counter++;
      itemCount.text = _counter.toString();
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Future onRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    }
  }


  @override
  void initState(){
    onRefresh();
    isLoading = false;
    imageLoading = false;
    getUom();
    super.initState();
    uomTemp =  widget.uom;
    priceTemp = widget.price;
    // print(uomTemp);
    // print(widget.uomId);
  }

  @override
  void dispose(){
    super.dispose();
    itemCount.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.green[300], // Status bar
          ),
          backgroundColor: Colors.white,
          elevation: 0.1,
          iconTheme: new IconThemeData(color: Colors.black),
          title: Text("Product Detail(s)",style: GoogleFonts.openSans(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 18.0),),
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search_outlined, color: Colors.black),
              onPressed: () async {
                Navigator.of(context).push(_search());
              }
            ),
          ],
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) : Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            Expanded(
              child: Scrollbar(
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children:[

                    ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:[



                              Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 5),
                                child: CachedNetworkImage(
                                  imageUrl: widget.image,
                                  imageBuilder: (context, imageProvider) => Container(
                                    height: 190,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => const CircularProgressIndicator(color: Colors.green,),
                                  errorWidget: (context, url, error) => Container(
                                    height: 190,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: AssetImage("assets/png/No_image_available.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // imageLoading
                              //     ? Padding(
                              //       padding:EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 60.0),
                              //       child: Center(
                              //   child: CircularProgressIndicator(
                              //       valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                              //      ),
                              //     ),
                              //   ) : Center(
                              //   child: Image.network(widget.image,height: 250.0,scale:1.8),
                              // ),
                              // Padding(
                              //   padding:EdgeInsets.fromLTRB(20.0, 10.0, 5.0, 5.0),
                              //   child: Row(
                              //     children:[
                              //       Text("Price:",style: TextStyle(fontSize: 17,color: Colors.black,),),
                              //       SizedBox(width: 10.0),
                              //       Text('₱ ${priceTemp.toString()}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.deepOrange,),),
                              //     ],
                              //   ),
                              // ),
                              // Padding(
                              //   padding:EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0),
                              //   child: Row(
                              //     children:[
                              //       Text("UOM:",style: TextStyle(fontSize: 17,color: Colors.black,),),
                              //       SizedBox(width: 10.0),
                              //       Text(uomTemp, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                              //     ],
                              //   ),
                              // ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                child: new Text(widget.prodName.toString(), style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0), textAlign: TextAlign.center,),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 5.0),
                                child: new Text("Select Unit of Measure", style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 14.0),),
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: getUomList == null ? 0 : getUomList.length,
                                // gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                                // crossAxisCount: 5,
                                // childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 2),
                                // ),
                                itemBuilder: (BuildContext context, int index) {
                                   return
                                     Column(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: [
                                       Row(
                                         children: [

                                           Flexible(
                                             fit: FlexFit.loose,
                                             child: SizedBox(height: 35,
                                              child: RadioListTile(
                                                visualDensity: const VisualDensity(
                                                  horizontal: VisualDensity.minimumDensity,
                                                  vertical: VisualDensity.minimumDensity,
                                                ),
                                                contentPadding: EdgeInsets.all(0),
                                                activeColor: Colors.green,
                                                title:  Transform.translate(
                                                  offset: const Offset(-10, 0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text('${getUomList[index]['UOM']}', overflow: TextOverflow.ellipsis, style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                      ),
                                                      Text('₱ ${getUomList[index]['price_with_vat']}', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13))
                                                    ],
                                                  ),
                                                ),
                                                value: index,
                                                groupValue: uomDataGroupValue,
                                                onChanged: (newValue) {

                                                  setState((){
                                                    uomDataGroupValue = newValue;
                                                    uomID = getUomList[index]['uom_id'];
                                                    uom = getUomList[index]['UOM'];
                                                    uomPrice = getUomList[index]['price_with_vat'];

                                                  });

                                                  print(uomID);
                                                  print(uom);
                                                  print(uomPrice);
                                                },
                                              ),
                                             ),
                                           ),
                                         ],
                                       )
                                     ],
                                   );
                                  }
                                ),
                              ),
                           ],
                         );
                       }
                     ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  TextButton(
                    onPressed: _counter == 1 ? null : _decrementCounter,
                    child: new Text('-',style: TextStyle(fontSize: 20,color: Colors.green,),),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  ),

                  Text(_counter.toString()),

                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  ),

                  TextButton(
                    onPressed: _counter == 999 ? null : _incrementCounter,
                    child: new Text('+',style: TextStyle(fontSize: 20,color: Colors.green,),),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                  ),

                  Flexible(
                    child: SleekButton(
                      onTap: () async{
                       addToCart();
                      },
                      style: SleekButtonStyle.flat(
                        color: Colors.green,
                        inverted: false,
                        rounded: true,
                        size: SleekButtonSize.big,
                        context: context,
                      ),
                      child: Center(
                        child:Text("ADD TO CART", style: TextStyle(
                          shadows: [
                            Shadow(
                              blurRadius: 1.0,
                              color: Colors.black54,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
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

Route _search() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GcSearch(),
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