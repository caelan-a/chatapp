import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'signaling.dart';
import 'package:flutter_webrtc/webrtc.dart';
import '../user_data.dart';
import '../contact.dart';
import '../pulsating_market.dart';

const textStyle = TextStyle(
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSans',
    fontWeight: FontWeight.w600);

class VideoCallScreen extends StatefulWidget {
  final String ip;
  UserData userData;
  Contact contact;
  TabController tabController;
  bool outgoing;

  VideoCallScreen(
      {Key key,
      @required this.ip,
      @required this.userData,
      @required this.contact,
      @required this.tabController,
      @required this.outgoing})
      : super(key: key);

  @override
  _VideoCallScreenState createState() => new _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  bool _inCalling = false;
  bool _receivingCall = false;

  _VideoCallScreenState({
    Key key,
  });

  //  Shown if user is initiating a call or receiving a call request
  Widget _buildCallingScreen(bool outgoing) {
    return Container(
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
                  child: widget.contact.avatarURL != ""
                      ? Image.asset(
                          widget.contact.avatarURL,
                          fit: BoxFit.cover,
                          // height: 60.0,
                          // width: 100.0,
                        )
                      : Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 100.0,
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.55,
            child: Text(
              !outgoing ? "Receiving a call from.." : "Connecting with..",
              style: textStyle,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.45,
            child: Text(
              widget.contact.visibleName,
              style: textStyle.copyWith(fontSize: 32.0),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.25,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: outgoing
                  ? OutlineButton(
                      borderSide: BorderSide(color: Colors.white),
                      shape: new RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white),
                          borderRadius: new BorderRadius.circular(30.0)),
                      textColor: Colors.white,
                      onPressed: () {},
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.call_end),
                          Text("   End Call"),
                        ],
                      ))
                  : Row(
                      children: <Widget>[
                        OutlineButton(
                          borderSide: BorderSide(color: Colors.white),
                          shape: new RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(30.0)),
                          textColor: Colors.white,
                          onPressed: () {
                            acceptCall();
                          },
                          color: Colors.white,
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.call),
                              Text("   Accept"),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(20.0)),
                        OutlineButton(
                            borderSide: BorderSide(color: Colors.white),
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(color: Colors.white),
                                borderRadius: new BorderRadius.circular(30.0)),
                            textColor: Colors.white,
                            onPressed: () {
                              rejectCall();
                            },
                            color: Colors.white,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.call_end),
                                Text("   Reject"),
                              ],
                            ))
                      ],
                    ),
            ),
          ),
          outgoing
              ? Positioned(
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
              : Container(),
        ],
      ),
    );
  }

  @override
  initState() {
    super.initState();

    initRenderers();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    widget.userData.rtcHandler.initStreams(_localRenderer, _remoteRenderer);
  }

  @override
  deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void acceptCall() {
    this.setState(() {
      _inCalling = true;
      _receivingCall = false;
    });
  }

  void rejectCall() {
    widget.userData.rtcHandler.hangUp();
    this.setState(() {
      _inCalling = false;
      _receivingCall = false;
    });
  }

  _switchCamera() {
    widget.userData.rtcHandler.switchCamera();
  }

  _muteMic() {}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _inCalling
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
                          rejectCall();
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
      body: _receivingCall
          ? _buildCallingScreen(false)
          : _inCalling
              ? OrientationBuilder(builder: (context, orientation) {
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
                            child: new RTCVideoView(_remoteRenderer),
                            // decoration:
                            // new BoxDecoration(color: Colors.black26),
                          )),
                      new Positioned(
                        right: 20.0,
                        top: 20.0,
                        child: new Container(
                          width: orientation == Orientation.portrait
                              ? 90.0
                              : 120.0,
                          height: orientation == Orientation.portrait
                              ? 120.0
                              : 90.0,
                          child: new RTCVideoView(_localRenderer),
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
                })
              : Container(),
    );
  }
}
