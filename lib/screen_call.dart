import 'package:flutter/material.dart';
import 'login_background.dart';
import 'screen_contacts.dart';
import 'contact.dart';
import 'pulsating_market.dart';
import 'chat/window_chat.dart';
import 'webrtc/window_video.dart';
import 'user_data.dart';
import 'webrtc/window_video.dart';

class CallScreen extends StatefulWidget {
  final Contact contact;
  UserData userData;
  int initialTab;
  bool outgoing;

  CallScreen(
      {Key key,
      @required this.contact,
      @required this.userData,
      this.outgoing = false,
      this.initialTab = 0})
      : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  bool isCalling = true;
  TabController tabController;

  @override
  void initState() {
    tabController =
        TabController(initialIndex: widget.initialTab, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // bottomNavigationBar: TabBar(
      //   tabs: [
      //     Tab(
      //       icon: new Icon(Icons.videocam),
      //     ),
      //     Tab(
      //       icon: new Icon(Icons.message),
      //     ),
      //   ],
      //   labelColor: Color(0xFF343434),
      //   labelStyle: textStyle.copyWith(
      //       fontSize: 20.0,
      //       color: Color(0xFFc9c9c9),
      //       fontWeight: FontWeight.w700),
      //   indicator: UnderlineTabIndicator(
      //     borderSide:
      //         BorderSide(color: Theme.of(context).primaryColor, width: 8.0),
      //     insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
      //   ),
      //   unselectedLabelColor: Color(0xFFc9c9c9),
      //   unselectedLabelStyle: textStyle.copyWith(
      //       fontSize: 20.0,
      //       color: Color(0xFFc9c9c9),
      //       fontWeight: FontWeight.w700),
      // ),
      body: Stack(children: <Widget>[
        TabBarView(
          controller: tabController,
          children: [
            ChatWindow(
              parentTabController: tabController,
              groupChatId: "test",
              peer: widget.contact,
              userData: widget.userData,
            ),
            VideoCallScreen(
              contact: widget.contact,
              tabController: tabController,
              userData: widget.userData,
              outgoing: widget.outgoing,
            ),
          ],
        ),
      ]),
    );
  }
}
