import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_webrtc/webrtc.dart';
import '../user_data.dart';
import 'handler_webrtc.dart';
import 'package:flutter/foundation.dart';

class Call {
  var id;
  var description;
  var media;

  var fromUsername;
  var fromVisibleName;
  var fromAvatarBase64;

  var sessionID;

  Call(
      {this.id,
      this.description,
      this.media,
      this.fromAvatarBase64,
      this.fromUsername,
      this.fromVisibleName,
      this.sessionID});
}

enum SignalingState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

/*
 * callbacks for Signaling API.
 */
typedef void SignalingStateCallback(SignalingState state);
typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);
typedef void DataChannelMessageCallback(
    RTCDataChannel dc, RTCDataChannelMessage data);
typedef void DataChannelCallback(RTCDataChannel dc);

class Signaling {
  String _selfId;
  var _socket;
  var _sessionId;
  var _host;
  var _port = 4443;
  var _displayName;
  var _peerConnections = new Map<String, RTCPeerConnection>();
  var _dataChannels = new Map<String, RTCDataChannel>();
  MediaStream _localStream;
  List<MediaStream> _remoteStreams;
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  OtherEventCallback onPeersUpdate;
  DataChannelMessageCallback onDataChannelMessage;
  DataChannelCallback onDataChannel;

