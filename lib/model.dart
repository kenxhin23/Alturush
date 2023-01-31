import 'dart:async';
import 'db_helper.dart';

class Model{
  final db = RapidA();
  // Future getLastOrder() async{
  //     var res =  await db.getLastOrder();
  //     List list = res['user_details'];
  //     return list;
  // }

  Future getLastItems(orderNo) async{
    var res = await db.getLastItems(orderNo);
    List list = res['user_details'];
    return list;
  }
}