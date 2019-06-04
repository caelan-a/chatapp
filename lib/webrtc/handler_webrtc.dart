import 'package:chatapp/user_data.dart';

import '../webrtc/signaling.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:core';
import 'signaling.dart';
import 'package:flutter_webrtc/webrtc.dart';

//  Images in base64
enum RTCMessageType {
  chatMessage,
  userDetails,
}

class RTCChatMessage {
  String content;
}

class RTCUserDetailsMessage {
  String username;
  String visibleName;
  String base64Avatar;

  //  Whether user is calling or accepting friend request
  //  'accept_request', 'call_request'
  String intent;

  RTCUserDetailsMessage({
    this.username,
    this.visibleName,
    this.base64Avatar,
    this.intent,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "visible_name": visibleName,
      "base_64_avatar": base64Avatar,
      "intent": intent,
    };
  }

  toString() {
    return visibleName + "(" + username + ")" + " wants to " + intent;
  }

  factory RTCUserDetailsMessage.fromJson(Map<String, dynamic> json) {
    return RTCUserDetailsMessage(
      username: json['username'],
      base64Avatar: json['base_64_avatar'],
      visibleName: json['visible_name'],
      intent: json['intent'],
    );
  }
}

class RTCHandler {
  String serverIp;
  Signaling _signaling; // used to communicate and listen to server
  Function(String, String, String) onIncomingCall;
  Function onEndCall;
  List<dynamic> _peers;
  var _selfId;
  UserData userData;
  RTCDataChannel _dataChannel;

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  bool _isBeingCalled = false;
  bool _isInCall = false;
  bool _isRequestingCall = false;

  RTCHandler(String serverIp, UserData userData,
      Function(String, String, String) onIncomingCall, Function onEndCall) {
    this.userData = userData;
    this.serverIp = serverIp;
    this.onIncomingCall = onIncomingCall;
    this.onEndCall = onEndCall;
  }

  //  Starts media streams
  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void disposeRenderers() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  RTCVideoRenderer getLocalRenderer() {
    return _localRenderer;
  }

  RTCVideoRenderer getRemoteRenderer() {
    return _remoteRenderer;
  }

  void switchCamera() {
    _signaling.switchCamera();
  }

  void makeCall(String usernameToCall, var media, bool use_screen) {
    if (_signaling != null) {
      _signaling.invite(usernameToCall, media, use_screen, userData);
    }
  }

  void acceptCall() {
    if (_signaling != null) {
      _signaling.acceptInvite(_signaling.latestInvite.fromUsername,
          _signaling.latestInvite.media, _signaling.latestInvite.description);
    }
  }

  void hangUp() {
    if (_signaling != null) {
      _signaling.bye();
    }
  }

  bool isBeingCalled() {
    return _isBeingCalled;
  }

  bool isInCall() {
    return _isInCall;
  }

  bool isRequestingCall() {
    return _isRequestingCall;
  }

  void disconnectFromServer() {
    if (_signaling != null) _signaling.close();
  }

  void handleMessage(String messageStr) {
    Map<String, dynamic> json = jsonDecode(messageStr);
    if (json['type'] == 'user_details') {
      RTCUserDetailsMessage userDetailsMessage =
          RTCUserDetailsMessage.fromJson(json);
      print(userDetailsMessage);
    }
  }

  bool isUserOnline(String username) {
    if(_peers != null) {
      
    } else {
      //  No peers => not connected
      return false;
    }
  }

  void connectToServer(String serverIP, String displayName, String username) {
    if (_signaling == null) {
      _signaling = new Signaling(serverIP, displayName, username)..connect();

      //  setup messaging
      //  format is json
      _signaling.onDataChannelMessage = (dc, RTCDataChannelMessage data) {
        if (data.isBinary) {
          print('Got binary [' + data.binary.toString() + ']');
        } else {
          handleMessage(data.text);
        }
      };

      _signaling.onDataChannel = (channel) {
        _dataChannel = channel;
      };

      _signaling.onStateChange = (SignalingState state) {
        _isBeingCalled = false;
        _isInCall = false;

        switch (state) {
          case SignalingState.CallStateNew:
            // onIncomingCall();
            break;
          case SignalingState.CallStateBye:
            onEndCall();

            break;
          case SignalingState.CallStateInvite:
            onIncomingCall(
                _signaling.latestInvite.fromVisibleName,
                _signaling.latestInvite.fromUsername,
                _signaling.latestInvite.fromAvatarBase64);

            _isBeingCalled = true;
            break;
          case SignalingState.CallStateConnected:
            _isInCall = true;
            print("CALL CONNECTED");
            break;
          case SignalingState.CallStateRinging:
            _isRequestingCall = true;
            break;
          case SignalingState.ConnectionClosed:
          case SignalingState.ConnectionError:

          case SignalingState.ConnectionOpen:
            break;
        }
      };

      //  Handle renderers
      _signaling.onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
      });

      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
      });

      _signaling.onPeersUpdate = ((event) {
        _selfId = event['self'];
        _peers = event['peers'];
      });
    }
  }
}
