import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:arush/db_helper.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../create_account_signin.dart';


class Chat extends StatefulWidget {
  final firstName;
  final lastName;
  final riderId;
  final ticketId;

  Chat({Key key, @required this.firstName,this.lastName, this.riderId, this.ticketId}) : super(key: key);
  @override
  _Chat createState() => _Chat();
}

class _Chat extends State<Chat> {
  final db = RapidA();
  var isLoading = true;
  List loadChatData;
  Timer timer;
  final chat = TextEditingController();

  Future loadChat() async{
    var res = await db.loadChat(widget.riderId, widget.ticketId);
    if (!mounted) return;
    setState(() {
      loadChatData = res['user_details'];
      print(loadChatData);
      print('ni load every 5 seconds');
      isLoading = false;
    });
  }

  sendMessage() async{
    await db.sendMessage(chat.text,widget.riderId, widget.ticketId);
    chat.clear();
    loadChat();
  }

  @override
  void initState(){
    loadChat();
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => loadChat());

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("${widget.firstName} ${widget.lastName}",
          style: GoogleFonts.openSans(
            color:Colors.white,fontWeight: FontWeight.bold,fontSize: 16.0,
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
        ),
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Expanded(
            child: RefreshIndicator(
              color: Colors.deepOrangeAccent,
              onRefresh: loadChat,
              child: Scrollbar(
                child: Container(
                  child:  ListView.builder(
                    reverse: true,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: loadChatData == null ? 0 : loadChatData.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isSender = false;
                      Color chatColor = Colors.blueAccent;
                      if(loadChatData[index]['isSender'] == 'true'){
                         isSender = true;
                         chatColor = Colors.deepOrange[300];
                        }
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: BubbleSpecialTwo(
                              text: loadChatData[index]['body'],
                              isSender: isSender,
                              color: chatColor,
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              // sent: true,
                              // seen: true,
                              tail: false,
                            ),
                          ),
                          SizedBox(height: 5.0),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),
          ),

          Container(
            height: 60.0,
            width: screenWidth,
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10.0, bottom: 10.0),
              child: CupertinoTextField(
                padding: EdgeInsets.only(left: 10),
                // autofocus: true,
                style: TextStyle(fontSize: 15.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.deepOrange[300],
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                keyboardType: TextInputType.text,
                controller: chat,
                // maxLines: 12,
                suffix: Container(
                  width: 60.0,
                  child: Padding(
                    padding: EdgeInsets.all(1.0),
                    child: GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String username = prefs.getString('s_customerId');
                        if(username == null){
                          await Navigator.of(context).push(_signIn());
                        }
                          sendMessage();
                      },
                        child: Icon(Icons.send, color: Colors.deepOrangeAccent, size: 32.0),
                    ),
                  ),
                ),
                cursorColor: Colors.black54,
                placeholder: "Enter message",
              ),
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