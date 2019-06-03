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


class CallSample extends StatefulWidget {
  static String tag = 'call_sample';
  final String ip;
  UserData userData;
  Contact contact;
  TabController tabController;


  CallSample({Key key, @required this.ip, @required this.userData, @required this.contact, @required this.tabController}) : super(key: key);

  @override
  _CallSampleState createState() => new _CallSampleState(serverIP: ip);
}

class _CallSampleState extends State<CallSample> {
  Signaling _signaling;
  String _displayName;
  List<dynamic> _peers;
  var _selfId;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
  bool _inCalling = false;
  final String serverIP;

  _CallSampleState({Key key, @required this.serverIP});

  Widget _buildCallingScreen() {
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
              "Connecting with..",
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
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.white),
                  shape: new RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white),
                      borderRadius: new BorderRadius.circular(30.0)),
                  textColor: Colors.white,
                  onPressed: () {

                  },
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.call_end),
                      Text("   End Call"),
                    ],
                  ),
                )),
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
        ],
      ),
    );
  }

  @override
  initState() {
    super.initState();

    _displayName = widget.userData.visibleName;
    _selfId = "@" + widget.userData.username;

    initRenderers();
    _connect();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  deactivate() {
    super.deactivate();
    if (_signaling != null) _signaling.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void _connect() async {
    if (_signaling == null) {
      _signaling = new Signaling(serverIP, _displayName)
        ..connect();

      _signaling.onStateChange = (SignalingState state) {
        switch (state) {
          case SignalingState.CallStateNew:
            this.setState(() {
              _inCalling = true;
            });
            break;
          case SignalingState.CallStateBye:
            this.setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              _inCalling = false;
            });
            break;
          case SignalingState.CallStateInvite:
          case SignalingState.CallStateConnected:
          case SignalingState.CallStateRinging:
          case SignalingState.ConnectionClosed:
          case SignalingState.ConnectionError:
          case SignalingState.ConnectionOpen:
            break;
        }
      };

      _signaling.onPeersUpdate = ((event) {
        this.setState(() {
          _selfId = event['self'];
          _peers = event['peers'];
        });
      });

      _signaling.onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
      });

      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
      });
    }
  }

  _invitePeer(context, peerId, use_screen) async {
    if (_signaling != null && peerId != _selfId) {
      _signaling.invite(peerId, 'video', use_screen);
    }
  }

  _hangUp() {
    if (_signaling != null) {
      _signaling.bye();
    }
  }

  _switchCamera() {
    _signaling.switchCamera();
  }

  _muteMic() {

  }

  _buildRow(context, peer) {
    var self = (peer['id'] == _selfId);
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(self
            ? peer['name'] + '[Your self]'
            : peer['name'] + '[' + peer['user_agent'] + ']'),
        onTap: null,
        trailing: new SizedBox(
            width: 100.0,
            child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.videocam),
                    onPressed: () => _invitePeer(context, peer['id'], false),
                    tooltip: 'Video calling',
                  ),
                  IconButton(
                    icon: const Icon(Icons.screen_share),
                    onPressed: () => _invitePeer(context, peer['id'], true),
                    tooltip: 'Screen sharing',
                  )
                ])),
        subtitle: Text('id: ' + peer['id']),
      ),
      Divider()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('P2P Call Sample'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: null,
            tooltip: 'setup',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _inCalling
          ? new SizedBox(
            width: 200.0,
            child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton(
                    child: const Icon(Icons.switch_camera),
                    onPressed: _switchCamera,
                  ),
                  FloatingActionButton(
                    onPressed: _hangUp,
                    tooltip: 'Hangup',
                    child: new Icon(Icons.call_end),
                    backgroundColor: Colors.pink,
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.mic_off),
                    onPressed: _muteMic,
                  )
                ])) : null,
      body: _inCalling
          ? OrientationBuilder(builder: (context, orientation) {
              return new Container(
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
                        decoration: new BoxDecoration(color: Colors.black54),
                      )),
                  new Positioned(
                    left: 20.0,
                    top: 20.0,
                    child: new Container(
                      width: orientation == Orientation.portrait ? 90.0 : 120.0,
                      height:
                          orientation == Orientation.portrait ? 120.0 : 90.0,
                      child: new RTCVideoView(_localRenderer),
                      decoration: new BoxDecoration(color: Colors.black54),
                    ),
                  ),
                ]),
              );
            })
          : new ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              itemCount: (_peers != null ? _peers.length : 0),
              itemBuilder: (context, i) {
                return _buildRow(context, _peers[i]);
              }),
    );
  }
}
