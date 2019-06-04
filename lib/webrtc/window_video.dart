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
  bool outgoing;

  VideoCallScreen(
      {Key key,
      @required this.userData,
      @required this.contact,
      @required this.tabController,
      @required this.outgoing})
      : super(key: key);

  @override
  _VideoCallScreenState createState() => new _VideoCallScreenState();
}

const double AVATAR_IMAGE_SIZE = 200.0;

class _VideoCallScreenState extends State<VideoCallScreen> {
  _VideoCallScreenState({
    Key key,
  });

  Image getImageFromB64(String base64Str) {
    return Image.memory(
      base64Decode(base64Str),
      width: AVATAR_IMAGE_SIZE,
      height: AVATAR_IMAGE_SIZE,
    );
  }

  Widget getUserAvatar(Contact contact) {
    return ClipRRect(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderRadius: BorderRadius.circular(150.0),
      child: contact.avatarURL != ""
          ? Image.asset(
              widget.contact.avatarURL,
              fit: BoxFit.cover,
              // height: 60.0,
              // width: 100.0,
            )
          : contact.avatarBase64 != ""
              ? getImageFromB64(contact.avatarBase64)
              : Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 100.0,
                ),
    );
  }

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
                  radius: 60.0,
                ),
                getUserAvatar(widget.contact),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.45,
            child: Text(
              !outgoing ? "Receiving a call from.." : "Connecting with..",
              style: textStyle,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.35,
            child: Text(
              widget.contact.visibleName,
              style: textStyle.copyWith(fontSize: 32.0),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.15,
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
  }

  void onEndCall() {}

  @override
  deactivate() {
    super.deactivate();
    widget.userData.rtcHandler.disposeRenderers();
  }

  void acceptCall() {
    widget.userData.rtcHandler.initRenderers();
    this.setState(() async {
      widget.userData.rtcHandler.acceptCall();
    });
  }

  void rejectCall() {
    this.setState(() {
      widget.userData.rtcHandler.hangUp();
    });
    Main.popScreens(context, 1);
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
      body: widget.userData.rtcHandler.isBeingCalled() ||
              widget.userData.rtcHandler.isRequestingCall()
          ? _buildCallingScreen(widget.outgoing)
          : widget.userData.rtcHandler.isInCall()
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
                            child: new RTCVideoView(
                                widget.userData.rtcHandler.getRemoteRenderer()),
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
                })
              : Container(),
    );
  }
}
