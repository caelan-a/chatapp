import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'signaling.dart';
import 'package:flutter_webrtc/webrtc.dart';
import '../user_data.dart';
import '../contact.dart';
import '../pulsating_market.dart';
import 'package:chatapp/main.dart';
import 'dart:typed_data';
import 'dart:convert';

const textStyle = TextStyle(
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSans',
    fontWeight: FontWeight.w600);

class VideoCallScreen extends StatefulWidget {
  UserData userData;
  Contact contact;
  TabController tabController;

  VideoCallScreen(
      {Key key,
      @required this.userData,
      @required this.contact,
      @required this.tabController,})
      : super(key: key);

  @override
  _VideoCallScreenState createState() => new _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  _VideoCallScreenState({
    Key key,
  });

  @override
  initState() {
    super.initState();
  }

  @override
  deactivate() {
    super.deactivate();
    widget.userData.rtcHandler.disposeRenderers();
  }

  void endCall() {
    this.setState(() {
      widget.userData.rtcHandler.hangUp();
    });
  }

  _switchCamera() {
    widget.userData.rtcHandler.switchCamera();
  }

  _muteMic() {}

  @override
  Widget build(BuildContext context) {
    print(widget.userData.rtcHandler.isInCall());
    return new Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: widget.userData.rtcHandler.isInCall()
            ? new SizedBox(
                width: 300.0,
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        // borderSide: BorderSide(color: Colors.white),
                        // shape: new RoundedRectangleBorder(
                        //     side: BorderSide(color: Colors.white),
                        //     borderRadius: new BorderRadius.circular(30.0)),
                        onPressed: _switchCamera,
                        color: Colors.white,
                        icon: Icon(Icons.switch_camera),
                      ),
                      OutlineButton(
                          borderSide: BorderSide(color: Colors.white),
                          shape: new RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(30.0)),
                          textColor: Colors.white,
                          onPressed: () {
                            endCall();
                          },
                          color: Colors.white,
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.call_end),
                              Text("   End Call"),
                            ],
                          )),
                      IconButton(
                        // borderSide: BorderSide(color: Colors.white),
                        // shape: new RoundedRectangleBorder(
                        //     side: BorderSide(color: Colors.white),
                        //     borderRadius: new BorderRadius.circular(30.0)),
                        onPressed: _muteMic,
                        color: Colors.white,
                        icon: Icon(Icons.mic_off),
                      ),
                    ]))
            : null,
        body: OrientationBuilder(builder: (context, orientation) {
          return new Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      "assets/call_background.jpg",
                    ),
                    fit: BoxFit.cover)),
            child: new Stack(children: <Widget>[
              new Positioned(
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: new Container(
                    margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: new RTCVideoView(
                        widget.userData.rtcHandler.getRemoteRenderer()),
                    // decoration:
                    // new BoxDecoration(color: Colors.black26),
                  )),
              new Positioned(
                right: 20.0,
                top: 20.0,
                child: new Container(
                  width: orientation == Orientation.portrait ? 90.0 : 120.0,
                  height: orientation == Orientation.portrait ? 120.0 : 90.0,
                  child: new RTCVideoView(
                      widget.userData.rtcHandler.getLocalRenderer()),
                  decoration: new BoxDecoration(color: Colors.black54),
                ),
              ),
              Positioned(
                left: 20.0,
                top: 20.0,
                child: IconButton(
                  icon: Icon(Icons.message),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      widget.tabController.animateTo(0);
                    });
                  },
                ),
              )
            ]),
          );
        }));
  }
}