  Call latestCall;

  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      /*
       * turn server configuration example.
      {
        'url': 'turn:123.45.67.89:3478',
        'username': 'change_to_real_user',
        'credential': 'change_to_real_secret'
      },
       */
    ]
  };

  Call getLatestCall() {
    return latestCall;
  }

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> _dc_constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  Signaling(this._host, this._displayName, this._selfId);

  close() {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    _peerConnections.forEach((key, pc) {
      pc.close();
    });
    if (_socket != null) _socket.close();
  }

  void switchCamera() {
    if (_localStream != null) {
      _localStream.getVideoTracks()[0].switchCamera();
    }
  }

  void invite(
      String peer_id, String media, bool use_screen, UserData userData) {
    this._sessionId = this._selfId + '-' + peer_id;

    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateRinging);
    }

    _createPeerConnection(peer_id, media, false).then((pc) {
      _peerConnections[peer_id] = pc;
      if (media == 'data') {
        _createDataChannel(peer_id, pc);
      }
      _createOffer(peer_id, pc, media, "@" + userData.username,
          userData.visibleName, userData.getBase64Avatar());
    });
  }

  void bye() {
    _send('bye', {
      'session_id': this._sessionId,
      'from': this._selfId,
    });
  }

  void acceptInvite() {
    var id = latestCall.id;
    var media = latestCall.media;
    var description = latestCall.description;

    print("\n\nACCEPT INVITE\n\n");
    _createPeerConnection(id, media, false).then((pc) {
      _peerConnections[id] = pc;
      pc.setRemoteDescription(
          new RTCSessionDescription(description['sdp'], description['type']));

      print("\n\nCREATE ANSWER\n\n");
      _createAnswer(id, pc, media);
    });

    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateConnected);
    }
  }

  void onServerMessage(message) async {
    Map<String, dynamic> mapData = message;
    var data = mapData['data'];

    switch (mapData['type']) {
      case 'peers':
        {
          List<dynamic> peers = data;
          if (this.onPeersUpdate != null) {
            Map<String, dynamic> event = new Map<String, dynamic>();
            event['self'] = _selfId;
            event['peers'] = peers;
            this.onPeersUpdate(event);
          }
        }
        break;
      case 'offer':
        {
          var id = data['from'];
          var description = data['description'];
          var media = data['media'];

          String fromUsername = description['from_username'];
          String fromVisibleName = description['from_visible_name'];
          String fromAvatarBase64 = description['from_avatar_base64'];

          var sessionId = data['session_id'];

          latestCall = Call(
            description: description,
            id: id,
            media: media,
            fromUsername: fromUsername,
            fromVisibleName: fromVisibleName,
            fromAvatarBase64: fromAvatarBase64,
            sessionID: sessionId,
          );

          print("Offer from $fromUsername");

          this._sessionId = sessionId;

          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateInvite);
          }
        }
        break;
      case 'answer':
        {
          var id = data['from'];
          var description = data['description'];

          //  User info
          var fromUsername = description['from_username'];
          var fromVisibleName = description['from_visible_name'];
          var fromAvatarBase64 = description['from_avatar_base64'];
          var sessionId = data['session_id'];

          latestCall = Call(
            description: description,
            id: id,
            fromUsername: fromUsername,
            fromVisibleName: fromVisibleName,
            fromAvatarBase64: fromAvatarBase64,
            sessionID: sessionId,
          );

          var pc = _peerConnections[id];
          if (pc != null) {
            pc.setRemoteDescription(new RTCSessionDescription(
                description['sdp'], description['type']));
          }

          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateConnected);
          }
        }
        break;
      case 'candidate':
        {
          var id = data['from'];
          var candidateMap = data['candidate'];
          var pc = _peerConnections[id];

          if (pc != null) {
            RTCIceCandidate candidate = new RTCIceCandidate(
                candidateMap['candidate'],
                candidateMap['sdpMid'],
                candidateMap['sdpMLineIndex']);
            pc.addCandidate(candidate);
          }
        }
        break;
      case 'leave':
        {
          var id = data;
          _peerConnections.remove(id);
          _dataChannels.remove(id);

          if (_localStream != null) {
            _localStream.dispose();
            _localStream = null;
          }

          var pc = _peerConnections[id];
          if (pc != null) {
            pc.close();
            _peerConnections.remove(id);
          }
          this._sessionId = null;
          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateBye);
          }
        }
        break;
      case 'bye':
        {
          var from = data['from'];
          var to = data['to'];
          var sessionId = data['session_id'];
          print('bye: ' + sessionId);

          if (_localStream != null) {
            _localStream.dispose();
            _localStream = null;
          }

          var pc = _peerConnections[to];
          if (pc != null) {
            pc.close();
            _peerConnections.remove(to);
          }

          var dc = _dataChannels[to];
          if (dc != null) {
            dc.close();
            _dataChannels.remove(to);
          }

          this._sessionId = null;
          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateBye);
          }
        }
        break;
      case 'keepalive':
        {
          print('keepalive response!');
        }
        break;
      default:
        break;
    }
  }

  Future<WebSocket> _connectForSelfSignedCert(String host, int port) async {
    try {
      Random r = new Random();
      String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));
      SecurityContext securityContext = new SecurityContext();
      HttpClient client = HttpClient(context: securityContext);
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        print('Allow self-signed certificate => $host:$port. ');
        return true;
      };

      HttpClientRequest request = await client.getUrl(
          Uri.parse('https://$host:$port/ws')); // form the correct url here
      request.headers.add('Connection', 'Upgrade');
      request.headers.add('Upgrade', 'websocket');
      request.headers.add(
          'Sec-WebSocket-Version', '13'); // insert the correct version here
      request.headers.add('Sec-WebSocket-Key', key.toLowerCase());

      HttpClientResponse response = await request.close();
      Socket socket = await response.detachSocket();
      var webSocket = WebSocket.fromUpgradedSocket(
        socket,
        protocol: 'signaling',
        serverSide: false,
      );

      return webSocket;
    } catch (e) {
      throw e;
    }
  }

  void connect() async {
    try {
      /*
      var url = 'ws://$_host:$_port';
      _socket = await WebSocket.connect(url);
      */
      _socket = await _connectForSelfSignedCert(_host, _port);

      if (this.onStateChange != null) {
        this.onStateChange(SignalingState.ConnectionOpen);
      }

      _socket.listen((data) {
        // debugPrint('Received Server Message: ' + data);
        this.onServerMessage(jsonDecode(data));
      }, onDone: () {
        print('Closed by server!');
        if (this.onStateChange != null) {
          this.onStateChange(SignalingState.ConnectionClosed);
        }
      });

      // Send new to connect to server
      _send('new', {
        'name': _displayName,
        'id': _selfId,
        'user_agent':
            'flutter-webrtc/' + Platform.operatingSystem + '-plugin 0.0.1'
      });
    } catch (e) {
      if (this.onStateChange != null) {
        this.onStateChange(SignalingState.ConnectionError);
      }
    }
  }

  Future<MediaStream> createStream(media, user_screen) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    MediaStream stream = user_screen
        ? await navigator.getDisplayMedia(mediaConstraints)
        : await navigator.getUserMedia(mediaConstraints);
    if (this.onLocalStream != null) {
      this.onLocalStream(stream);
    }
    return stream;
  }

  _createPeerConnection(id, media, user_screen) async {
    if (media != 'data') _localStream = await createStream(media, user_screen);
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    if (media != 'data') pc.addStream(_localStream);
    pc.onIceCandidate = (candidate) {
      _send('candidate', {
        'to': id,
        'candidate': {
          'sdpMLineIndex': candidate.sdpMlineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
        'session_id': this._sessionId,
      });
    };

    pc.onIceConnectionState = (state) {};

    pc.onAddStream = (stream) {
      if (this.onAddRemoteStream != null) this.onAddRemoteStream(stream);
      // _remoteStreams.add(stream);
    };

    pc.onRemoveStream = (stream) {
      if (this.onRemoveRemoteStream != null) this.onRemoveRemoteStream(stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }

  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      if (this.onDataChannelMessage != null)
        this.onDataChannelMessage(channel, data);
    };
    _dataChannels[id] = channel;

    if (this.onDataChannel != null) this.onDataChannel(channel);
  }

  _createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  _createOffer(
      String id,
      RTCPeerConnection pc,
      String media,
      String fromUsername,
      String fromVisibleName,
      String fromAvatarBase64) async {
    try {
      RTCSessionDescription s = await pc
          .createOffer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);
      _send('offer', {
        'to': id,
        'description': {
          'sdp': s.sdp,
          'type': s.type,
          'from_username': fromUsername,
          'from_visible_name': fromVisibleName,
          'from_avatar_base64': fromAvatarBase64,
        },
        'session_id': this._sessionId,
        'media': media,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _createAnswer(String id, RTCPeerConnection pc, media) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);
      print("\n\n SEND ANSWER \n\n");
      _send('answer', {
        'to': id,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': this._sessionId,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _send(event, data) {
    data['type'] = event;
    JsonEncoder encoder = new JsonEncoder();
    if (_socket != null) _socket.add(encoder.convert(data));
    // print('send: ' + encoder.convert(data));
  }
}
