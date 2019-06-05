import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'webrtc/signaling.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'user_data.dart';
import 'contact.dart';
import 'pulsating_market.dart';
import 'package:chatapp/main.dart';
import 'dart:typed_data';
import 'dart:convert';

const textStyle = TextStyle(
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSans',
    fontWeight: FontWeight.w600);

class RingingScreen extends StatefulWidget {
  UserData userData;
  Contact contact;
  bool outgoing;

  RingingScreen(
      {Key key,
      @required this.userData,
      @required this.contact,
      @required this.outgoing})
      : super(key: key);

  @override
  _RingingScreenState createState() => new _RingingScreenState();
}

const double AVATAR_IMAGE_SIZE = 200.0;

class _RingingScreenState extends State<RingingScreen> {
  _RingingScreenState({
    Key key,
  });

  Image getImageFromB64(String base64Str) {
    return Image.memory(
      base64Decode(base64Str),
      fit: BoxFit.fill,
      width: AVATAR_IMAGE_SIZE,
      height: AVATAR_IMAGE_SIZE,
    );
  }

  @override
  void initState() {
    print('${widget.contact.username} is ringing ');
    super.initState();
  }

  Widget getUserAvatar(Contact contact) {
    return ClipRRect(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderRadius: BorderRadius.circular(150.0),
      child: contact.avatarBase64 != ""
              ? getImageFromB64(contact.avatarBase64)
              : Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 100.0,
                ),
    );
  }

  void acceptCall() async {
    await widget.userData.rtcHandler.acceptCall();
    this.setState(() {});
  }

  void rejectCall() {
    this.setState(() {
      widget.userData.rtcHandler.hangUp();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userData.rtcHandler.isInCall());
    return new Scaffold(
      body: Container(
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
                !widget.outgoing
                    ? "Receiving a call from.."
                    : "Connecting with..",
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
                child: widget.outgoing
                    ? OutlineButton(
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
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
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
          ],
        ),
      ),
    );
  }
}
