import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'gcview_item.dart';

class GcSearch extends StatefulWidget {

  final bunitCode;
  GcSearch({Key key, @required this.bunitCode}) : super(key: key);
  @override
  _Search createState() => _Search();
}
class _Search extends State<GcSearch> {
  final db = RapidA();
  final search = TextEditingController();
  List searchProdData = [];
  bool searchLoading;
  bool load;

  Future searchProd() async {
    searchLoading = true;
    var res = await db.searchProdGc(search.text,unitGroupId, widget.bunitCode);
    if (!mounted) return;
    setState(() {
      load = false;
      searchLoading = false;
      searchProdData = res['user_details'];
    });
    print('mao ni ag unit group id');
    print(searchProdData);
  }

  @override
  void initState() {
    load = true;
    print('mao ni ag bunitCode');
    print(widget.bunitCode);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          // automaticallyImplyLeading: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.green[300], // Status bar
          ),
          backgroundColor: Colors.white,
          iconTheme: new IconThemeData(color: Colors.black),
          elevation: 0.0,
          title: Container(
            height: 40.0,
            child: CupertinoTextField(
              autofocus: true,
              style: TextStyle(fontSize: 15.0),
              keyboardType: TextInputType.text,
              controller: search,
              onChanged: (text) {
                searchProd();
                if(search.text.length <= 1){
                  setState(() {
                    load = true;
                  });
                }
              },
              prefix: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.search_sharp,color: Colors.black54,),
              ),
              suffix: Padding(
                padding: EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: (){
                    search.clear();
                    load = true;
                    setState(() {
                      searchProdData.clear();
                    });
                    print(load);
                  },
                  child: Icon(Icons.close_rounded,color: Colors.black54,),
                ),
              ),
              cursorColor: Colors.black54,
              placeholder: "Search here...",
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
              ),
              onPressed: (){
                FocusScope.of(context).requestFocus(FocusNode());
                searchProd();
              },
              child: Text("Search",style: TextStyle(color: Colors.black),)
            )
          ],
        ),
        body: Scrollbar(
          child: searchProdData.length !=0 || load == true ? ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: searchProdData == null ? 0 : searchProdData.length,
            itemBuilder: (BuildContext context, int index){
              return InkWell(
                onTap: (){
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).push(_gcVieItem(
                    searchProdData[index]['prod_id'],
                    searchProdData[index]['product_name'],
                    searchProdData[index]['image'],
                    searchProdData[index]['itemcode'],
                    searchProdData[index]['price'],
                    searchProdData[index]['uom'],
                    searchProdData[index]['uom_id'],
                    bUnitCodeGc)
                  );
                },
                child:Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                  child: Row(
                    children:[

                      Container(
                        width: 30.0,
                        height: 30.0,
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                            image: new NetworkImage(searchProdData[index]['image']),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                          border: new Border.all(
                            color: Colors.black54,
                            width: 0.5,
                          ),
                        ),
                      ),

                      SizedBox(width: 10.0),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(searchProdData[index]['product_name'],overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13.0,color: Colors.black54),),
                            // Text(searchProdData[index]['prod_bu']+ " - "+ searchProdData[index]['tenant_name'],style: TextStyle(fontSize: 10.0),)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
          ): Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Container(
                  height: 100,
                  width: 100,
                  child: SvgPicture.asset("assets/svg/file.svg"),
                ),

                Text("No Result Found",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 20.0),),
                Text("We can't find any item matching your search",style: TextStyle(color: Colors.black54,),),
              ],
            ),
          ),
        )
      ),
    );
  }
}

Route _gcVieItem(prodId,prodName,image,itemCode,price,uom,uomId,buCode){
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ViewItem(prodId:prodId,prodName:prodName,image:image,itemCode:itemCode,price:price,uom:uom,uomId:uomId,buCode:buCode),
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

//
// Route _viewItem(buCode, tenantCode, prodId,productUom,unitOfMeasure,price) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) =>
//         ViewItem(buCode: buCode, tenantCode: tenantCode, prodId: prodId,productUom:productUom,unitOfMeasure:unitOfMeasure,price:price),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       var begin = Offset(0.0, 1.0);
//       var end = Offset.zero;
//       var curve = Curves.decelerate;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }