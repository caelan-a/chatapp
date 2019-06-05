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
  Function(String, String, String) onCallAccepted;
  List<dynamic> _peers;
  var _selfId;
  UserData userData;
  RTCDataChannel _dataChannel;

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  bool _isBeingCalled = false;
  bool _isInCall = false;
  bool _isRequestingCall = false;

  RTCHandler(
      String serverIp,
      UserData userData,
      Function(String, String, String) onIncomingCall,
      Function onEndCall,
      Function onCallAccepted) {
    this.userData = userData;
    this.serverIp = serverIp;
    this.onIncomingCall = onIncomingCall;
    this.onEndCall = onEndCall;
    this.onCallAccepted = onCallAccepted;
  }

  //  Starts media streams
  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void disposeRenderers() {
    _localRenderer?.dispose();
    _remoteRenderer?.dispose();
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

  Future<void> makeCall(
      String usernameToCall, var media, bool use_screen) async {
    if (_signaling != null) {
      _isRequestingCall = true;
      await initRenderers();
      _signaling.invite(usernameToCall, media, use_screen, userData);
    }
  }

  Future<void> acceptCall() async {
    if (_signaling != null) {
      await initRenderers();
      _signaling.acceptInvite();
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
    if (_peers != null) {
      bool peerOnline = false;
      _peers.forEach((p) {
        bool equal = p['id'] == username;
        if (equal == true) {
          peerOnline = true;
        }
        print("p" + peerOnline.toString());
      });
      return peerOnline;
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
      // _signaling.onDataChannelMessage = (dc, RTCDataChannelMessage data) {
      //   if (data.isBinary) {
      //     print('Got binary [' + data.binary.toString() + ']');
      //   } else {
      //     handleMessage(data.text);
      //   }
      // };

      // _signaling.onDataChannel = (channel) {
      //   _dataChannel = channel;
      // };

      _signaling.onStateChange = (SignalingState state) {
        print("CALL STATE: $state");

        if (state != SignalingState.CallStateBye) {
          _isBeingCalled = false;
          _isInCall = false;
          _isRequestingCall = false;
        }
        switch (state) {
          case SignalingState.CallStateNew:
            break;
          case SignalingState.CallStateBye:
            if (_isInCall || _isBeingCalled || _isRequestingCall) {
              disposeRenderers();
              onEndCall();
              _isBeingCalled = false;
              _isInCall = false;
              _isRequestingCall = false;
              print("\n\n BYE\n\n");
            }
            break;
          case SignalingState.CallStateInvite:
            onIncomingCall(
                _signaling.latestCall.fromVisibleName,
                _signaling.latestCall.fromUsername,
                _signaling.latestCall.fromAvatarBase64);

            _isBeingCalled = true;
            print("\n\n CALL INVITE\n\n");

            break;
          case SignalingState.CallStateConnected:
            _isInCall = true;
            print("\n\n CALL CONNECTED\n\n");
            onCallAccepted(
                _signaling.latestCall.fromVisibleName,
                _signaling.latestCall.fromUsername,
                _signaling.latestCall.fromAvatarBase64);

            break;
          case SignalingState.CallStateRinging:
            _isRequestingCall = true;
            print("\n\n CALL RINGING\n\n");

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
