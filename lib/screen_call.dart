import 'package:flutter/material.dart';
import 'login_background.dart';
import 'screen_contacts.dart';
import 'contact.dart';
import 'pulsating_market.dart';

class CallScreen extends StatefulWidget {
  final Contact contact;

  CallScreen({Key key, @required this.contact}) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

const textStyle = TextStyle(
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSans',
    fontWeight: FontWeight.w600);

class _CallScreenState extends State<CallScreen> {
  void onTabTapped() {}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(
                icon: new Icon(Icons.videocam),
              ),
              Tab(
                icon: new Icon(Icons.message),
              ),
            ],
            labelColor: Color(0xFF343434),
            labelStyle: textStyle.copyWith(
                fontSize: 20.0,
                color: Color(0xFFc9c9c9),
                fontWeight: FontWeight.w700),
            indicator: UnderlineTabIndicator(
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 8.0),
              insets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
            ),
            unselectedLabelColor: Color(0xFFc9c9c9),
            unselectedLabelStyle: textStyle.copyWith(
                fontSize: 20.0,
                color: Color(0xFFc9c9c9),
                fontWeight: FontWeight.w700),
          ),
          body: TabBarView(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          "assets/call_background.jpg",
                        ),
                        fit: BoxFit.cover)),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Positioned(
                      top: MediaQuery.of(context).size.height / 4.2,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          PulsatingMarker(
                            screenPosition: Offset(0, 0),
                            scale: 0.13,
                            color: Colors.white,
                            radius: 50.0,
                          ),
                          ClipRRect(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            borderRadius: BorderRadius.circular(150.0),
                            child: Image.network(
                              widget.contact.avatarURL,
                              fit: BoxFit.cover,
                              scale: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height / 1.55,
                      child: Text(
                        "Connecting with..",
                        style: textStyle,
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height / 1.45,
                      child: Text(
                        widget.contact.username,
                        style: textStyle.copyWith(fontSize: 32.0),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height / 1.25,
                      child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: OutlineButton(
                            borderSide: BorderSide(
                                color: Colors.white),
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.white),
                                borderRadius: new BorderRadius.circular(30.0)),
                            textColor: Colors.white,
                            onPressed: () {},
                            color: Colors.white,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.call_end),
                                Text("   End Call"),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              new Container(),
            ],
          ),
        ));
  }
}
