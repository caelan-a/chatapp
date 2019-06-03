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

  RTCHandler(String serverIp, UserData userData, Function(String, String, String) onIncomingCall,
      Function onEndCall) {
    this.userData = userData;
    this.serverIp = serverIp;
    this.onIncomingCall = onIncomingCall;
    this.onEndCall = onEndCall;
  }

  void switchCamera() {
    _signaling.switchCamera();
  }

    // void invitePeerToMessage(peerId, use_screen) async {
    //   if (_signaling != null && peerId != _selfId) {
    //     _signaling.invite(peerId, 'data', use_screen);
    //   }
    // }

  void hangUp() {
    if (_signaling != null) {
      _signaling.bye();
    }
  }

  //  Used to link local media streams to server
  void initStreams(
      RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer) {
    if (_signaling == null) {
      _signaling.onLocalStream = ((stream) {
        localRenderer.srcObject = stream;
      });

      _signaling.onAddRemoteStream = ((stream) {
        remoteRenderer.srcObject = stream;
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        remoteRenderer.srcObject = null;
      });
    } else {
      print("RTC Handler not initialised..");
    }
  }

  void disconnectFromServer() {
    if (_signaling != null) _signaling.close();
  }

  void sendUserDetails() {
    String userDetailsMessage = jsonEncode(RTCUserDetailsMessage(
      username: userData.username,
      visibleName: userData.visibleName,
      base64Avatar: userData.getBase64Avatar(),
      intent: "call_request",
    ));
    _dataChannel.send(RTCDataChannelMessage(userDetailsMessage));
  }

  // void sendCallRequest(String peerId, bool use_screen) {
  //   invitePeerToMessage(peerId, use_screen);
  //   sendUserDetails();
  // }

  void handleMessage(String messageStr) {
    Map<String, dynamic> json = jsonDecode(messageStr);
    if (json['type'] == 'user_details') {
      RTCUserDetailsMessage userDetailsMessage =
          RTCUserDetailsMessage.fromJson(json);
      print(userDetailsMessage);
    }
  }

  void connectToServer(String serverIP, String displayName, String username) {
    if (_signaling == null) {
      _signaling = new Signaling(serverIP, displayName,username)..connect();

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
        switch (state) {
          case SignalingState.CallStateNew:
            // onIncomingCall();
            break;
          case SignalingState.CallStateBye:
            onEndCall();
            // this.setState(() {
            //   _localRenderer.srcObject = null;
            //   _remoteRenderer.srcObject = null;
            //   _inCalling = false;
            // });
            break;
          case SignalingState.CallStateInvite:
            //  Received invite
            
          break;  
          case SignalingState.CallStateConnected:
          case SignalingState.CallStateRinging:
          case SignalingState.ConnectionClosed:
          case SignalingState.ConnectionError:
          case SignalingState.ConnectionOpen:
            break;
        }
      };

      _signaling.onPeersUpdate = ((event) {
        _selfId = event['self'];
        _peers = event['peers'];
      });
    }
  }
}
