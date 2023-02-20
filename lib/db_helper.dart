import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';

List loadIdList;
List<bool> side = [];
List<bool> side1 = [];
List<bool> side2 = [];
List<bool> side3 = [];
List<String> selectedDiscountType = [];
int unitGroupId;
String bUnitCodeGc;
class RapidA {
  static final RapidA _instance = RapidA._();
  RapidA._();

  factory RapidA() {
    return _instance;
  }

  // String server = "https://app1.alturush.com/";
  String server = "http://172.16.43.147/rapida";
  // String server = "http://10.233.1.58/rapida/";
  // String server = "http://172.16.46.130/rapida";
  // String server = "http://192.168.1.2:3333/rapida";
  // String server = "http://203.177.223.59:8006/";

  final key = Key.fromUtf8('SoAxVBnw8PYHzHHTFBQdG0MFCLNdmGFf'); //32 chars
  final iv = IV.fromUtf8('T1g994xo2UAqG81M'); //16 chars

  //mysql query code

  String encrypt(String string) {
    final encrypt = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypt.encrypt(string, iv: iv);
    return encrypted.base64;
  }

  Future loadCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadCartDataNew_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadCartData2(productID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/loadCartDataNew2_r"),body:{
      'cusId'     : encrypt(userID),
      'productID' : encrypt(productID.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  //new
  // firstName.text,
  // lastName.text,
  // email.text,
  // birthday.text,
  // contactNumber.text);
  // username.text,
  // password.text,
  Future createAccountSample(firstName, lastName, email, birthday, contactNumber, username, password) async {
    var client = http.Client();
    // if(suffix.toString().isEmpty){
    //   suffix = suffix;
    // }else{
    //   suffix = encrypt(suffix);
    // }
    await client.post(Uri.parse("$server/createUser_r"),body:{
      // 'townId':encrypt(townId),
      // 'barrioId':encrypt(barrioId),
      'firstName'    : encrypt(firstName),
      'lastName'     : encrypt(lastName),
      'email'        : encrypt(email),
      'birthday'     : encrypt(birthday),
      'contactNumber': encrypt(contactNumber),
      'username'     : encrypt(username),
      'password'     : encrypt(password)
    });
    client.close();
  }

  Future checkLogin(_usernameLogIn,_passwordLogIn) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkLogin_r"),body:{
      '_usernameLogIn' : encrypt(_usernameLogIn),
      '_passwordLogIn' : encrypt(_passwordLogIn)
    });
    print(_usernameLogIn);
    client.close();
    return response.body;

  }

  Future getUserData(id) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getUserData_r"),body:{
      'id' : encrypt(id)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getPlaceOrderData() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getPlaceOrderData_r"),body:{
      'cusId' : encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future checkAllowedPlace() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await client.post(Uri.parse("$server/checkAllowedPlace_r"),body:{
      'townId' : encrypt(prefs.getString('s_townId')),
    });
    client.close();
    return response.body;
  }

  Future checkFee() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await client.post(Uri.parse("$server/checkFee_r"),body:{
      'townId' : encrypt(prefs.getString('s_townId')),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getMobileNumber() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getMobileNumber_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getAppUsers() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getAppUser_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getOrderData() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getOrderData_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getSubTotal() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getSubtotal_r"),body:{
      'customerId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future placeOrder(
      deliveryDateData,
      deliveryTimeData,
      getTenantData,
      specialInstruction,
      deliveryCharge,
      amountTender,
      productID
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    var client = http.Client();
    await client.post(Uri.parse("$server/placeOrder_r"),body:{
      'cusId'               : encrypt(userID),
      'deliveryDateData'    : encrypt(deliveryDateData.toString()),
      'deliveryTimeData'    : encrypt(deliveryTimeData.toString()),
      'selectedDiscountType': encrypt(selectedDiscountType.toString()),
      'deliveryCharge'      : encrypt(deliveryCharge.toString()),
      'amountTender'        : encrypt(amountTender.toString()),
      'specialInstruction'  : encrypt(specialInstruction.toString()),
      'getTenantData'       : encrypt(getTenantData.toString()),
      'productID'           : encrypt(productID.toString())
    });
    client.close();
  }

  Future placeOrder2(
      deliveryDateData,
      deliveryTimeData,
      getTenantData,
      specialInstruction,
      deliveryCharge,
      amountTender,
      productID
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    var client = http.Client();
    await client.post(Uri.parse("$server/placeOrder_r2"),body:{
      'cusId'                : encrypt(userID),
      'deliveryDateData'     : encrypt(deliveryDateData.toString()),
      'deliveryTimeData'     : encrypt(deliveryTimeData.toString()),
      'selectedDiscountType' : encrypt(selectedDiscountType.toString()),
      'deliveryCharge'       : encrypt(deliveryCharge.toString()),
      'amountTender'         : encrypt(amountTender.toString()),
      'specialInstruction'   : encrypt(specialInstruction.toString()),
      'getTenantData'        : encrypt(getTenantData.toString()),
      'productID'            : encrypt(productID.toString())
    });
    client.close();
  }

  // Future getLastOrder() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   Map dataUser;
  //   final response = await http.post("$server/getLastOrderId_r",body:{
  //     'cusId':prefs.getString('s_customerId'),
  //   });
  //   dataUser = jsonDecode(response.body);
  //   return dataUser;
  // }

  Future getLastItems(orderNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getLastItems_r"),body:{
      'orderNo' : encrypt(orderNo),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getAllowedLoc() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getAllowedLoc_r"),body:{
      'd':'d',
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getBuGroupID() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getBuGroupID_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future gcGetAddress() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/gcGetAddress_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future gcLoadBu() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/gcLoadBu_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future gcLoadBu2(tempID) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/gcLoadBu2_r"),body:{
      'cusId' : encrypt(userID),
      'tempID' : encrypt(tempID.toString()),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getBuSegregate() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getBu_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getBuSegregate1() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getBu_r1"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getBuSegregate2(productID) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getBu_r2"),body:{
      'cusId'     : encrypt(userID),
      'productID' : encrypt(productID.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future displayOrder(tenantId) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/displayOrder_r"),body:{
      'cusId'   : encrypt(userID),
      'tenantId': encrypt(tenantId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getDiscountID(discountName) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getDiscountID_r"),body:{
      'cusId'       : encrypt(userID),
      'discountName': encrypt(discountName)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future displayAddOns(cartId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/displayAddOns_r"),body:{
      'cartId' : cartId
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTenantSegregate () async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTenant_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTicketNoOnFoods() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTicketNoOnFoods_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTicketNoOnGoods() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTicketNoOnGoods_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTicketNoFoodOnTransit() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTicketNoFood_ontrans_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTicketNoFoodOnDelivered() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTicketNoFood_delivered_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTicketCancelled() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTicket_cancelled_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future lookItems(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/lookItems_r"),body:{
      'ticketNo' : encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future orderTimeFramePickUp(ticketNo, tenantId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/orderTimeFramePickUp_r"),body:{
      'ticketNo' : encrypt(ticketNo),
      'tenantId' : encrypt(tenantId),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getContainer(ticketId, tenantId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getContainer_r"),body:{
      'ticketId' : encrypt(ticketId),
      'tenantId' : encrypt(tenantId),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future orderTimeFrameDelivery(ticketNo, tenantId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/orderTimeFrameDelivery_r"),body:{
      'ticketNo' : encrypt(ticketNo),
      'tenantId' : encrypt(tenantId),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future cancelStatus(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getCancelStatus_r"),body:{
      'ticketNo' : encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future lookItemsSegregate(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/lookItems_segregate_r"),body:{
      'ticketNo' : encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future lookItemsSegregate2(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/lookItems_segregate2_r"),body:{
      'ticketNo' : encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTotalAmount(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTotalAmount_r"),body:{
      'ticketNo' : encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getAmountPerTenantmod(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getAmountPerTenantmod_r"),body:{
      'ticketNo' : encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future lookItemsGood(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/lookitems_good_r"),body:{
      'ticketNo' : encrypt(ticketNo),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getDiscount(ticketID) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getDiscount_r"),body:{
      'ticketID' : encrypt(ticketID),
    });
    try {
      dataUser = jsonDecode(response.body);
    } catch (e) {
      print('caught error: $e');
    }

    client.close();
    return dataUser;
  }

  Future getTotal(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTotal_r"),body:{
      'ticketNo' : encrypt(ticketNo),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTotal2(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTotal_r2"),body:{
      'ticketNo' : encrypt(ticketNo),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getPickupSchedule(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getPickupSchedule_r"),body:{
      'ticketNo' : encrypt(ticketNo),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getVehicleType(ticketId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getVehicleType_r"),body:{
      'ticketId' : encrypt(ticketId),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getSpecialInstructions(ticketId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getInstruction_r"),body:{
      'ticketId' : encrypt(ticketId),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getOrderSummary(ticketId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getOrderSummary_r"),body:{
      'ticketId' : encrypt(ticketId),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getPickupSummary(ticketId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getPickupSummary_r"),body:{
      'ticketId' : encrypt(ticketId),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getSTotal(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getSubTotal_r"),body:{
      'ticketNo' : encrypt(ticketNo),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }



  Future checkIfOnGoing(ticketNo) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkifongoing_r"),body:{
      'ticketNo' : encrypt(ticketNo)
    });
    client.close();
    return response.body;
  }

  Future removeItemFromCart(cartId) async{
    var client = http.Client();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    await client.post(Uri.parse("$server/removeItemFromCart_r"),body:{
      'cartId' : cartId
    });
    client.close();
  }

  Future trapTenantLimit(townId) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/trapTenantLimit_r"),body:{
      'cusId' : encrypt(userID),
      'townId': encrypt(townId.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getAmountPerTenant() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTenant_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getAmountPerTenant2(productID) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTenant_r2"),body:{
      'cusId'     : encrypt(userID),
      'productID' : encrypt(productID.toString())
    });
      try {
        dataUser = jsonDecode(response.body);
    } catch (e) {
      print('caught error: $e');
    }

    client.close();
    return dataUser;
  }

  Future getGlobalCat() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getglobalcat_r"),body:{
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  //node
  Future getBusinessUnitsCi() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/display_store_r"),body:{
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getBusinessUnits(groupID) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/load_store_r"),body:{
      'groupID' : encrypt(groupID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTenantsCi(buCode , globalID) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/display_tenant_r"),body:{
      'buCode' : encrypt(buCode),
      'globalID' : encrypt(globalID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getStoreCi(categoryId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/display_restaurant_r"),body:{
      'categoryId' : encrypt(categoryId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getItemDataCi(prodId,productUom) async{
    var client = http.Client();
    if(productUom == null){
      productUom = null;
    }
    Map dataUser;
    final response = await client.post(Uri.parse("$server/display_item_data_r"),body:{
      'prodId'     : encrypt(prodId.toString()),
      'productUom' : encrypt(productUom.toString())
    });
    try {
      dataUser = jsonDecode(response.body);
    } catch (e) {
      print('caught error: $e');
    }
    client.close();
    return dataUser;
  }

  Future getSuggestion(prodId) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID =  prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getSuggestion_r"),body:{
      'prodId' : encrypt(prodId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future addToCartCi(buCode,tenantCode,prodId,itemCount,price) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/add_to_cart_r"),body:{
      'customerId' : encrypt(userID),
      'buCode'     : encrypt(buCode),
      'tenantCode' : encrypt(tenantCode),
      'prodId'     : encrypt(prodId),
      'itemCount'  : encrypt(itemCount),
      'price'      : encrypt(price)
    });
    client.close();
  }

  Future addToCartCiTest(buCode,tenantCode,prodId,productUom,flavorId,drinkId,drinkUom,friesId,friesUom,sideId,sideUom,selectedSideItems,selectedSideItemsUom,selectedDessertItems,selectedDessertItemsUom,boolFlavorId,boolDrinkId,boolFriesId,boolSideId,_counter) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/add_to_cart_r"),body:{
      'customerId'             : encrypt(userID),
      'buCode'                 : encrypt(buCode.toString()),
      'tenantCode'             : encrypt(tenantCode.toString()),
      'prodId'                 : encrypt(prodId.toString()),
      'productUom'             : encrypt(productUom.toString()),
      'flavorId'               : encrypt(flavorId.toString()),
      'drinkId'                : encrypt(drinkId.toString()),
      'drinkUom'               : encrypt(drinkUom.toString()),
      'friesId'                : encrypt(friesId.toString()),
      'friesUom'               : encrypt(friesUom.toString()),
      'sideId'                 : encrypt(sideId.toString()),
      'sideUom'                : encrypt(sideUom.toString()),
      'selectedSideItems'      : encrypt(selectedSideItems.toString()),
      'selectedSideItemsUom'   : encrypt(selectedSideItemsUom.toString()),
      'selectedDessertItems'   : encrypt(selectedDessertItems.toString()),
      'selectedDessertItemsUom': encrypt(selectedDessertItemsUom.toString()),
      '_counter'               : encrypt(_counter.toString())
    });
    client.close();
  }


  Future selectSuffixCi() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/selectSuffix_r"));
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTowns() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTowns_r"));

    try {
      dataUser = jsonDecode(response.body);
    } catch (e) {
      print('caught error: $e');
    }
    client.close();
    return dataUser;
  }

  Future getBarrioCi(townId) async{
    var client = http.Client();
    Map dataUser;
    final response =  await client.post(Uri.parse("$server/getbarrio_r"),body:{
      'townId' : encrypt(townId.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future updateCartQty(id,qty) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/updateCartQty_r"),body:{
      'id' : encrypt(id),
      'qty': encrypt(qty)
    });
    client.close();
  }

  Future updateCartStk(id,stk) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/updateCartStk_r"),body:{
      'id' : encrypt(id),
      'stk': encrypt(stk.toString())
    });
    client.close();
  }

  Future getCounter() async{
    var client = http.Client();
    String userID;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String status = prefs.getString('s_status');
    if(status==null){
      userID = '0';
    }else{
      userID = prefs.getString('s_customerId');
    }
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getCounter_r"),body:{
      'customerId' : encrypt(userID)
    });
    try {
      dataUser = jsonDecode(response.body);
    } catch (e) {
      print('caught error: $e');
    }
    client.close();
    return dataUser;
  }

  Future savePickup(deliveryDateData,deliveryTimeData,getTenantData,specialInstruction,subtotal,productID) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/savePickup_r"),body:{

      'customerId'          : encrypt(userID),
      'deliveryDateData'    : encrypt(deliveryDateData.toString()),
      'deliveryTimeData'    : encrypt(deliveryTimeData.toString()),
      'getTenantData'       : encrypt(getTenantData.toString()),
      'specialInstruction'  : encrypt(specialInstruction.toString()),
      'subtotal'            : encrypt(subtotal.toString()),
      'selectedDiscountType': encrypt(selectedDiscountType.toString()),
      'productID'           : encrypt(productID.toString())
    });
    client.close();
  }

  Future savePickup2(deliveryDateData,deliveryTimeData,getTenantData,specialInstruction,subtotal,productID) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/savePickup_r2"),body:{

      'customerId'          : encrypt(userID),
      'deliveryDateData'    : encrypt(deliveryDateData.toString()),
      'deliveryTimeData'    : encrypt(deliveryTimeData.toString()),
      'getTenantData'       : encrypt(getTenantData.toString()),
      'specialInstruction'  : encrypt(specialInstruction.toString()),
      'subtotal'            : encrypt(subtotal.toString()),
      'selectedDiscountType': encrypt(selectedDiscountType.toString()),
      'productID'           : encrypt(productID.toString())
    });
    client.close();
  }

  Future loadSubTotal() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response =  await client.post(Uri.parse("$server/loadSubTotalnew_r"),body:{
      'customerId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadSubTotal2(productID) async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response =  await client.post(Uri.parse("$server/loadSubTotalnew_r2"),body:{
      'customerId' : encrypt(userID),
      'productID'  : encrypt(productID.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadRiderPage(ticketNo) async{
    var client = http.Client();
    Map dataUser;
    final response =  await client.post(Uri.parse("$server/showRiderDetails_r"),body:{
      'ticketNo' : encrypt(ticketNo)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTrueTime() async{
    var client = http.Client();
    Map dataUser;
    final response =  await client.post(Uri.parse("$server/getTrueTime_r"));
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadFlavor(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadFlavor_r"),body:{
      'prodId' : encrypt(prodId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadDrinks(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadDrinks_r"),body:{
      'prodId' : encrypt(prodId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadFries(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadFries_r"),body:{
      'prodId' : encrypt(prodId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadSide(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadSide_r"),body:{
      'prodId' : encrypt(prodId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }
//    String userID;
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String status = prefs.getString('s_status');
//    if(status==null){
//      userID = '0';
//    }else{
//      userID = prefs.getString('s_customerId');
//    }
//    Map dataUser;
//    final response = await http.post("$server/getSubtotal_r",body:{
//      'customerId':userID
//    });

//  Future listenCartSubtotal() async{
//    dataUser = jsonDecode(response.body);
//    return dataUser;
//  }

  Future checkAddon(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/checkAddon_r"),body:{
      'prodId' : encrypt(prodId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadAddonSide(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadAddonSide_r"),body:{
      'prodId' : encrypt(prodId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadAddonDessertSide(prodId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadAddonDessert_r"),body:{
      'prodId' : encrypt(prodId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future cancelOrderTenant(tenantID,ticketID) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/cancelOrderTenant_r"),body:{
      'tenantID' : encrypt(tenantID),
      'ticketID' : encrypt(ticketID)
    });
    client.close();
  }


  Future cancelOrderSingleGood(tomsId,ticketId) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/cancelOrderSingleGood_r"),body:{
      'tomsId'  : encrypt(tomsId),
      'ticketId': encrypt(ticketId)
    });
    client.close();
  }

  Future cancelOrderSingleFood(tomsId,ticketId) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/cancelOrderSingleFood_r"),body:{
      'tomsId'  : encrypt(tomsId),
      'ticketId': encrypt(ticketId)
    });
    client.close();
  }

  Future loadLocation(placeRemark) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadLocation_r"),body:{
      'placeRemark' : placeRemark
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future checkEmptyStore(tenantCode) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkifemptystore_r"),body:{
      'tenantCode' : encrypt(tenantCode)
    });
    client.close();
    return response.body;
  }

  Future getCategories(tenantCode) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getCategories_r"),body:{
      'tenantCode' : encrypt(tenantCode)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getItemsByCategories(categoryId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getItemsByCategories_r"),body:{
      'categoryId' : encrypt(categoryId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getItemsByCategoriesAll(tenantCode) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getItemsByCategoriesAll_r"),body:{
      'tenantCode' : encrypt(tenantCode)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getGcStoreCi(String offset,categoryNo,[itemSearch = ""]) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getGcItems_r"),body:{
      'offset'    : offset,
      'categoryNo': categoryNo,
      'itemSearch': itemSearch
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future addToCartGc(buCode,prodId,itemCode,uomSymbol,uomId,_counter) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/addToCartGc_r"),body:{
      'userID'    : encrypt(userID.toString()),
      'buCode'    : encrypt(buCode.toString()),
      'prodId'    : encrypt(prodId.toString()),
      'itemCode'  : encrypt(itemCode.toString()),
      'uomSymbol' : encrypt(uomSymbol.toString()),
      'uom'       : encrypt(uomId.toString()),
      '_counter'  : encrypt(_counter.toString()),
    });
    client.close();
  }

  Future gcLoadPriceGroup() async {
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response =  await client.post(Uri.parse("$server/gc_loadPriceGroup_r"),body:{
      'userID' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getAmountPerStore() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response =  await client.post(Uri.parse("$server/getStore_r"),body:{
      'userID' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getAmountPerStore2(tempID) async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response =  await client.post(Uri.parse("$server/getStore2_r"),body:{
      'userID' : encrypt(userID),
      'tempID' : encrypt(tempID.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future gcLoadCartData() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response =  await client.post(Uri.parse("$server/gc_cart_r"),body:{
      'userID' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future gcLoadCartData2(tempID) async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response =  await client.post(Uri.parse("$server/gc_cart2_r"),body:{
      'userID' : encrypt(userID),
      'tempID' : encrypt(tempID.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future updateGcCartQty(id,qty) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/updateGcCartQty_r"),body:{
      'id' : encrypt(id),
      'qty': encrypt(qty)
    });
    client.close();
  }

  Future loadGcSubTotal() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    print(userID);
    final response = await client.post(Uri.parse("$server/loadGcSubTotal_r"),body:{
      'customerId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadGcSubTotal2(tempID) async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    print(userID);
    final response = await client.post(Uri.parse("$server/loadGcSubTotal2_r"),body:{
      'customerId' : encrypt(userID),
      'tempID' : encrypt(tempID.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getGcCounter() async{
    var client = http.Client();
    String userID;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String status = prefs.getString('s_status');
    if(status==null){
      userID = '0';
    }else{
      userID = prefs.getString('s_customerId');
    }
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getGcCounter_r"),body:{
      'customerId' : encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getGcCategories() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getGcCategories_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getItemsByGcCategories(categoryId,offset, groupCode) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getItemsByGcCategories_r"),body:{
      'categoryId'  : encrypt(categoryId),
      'offset'      : encrypt(offset.toString()),
      'groupCode'   : encrypt(groupCode)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future removeGcItemFromCart(cartId) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/removeGcItemFromCart_r"),body:{
      'cartId' : encrypt(cartId)
    });
    client.close();
  }
  
  Future getBill(priceG) async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/getBill_r"),body:{
      'customerId' : encrypt(userID),
      'priceG'     : encrypt(priceG)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }
  
  Future gcGroupByBu(priceGroup) async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/gcgroupbyBu_r"),body:{
      'customerId' : encrypt(userID),
      'priceGroup' : encrypt(priceGroup)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future gcGroupByBu2(priceGroup, tempID) async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/gcgroupbyBu2_r"),body:{
      'customerId' : encrypt(userID),
      'priceGroup' : encrypt(priceGroup),
      'tempID'     : encrypt(tempID.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }
  
  Future getConFee() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getConFee_r"),body:{
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future submitOrder(
      groupValue,
      deliveryDateData,
      deliveryTimeData,
      buData,
      totalData,
      convenienceData,
      placeRemarks,
      pickUpOrDelivery, 
      priceGroup) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/gc_submitOrder_r"),body:{
      'customerId'       : encrypt(userID),
      'groupValue'       : encrypt(groupValue.toString()),
      'deliveryDateData' : encrypt(deliveryDateData.toString()),
      'deliveryTimeData' : encrypt(deliveryTimeData.toString()),
      'buData'           : encrypt(buData.toString()),
      'totalData'        : encrypt(totalData.toString()),
      'convenienceData'  : encrypt(convenienceData.toString()),
      'placeRemarks'     : encrypt(placeRemarks.toString()),
      'pickUpOrDelivery' : encrypt(pickUpOrDelivery.toString()),
      'priceGroup'       : encrypt(priceGroup),
    });
    client.close();
  }

  Future submitOrder2(
      groupValue,
      deliveryDateData,
      deliveryTimeData,
      buData,
      totalAmount,
      pickingCharge,
      placeRemarks,
      pickUpOrDelivery,
      priceGroup,
      tempID) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/gc_submitOrder2_r"),body:{
      'customerId'       : encrypt(userID),
      'groupValue'       : encrypt(groupValue.toString()),
      'deliveryDateData' : encrypt(deliveryDateData.toString()),
      'deliveryTimeData' : encrypt(deliveryTimeData.toString()),
      'buData'           : encrypt(buData.toString()),
      'totalAmount'      : encrypt(totalAmount.toString()),
      'pickingCharge'    : encrypt(pickingCharge.toString()),
      'placeRemarks'     : encrypt(placeRemarks.toString()),
      'pickUpOrDelivery' : encrypt(pickUpOrDelivery.toString()),
      'priceGroup'       : encrypt(priceGroup),
      'tempID'           : encrypt(tempID.toString())
    });
    client.close();
  }

  Future getUom(itemCode) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/gc_select_uom_r"),body:{
      'itemCode' : encrypt(itemCode)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }
  Future showDiscount() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/showDiscount_r"),body:{

    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }
  // Future uploadId1(discountIdType,name,idNumber,base64Image,base64Booklet) async{
  //   var client = http.Client();
  //   int imageName = DateTime.now().microsecondsSinceEpoch;
  //   int imageBookletName = DateTime.now().microsecondsSinceEpoch;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   var userID = prefs.getString('s_customerId');
  //   await client.post(Uri.parse("$server/uploadId1_r"),body:{
  //     'userID':encrypt(userID),
  //     'discountId':encrypt(discountIdType),
  //     'name':encrypt(name),
  //     'idNumber':encrypt(idNumber),
  //     'imageName':encrypt(imageName.toString()),
  //     'imageBookletName':encrypt(imageBookletName.toString())
  //   });
  //   uploadImage(base64Image,imageName);
  //   uploadBookletImage(base64Booklet,imageBookletName);
  //   client.close();
  // }


  Future uploadBookletImage(_image,imageName) async {
    var client = http.Client();
    await client.post(Uri.parse("$server/upLoadImage_r"),body:{
      '_image'    : _image,
      '_imageName': imageName.toString()
    });
    client.close();
  }

  Future displayId() async {
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/loadIdList_r"),body:{
      'userID' : encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future futureLoadQuotes() async {
    var client = http.Client();
    Map dataUser;
    final response = await client.get(Uri.parse("https://api.quotable.io/random?minLength=30&maxLength=40"));
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future delete(id) async {
    var client = http.Client();
    await client.post(Uri.parse("$server/delete_id_r"),body:{
      'id' : encrypt(id)
    });
    client.close();
  }

  Future checkIfHasId() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/checkidcheckout_r"),body:{
      'userID' : encrypt(userID)
    });
    client.close();
    return response.body;
  }

  Future changeAccountStat(usernameLogIn) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/changeAccountStat_r"),body:{
      'usernameLogIn' : encrypt(usernameLogIn)
    });
    client.close();
  }

  Future getUserDetails(usernameLogIn) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getUserDetails_r"),body:{
      'usernameLogIn' : encrypt(usernameLogIn)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future verifyOTP(realMobileNumber) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/verifyOTP_r"),body:{
      'mobileNumber' : encrypt(realMobileNumber)
    });
    // await client.post(Uri.parse("$server/verifyOTP_r"),body:{
    //   'mobileNumber':realMobileNumber
    // });
    client.close();
    return response.body;
  }

  Future recoverOTP(realMobileNumber) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/recoverOTP_r"),body:{
      'mobileNumber' : encrypt(realMobileNumber)
    });
    // await client.post(Uri.parse("$server/recoverOTP_r"),body:{
    //   'mobileNumber':realMobileNumber
    // });
    client.close();
    return response.body;
  }

  Future updateProfileOTP(realMobileNumber) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/updateProfileOTP_r"),body:{
      'mobileNumber' : encrypt(realMobileNumber)
    });
    // await client.post(Uri.parse("$server/updateProfileOTP_r"),body:{
    //   'mobileNumber':realMobileNumber
    // });
    client.close();
    return response.body;
  }

  Future verifyOtpCode(otpCode, mobileNumber, userID) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/verifyOtpCode_r"),body:{
      'otpCode'      : encrypt(otpCode),
      'mobileNumber' : encrypt(mobileNumber),
      'userID'       : encrypt(userID),
    });
    client.close();
    return response.body;

  }

  Future checkOtpCode(otpCode,mobileNumber) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkOtpCode_r"),body:{
      'otpCode'      : encrypt(otpCode),
      'mobileNumber' : encrypt(mobileNumber)
    });
    client.close();
    return response.body;
  }

  Future changePassword(newPassWord,realMobileNumber) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/changePassword_r"),body:{
      'newPassWord'      : encrypt(newPassWord),
      'realMobileNumber' : encrypt(realMobileNumber)
    });
    client.close();
  }

  Future checkUsernameIfExist(username) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkUsernameIfExist_r"),body:{
      'username' : encrypt(username)
    });
    client.close();
    return response.body;
  }

  Future getOrderTicketIfExist(ticketID) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/getOrderTicket_r"),body:{
      'ticketID' : encrypt(ticketID.toString())
    });
    client.close();
    return response.body;
  }

  Future checkEmailIfExist(email) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkEmailIfExist_r"),body:{
      'email' : encrypt(email)
    });
    client.close();
    return response.body;
  }

  Future checkPhoneIfExist(phoneNumber) async{
    var client = http.Client();
    final response = await client.post(Uri.parse("$server/checkPhoneIfExist_r"),body:{
      'phoneNumber' : encrypt(phoneNumber)
    });
    client.close();
    return response.body;
  }

  Future getProvince() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getProvince_r"),body:{
    });
    try {
      dataUser = jsonDecode(response.body);
    } catch(e){
      print(e);
    }

    client.close();
    return dataUser;
  }

  Future selectTown(provinceId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTown_r"),body:{
      'provinceId' : encrypt(provinceId)
    });
    try {
      dataUser = jsonDecode(response.body);
    } catch(e) {
      print(e);
    }

    client.close();
    return dataUser;
  }

  Future selectBarangay(townID) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getBarangay_r"),body:{
      'townID' : encrypt(townID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future selectBuildingType() async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/selectBuildingType"),body:{
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future addTempCartPickup(
      orderID,
      productID,
      uomID,
      quantity,
      price,
      measurement,
      totalPrice,
      icoos
      ) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/addTempCartPickup_r"),body:{
      'userID'      : encrypt(userID),
      'orderID'     : encrypt(orderID.toString()),
      'productID'   : encrypt(productID.toString()),
      'uomID'       : encrypt(uomID.toString()),
      'quantity'    : encrypt(quantity.toString()),
      'price'       : encrypt(price.toString()),
      'measurement' : encrypt(measurement.toString()),
      'totalPrice'  : encrypt(totalPrice.toString()),
      'icoos'       : encrypt(icoos.toString()),

    });
    client.close();
  }

  Future addTempCartDelivery(
      orderID,
      productID,
      uomID,
      quantity,
      price,
      measurement,
      totalPrice,
      icoos
      ) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/addTempCartDelivery_r"),body:{
      'userID'      : encrypt(userID),
      'orderID'     : encrypt(orderID.toString()),
      'productID'   : encrypt(productID.toString()),
      'uomID'       : encrypt(uomID.toString()),
      'quantity'    : encrypt(quantity.toString()),
      'price'       : encrypt(price.toString()),
      'measurement' : encrypt(measurement.toString()),
      'totalPrice'  : encrypt(totalPrice.toString()),
      'icoos'       : encrypt(icoos.toString()),

    });
    client.close();
  }

  Future addToCartNew(prodId,uomId,_counter,uomPrice,measurement,
      choiceUomIdDrinks,choiceIdDrinks,choicePriceDrinks,
      choiceUomIdFries,choiceIdFries,choicePriceFries,
      choiceUomIdSides,choiceIdSides,choicePriceSides,
      suggestionIdFlavor, productSuggestionIdFlavor, suggestionPriceFlavor,
      suggestionIdWoc, productSuggestionIdWoc, suggestionPriceWoc,
      suggestionIdTos, productSuggestionIdTos, suggestionPriceTos,
      suggestionIdTon, productSuggestionIdTon, suggestionPriceTon,
      suggestionIdTops, productSuggestionIdTops, suggestionPriceTops,
      suggestionIdCoi, productSuggestionIdCoi, suggestionPriceCoi,
      suggestionIdCoslfm, productSuggestionIdCoslfm, suggestionPriceCoslfm,
      suggestionIdSink, productSuggestionIdSink, suggestionPriceSink,
      suggestionIdBcf, productSuggestionIdBcf, suggestionPriceBcf,
      suggestionIdCc, productSuggestionIdCc, suggestionPriceCc,
      suggestionIdCom, productSuggestionIdCom, suggestionPriceCom,
      suggestionIdCoft, productSuggestionIdCoft, suggestionPriceCoft,
      suggestionIdCymf, productSuggestionIdCymf, suggestionPriceCymf,
      suggestionIdTomb, productSuggestionIdTomb, suggestionPriceTomb,
      suggestionIdCosv, productSuggestionIdCosv, suggestionPriceCosv,
      suggestionIdTop, productSuggestionIdTop, suggestionPriceTop,
      suggestionIdTocw, productSuggestionIdTocw, suggestionPriceTocw,
      suggestionIdNameless, productSuggestionIdNameless, suggestionPriceNameless,
      selectedSideOnPrice,selectedSideItems ,selectedSideItemsUom,
      selectedSideSides, selectedSideDessert, selectedSideDrinks) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/addToCartNew_r"),body:{
      'userID'                        : encrypt(userID),
      'prodId'                        : encrypt(prodId),
      'uomId'                         : encrypt(uomId.toString()),
      '_counter'                      : encrypt(_counter.toString()),
      'uomPrice'                      : encrypt(uomPrice.toString()),
      'measurement'                   : encrypt(measurement.toString()),

      'choiceUomIdDrinks'             : encrypt(choiceUomIdDrinks.toString()),
      'choiceIdDrinks'                : encrypt(choiceIdDrinks.toString()),
      'choicePriceDrinks'             : encrypt(choicePriceDrinks.toString()),

      'choiceUomIdFries'              : encrypt(choiceUomIdFries.toString()),
      'choiceIdFries'                 : encrypt(choiceIdFries.toString()),
      'choicePriceFries'              : encrypt(choicePriceFries.toString()),

      'choiceUomIdSides'              : encrypt(choiceUomIdSides.toString()),
      'choiceIdSides'                 : encrypt(choiceIdSides.toString()),
      'choicePriceSides'              : encrypt(choicePriceSides.toString()),

      'suggestionIdFlavor'            : encrypt(suggestionIdFlavor.toString()),
      'productSuggestionIdFlavor'     : encrypt(productSuggestionIdFlavor.toString()),
      'suggestionPriceFlavor'         : encrypt(suggestionPriceFlavor.toString()),

      'suggestionIdWoc'               : encrypt(suggestionIdWoc.toString()),
      'productSuggestionIdWoc'        : encrypt(productSuggestionIdWoc.toString()),
      'suggestionPriceWoc'            : encrypt(suggestionPriceWoc.toString()),

      'suggestionIdTos'               : encrypt(suggestionIdTos.toString()),
      'productSuggestionIdTos'        : encrypt(productSuggestionIdTos.toString()),
      'suggestionPriceTos'            : encrypt(suggestionPriceTos.toString()),

      'suggestionIdTon'               : encrypt(suggestionIdTon.toString()),
      'productSuggestionIdTon'        : encrypt(productSuggestionIdTon.toString()),
      'suggestionPriceTon'            : encrypt(suggestionPriceTon.toString()),

      'suggestionIdTops'              : encrypt(suggestionIdTops.toString()),
      'productSuggestionIdTops'       : encrypt(productSuggestionIdTops.toString()),
      'suggestionPriceTops'           : encrypt(suggestionPriceTops.toString()),

      'suggestionIdCoi'               : encrypt(suggestionIdCoi.toString()),
      'productSuggestionIdCoi'        : encrypt(productSuggestionIdCoi.toString()),
      'suggestionPriceCoi'            : encrypt(suggestionPriceCoi.toString()),

      'suggestionIdCoslfm'            : encrypt(suggestionIdCoslfm.toString()),
      'productSuggestionIdCoslfm'     : encrypt(productSuggestionIdCoslfm.toString()),
      'suggestionPriceCoslfm'         : encrypt(suggestionPriceCoslfm.toString()),

      'suggestionIdSink'              : encrypt(suggestionIdSink.toString()),
      'productSuggestionIdSink'       : encrypt(productSuggestionIdSink.toString()),
      'suggestionPriceSink'           : encrypt(suggestionPriceSink.toString()),

      'suggestionIdBcf'               : encrypt(suggestionIdBcf.toString()),
      'productSuggestionIdBcf'        : encrypt(productSuggestionIdBcf.toString()),
      'suggestionPriceBcf'            : encrypt(suggestionPriceBcf.toString()),

      'suggestionIdCc'                : encrypt(suggestionIdCc.toString()),
      'productSuggestionIdCc'         : encrypt(productSuggestionIdCc.toString()),
      'suggestionPriceCc'             : encrypt(suggestionPriceCc.toString()),

      'suggestionIdCom'               : encrypt(suggestionIdCom.toString()),
      'productSuggestionIdCom'        : encrypt(productSuggestionIdCom.toString()),
      'suggestionPriceCom'            : encrypt(suggestionPriceCom.toString()),

      'suggestionIdCoft'              : encrypt(suggestionIdCoft.toString()),
      'productSuggestionIdCoft'       : encrypt(productSuggestionIdCoft.toString()),
      'suggestionPriceCoft'           : encrypt(suggestionPriceCoft.toString()),

      'suggestionIdCymf'              : encrypt(suggestionIdCymf.toString()),
      'productSuggestionIdCymf'       : encrypt(productSuggestionIdCymf.toString()),
      'suggestionPriceCymf'           : encrypt(suggestionPriceCymf.toString()),

      'suggestionIdTomb'              : encrypt(suggestionIdTomb.toString()),
      'productSuggestionIdTomb'       : encrypt(productSuggestionIdTomb.toString()),
      'suggestionPriceTomb'           : encrypt(suggestionPriceTomb.toString()),

      'suggestionIdCosv'              : encrypt(suggestionIdCosv.toString()),
      'productSuggestionIdCosv'       : encrypt(productSuggestionIdCosv.toString()),
      'suggestionPriceCosv'           : encrypt(suggestionPriceCosv.toString()),

      'suggestionIdTop'               : encrypt(suggestionIdTop.toString()),
      'productSuggestionIdTop'        : encrypt(productSuggestionIdTop.toString()),
      'suggestionPriceTop'            : encrypt(suggestionPriceTop.toString()),

      'suggestionIdTocw'              : encrypt(suggestionIdTocw.toString()),
      'productSuggestionIdTocw'       : encrypt(productSuggestionIdTocw.toString()),
      'suggestionPriceTocw'           : encrypt(suggestionPriceTocw.toString()),

      'suggestionIdNameless'          : encrypt(suggestionIdNameless.toString()),
      'productSuggestionIdNameless'   : encrypt(productSuggestionIdNameless.toString()),
      'suggestionPriceNameless'       : encrypt(suggestionPriceNameless.toString()),

      'selectedSideOnPrice'           : encrypt(selectedSideOnPrice.toString()),
      'selectedSideItems'             : encrypt(selectedSideItems.toString()),
      'selectedSideItemsUom'          : encrypt(selectedSideItemsUom.toString()),

      'selectedSideSides'             : encrypt(selectedSideSides.toString()),
      'selectedSideDessert'           : encrypt(selectedSideDessert.toString()),
      'selectedSideDrinks'            : encrypt(selectedSideDrinks.toString()),
    });
    client.close();
    return response.body;
  }

  Future updateNewAddress(id, firstName, lastName, mobileNum, houseUnit, streetPurok, landMark, otherNotes, barangayID, addressType) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/updateNewAddress_r"),body:{
      'id'          : encrypt(id.toString()),
      'userID'      : encrypt(userID.toString()),
      'firstName'   : encrypt(firstName.toString()),
      'lastName'    : encrypt(lastName.toString()),
      'mobileNum'   : encrypt(mobileNum.toString()),
      'houseUnit'   : houseUnit,
      'streetPurok' : encrypt(streetPurok.toString()),
      'landMark'    : encrypt(landMark.toString()),
      'otherNotes'  : otherNotes,
      'barangayID'  : encrypt(barangayID.toString()),
      'addressType' : encrypt(addressType.toString())
    });
    client.close();
  }

  Future updateProfile(firstName, lastName, email, mobileNumber) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/updateProfile_r"),body:{
      'userID'      : encrypt(userID),
      'firstName'   : encrypt(firstName),
      'lastName'    : encrypt(lastName),
      'email'       : encrypt(email),
      'mobileNumber': encrypt(mobileNumber),
    });
    client.close();
  }

  Future submitNewAddress(firstName,lastName,mobileNum,houseUnit,streetPurok,landMark,otherNotes,barangayID,addressType) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/submitNewAddress_r"),body:{
      'userID'      : encrypt(userID),
      'firstName'   : encrypt(firstName),
      'lastName'    : encrypt(lastName),
      'mobileNum'   : encrypt(mobileNum),
      'houseUnit'   : houseUnit,
      'streetPurok' : encrypt(streetPurok),
      'landMark'    : encrypt(landMark),
      'otherNotes'  : otherNotes,
      'barangayID'  : encrypt(barangayID.toString()),
      'addressType' : encrypt(addressType)
    });
    client.close();
  }

  Future selectCategory(tenantId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/viewTenantCategories_r"),body:{
      'tenantId' : encrypt(tenantId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadAddresses(idd, cusId) async{
    var client = http.Client();
    Map dataUser;
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await client.post(Uri.parse("$server/loadAdresses_r"),body:{
      'idd'    : encrypt(idd),
      'userID' : encrypt(cusId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadAddress() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/loadAddress_r"),body:{
      'userID' : encrypt(userID)
    });
    try {
      dataUser = jsonDecode(response.body);
    } catch (e) {
      print('caught error: $e');
    }
    client.close();
    return dataUser;
  }

  Future deleteAddress(id) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/deleteAddress_r"),body:{
      'id' : encrypt(id)
    });
    client.close();
  }

  Future deleteDiscountID(id) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/deleteDiscountID_r"),body:{
      'id' : encrypt(id)
    });
    client.close();
  }

  Future checkIfHasAddresses() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/checkIfHasAddresses_r"),body:{
      'userID' : encrypt(userID)
    });
    client.close();
    return response.body;
  }

  Future displayAddresses(groupID) async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/submitLoadAddress_r"),body:{
      'userID'  : encrypt(userID),
      'groupID' : encrypt(groupID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future updateDefaultShipping(id,customerId) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/updateDefaultShipping_r"),body:{
      'id'          : encrypt(id),
      'customerId'  : encrypt(customerId)
    });
    client.close();
  }

  Future updateDefaultNumber(id,customerId) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/updateDefaultNumber_r"),body:{
      'id'          : encrypt(id),
      'customerId'  : encrypt(customerId)
    });
    client.close();
  }

  Future updateNumber(id,updateNumber) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/updateNumber_r"),body:{
      'id'            : encrypt(id),
      'updateNumber'  : encrypt(updateNumber)
    });
    client.close();
  }

  Future updatePickupAt(date,time) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/updatePickupAt_r"),body:{
      'date'  : encrypt(date),
      'time'  : encrypt(time),
      'userID': encrypt(userID)
    });
    client.close();
  }

  Future checkIfBf() async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/checkIfBf_r"),body:{
      'userID' : encrypt(userID)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getTotalFee(ticketID) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/getTotalFee_r"),body:{
      'ticketID' : encrypt(ticketID.toString())
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future searchProd(search,unitGroupId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/search_item_r"),body:{
      'search'      : search,
      'unitGroupId' : '$unitGroupId'
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future searchProdGc(search,unitGroupId) async{
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/searchGc_item_r"),body:{
      'search'      : search,
      'unitGroupId' : '$unitGroupId'
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future updatePassword(currentPass,oldPassword) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/updatePassword_r"),body:{
      'userID'      : encrypt(userID),
      'currentPass' : encrypt(currentPass),
      'oldPassword' : encrypt(oldPassword)
    });
    client.close();
    return response.body;
  }

  Future updateUsername(currentPass,newUsername) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/updateUsername_r"),body:{
      'userID'      : encrypt(userID),
      'currentPass' : encrypt(currentPass),
      'newUsername' : encrypt(newUsername)
    });
    client.close();
    return response.body;
  }

  Future loadChat(riderId, ticketId) async{
    var client = http.Client();
    Map dataUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    final response = await client.post(Uri.parse("$server/chat_r"),body:{
      'userID'  : encrypt(userID),
      'riderId' : encrypt(riderId),
      'ticketId': encrypt(ticketId)
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future sendMessage(chat, riderId, ticketId) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/send_chat_r"),body:{
      'chat'    : (chat),
      'userID'  : encrypt(userID),
      'riderId' : encrypt(riderId),
      'ticketId': encrypt(ticketId)
    });
    client.close();
  }

  Future checkVersion(appName) async {
    var client = http.Client();
    Map dataUser;
    final response = await client.post(Uri.parse("$server/check_version_r"),body:{
      'appName' : encrypt(appName),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future loadProfile() async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/loadProfile_r"),body:{
      'cusId' : encrypt(userID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getStatus(tenantID) async {
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/get_status_r"),body:{
      'tenantID' : encrypt(tenantID),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future getStatus2(bunitCode) async {
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    Map dataUser;
    final response = await client.post(Uri.parse("$server/get_status_r2"),body:{
      'bunitCode' : encrypt(bunitCode),
    });
    dataUser = jsonDecode(response.body);
    client.close();
    return dataUser;
  }

  Future uploadProfilePic(base64Image) async{
    var client = http.Client();
    int picName = DateTime.now().microsecondsSinceEpoch;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/uploadProfilePic_r"),body:{
      'userID'  : encrypt(userID),
      'picName' : encrypt(picName.toString())

    });
    uploadPic(base64Image,picName);
    client.close();
  }

  Future uploadId(discountIdType,name,idNumber,base64Image) async{
    var client = http.Client();
    int imageName = DateTime.now().microsecondsSinceEpoch;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/uploadId_r"),body:{
      'userID'    : encrypt(userID),
      'discountId': encrypt(discountIdType),
      'name'      : encrypt(name),
      'idNumber'  : encrypt(idNumber),
      'imageName' : encrypt(imageName.toString())
    });
    uploadImage(base64Image,imageName);
    client.close();
  }

  Future uploadNumber(number) async{
    var client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('s_customerId');
    await client.post(Uri.parse("$server/uploadNumber_r"),body:{
      'userID' : encrypt(userID),
      'number' : encrypt(number),
    });
    client.close();
  }

  Future uploadImage(_image,imageName) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/upLoadImage_r"),body:{
      '_image'    : _image,
      '_imageName': imageName.toString()
    });
    client.close();
  }

  Future uploadPic(_image,imageName) async{
    var client = http.Client();
    await client.post(Uri.parse("$server/upLoadPic_r"),body:{
      '_image'    : _image,
      '_imageName': imageName.toString()
    });
    client.close();
  }
}



