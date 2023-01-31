// import 'package:flutter/material.dart';
// import 'dart:async';
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   StreamController<int> _events;
//
//   @override
//   initState() {
//     super.initState();
//     _events = StreamController<int>.broadcast();
//     _events.add(60);
//   }
//
//   Timer _timer;
//   void _startTimer() {
//     _counter = 60;
//     if (_timer != null) {
//       _timer.cancel();
//     }
//     if (_timer == null) {
//       _counter = 0;
//     }
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       //setState(() {
//       (_counter > 0) ? _counter-- : _timer.cancel();
//       //});
//       print(_counter);
//       _events.add(_counter);
//     });
//   }
//
//   void alertD(BuildContext ctx) async{
//     var alert = AlertDialog(
//       // title: Center(child:Text('Enter Code')),
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20.0))),
//         backgroundColor: Colors.grey[100],
//         elevation: 0.0,
//         content: StreamBuilder<int>(
//             stream: _events.stream,
//             builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
//               // print(snapshot.data.toString());
//               return Container(
//                 height: 215,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Padding(
//                         padding: const EdgeInsets.only(
//                             top: 10, left: 10, right: 10, bottom: 15),
//                         child: Text(
//                           'Enter Code',
//                           style: TextStyle(
//                               color: Colors.green[800],
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16),
//                         )),
//                     Container(
//                       height: 70,
//                       width: 180,
//                       child: TextFormField(
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                         textAlign: TextAlign.center,
//                         decoration: InputDecoration(
//                           enabledBorder: OutlineInputBorder(
//                               borderSide:
//                               BorderSide(color: Colors.green, width: 0.0)),
//                         ),
//                         keyboardType: TextInputType.number,
//                         maxLength: 10,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 1,
//                     ),
//                     Text('00:${snapshot.data.toString()}'),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(25),
//                           child: Material(
//                             child: InkWell(
//                               onTap: () {
//                                 //Navigator.of(ctx).pushNamed(SignUpScreenSecond.routeName);
//                               },
//                               child: Container(
//                                 width: 100,
//                                 height: 50,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(25),
//                                   gradient: LinearGradient(
//                                       colors: [
//                                         Colors.green,
//                                         Colors.grey,
//                                       ],
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight),
//                                 ),
//                                 child: Center(
//                                     child: Text(
//                                       'Validate',
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold),
//                                     )),
//                               ),
//                             ),
//                           ),
//                         ),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(25),
//                           child: Material(
//                             child: InkWell(
//                               onTap: () {},
//                               child: Container(
//                                 width: 100,
//                                 height: 50,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(25),
//                                   gradient: LinearGradient(
//                                       colors: [
//                                         Colors.grey,
//                                         Colors.green,
//                                       ],
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight),
//                                 ),
//                                 child: Center(
//                                     child: Text(
//                                       'Resend',
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold),
//                                     )),
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     ), //new column child
//                   ],
//                 ),
//               );
//             }));
//     showDialog(
//         context: ctx,
//         builder: (BuildContext c) {
//           return alert;
//         });
//   }
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             RaisedButton(
//                 onPressed: () {
//                   _startTimer();
//                   alertD(context);
//                 },
//                 child: Text('Click')),
//             Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }









import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CountdownTimerDemo extends StatefulWidget {
  @override
  _CountdownTimerDemoState createState() => _CountdownTimerDemoState();
}
class _CountdownTimerDemoState extends State<CountdownTimerDemo> {
  // Step 2
  Timer countdownTimer;
  Duration myDuration = Duration(seconds: 180);


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose()
  {
    super.dispose();
    countdownTimer?.cancel();
  }

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
    setState(() => myDuration = Duration(seconds: 180));
  }
  // Step 6
  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer?.cancel();
        myDuration = Duration(seconds: 0);
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


    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            // Step 8
            Text(
              '$hours:$minutes:$seconds',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 50),
            ),
            SizedBox(height: 20),
            // Step 9
            ElevatedButton(
              onPressed: startTimer,
              child: Text(
                'Start',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            // Step 10
            ElevatedButton(
              onPressed: () {
                if (countdownTimer == null || countdownTimer.isActive) {
                  stopTimer();
                }
              },
              child: Text(
                'Stop',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            // Step 11
            ElevatedButton(
                onPressed: () {
                  resetTimer();
                },
                child: Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}






// import 'dart:ui';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
//
//
// import 'countdown_dart.dart';
// import 'countdown_timer.dart';
//
// class MyHomePage extends StatefulWidget {
//
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
//   int _counter = 0;
//   AnimationController _controller;
//   int levelClock = 10;
//   // 1670997074616
//   CountdownTimerController controller;
//   int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 10;
//
//   bool time = true;
//
//   void onEnd() {
//     setState(() {
//       time = false;
//     });
//
//     print('onEnd');
//   }
//
//   void start() {
//     // controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
//   }
//
//   void _incrementCounter() {
//     setState(() {
//       // _counter++;
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     // controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
//     print('ang endtime kay $endTime');
//
//     _controller = AnimationController(
//         vsync: this,
//         duration: Duration(
//             seconds:
//             levelClock) // gameData.levelClock is a user entered number elsewhere in the applciation
//     );
//
//     if (levelClock == 0){
//       print('hide');
//     }
//
//     _controller.forward();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('timer'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//
//             Visibility(
//               visible: time,
//               child: CountdownTimer(
//                 controller: controller,
//                 endTime: endTime,
//                 onEnd: onEnd,
//               ),
//             ),
//
//
//             Countdown(
//               animation: StepTween(
//                 begin: levelClock, // THIS IS A USER ENTERED NUMBER
//                 end: 0,
//               ).animate(_controller),
//             ),
//
//             // Text(
//             //   'You have pushed the button this many times:',
//             // ),
//             // Text(
//             //   '$_counter',
//             //   style: Theme.of(context).textTheme.bodyText1,
//             // ),
//
//           ],
//         ),
//       ),
//
//       floatingActionButton: FloatingActionButton(
//         onPressed: start,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
