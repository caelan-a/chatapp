import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_webrtc/webrtc.dart';
import 'random_string.dart';
import '../user_data.dart';

class Invite {
  var id;
  var description;
  var media;

  var fromUsername;
  var fromVisibleName;
  var fromAvatarBase64;

  var sessionID;

  Invite(
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

  Invite latestInvite;

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

  Invite getLatestInvite() {
    return latestInvite;
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
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
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
      this.onStateChange(SignalingState.CallStateNew);
    }

    _createPeerConnection(peer_id, media, use_screen).then((pc) {
      _peerConnections[peer_id] = pc;
      if (media == 'data') {
        _createDataChannel(peer_id, pc);
      }
      _createOffer(peer_id, pc, media, userData.username, userData.visibleName,
          userData.getBase64Avatar());
    });
  }

  void bye() {
    _send('bye', {
      'session_id': this._sessionId,
      'from': this._selfId,
    });
  }

  void acceptInvite(var id, var media, var description) {
    _createPeerConnection(id, media, false).then((pc) {
      _peerConnections[id] = pc;
      pc.setRemoteDescription(
          new RTCSessionDescription(description['sdp'], description['type']));
      _createAnswer(id, pc, media);
    });
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

          var fromUsername = "tester";
          var fromVisibleName = "Mr Tester";
          var fromAvatarBase64 = test_image_b64;

          // var fromUsername = data['from_username'];
          // var fromVisibleName = data['from_visible_name'];
          // var fromAvatarBase64 = data['from_avatar_base64'];

          var sessionId = data['session_id'];

          latestInvite = Invite(
              description: description,
              id: id,
              media: media,
              fromUsername: fromUsername,
              fromVisibleName: fromVisibleName,
              fromAvatarBase64: fromAvatarBase64);
              
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

          var pc = _peerConnections[id];
          if (pc != null) {
            pc.setRemoteDescription(new RTCSessionDescription(
                description['sdp'], description['type']));
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
        print('Received Server Message: ' + data);
        JsonDecoder decoder = new JsonDecoder();
        this.onServerMessage(decoder.convert(data));
      }, onDone: () {
        print('Closed by server!');
        if (this.onStateChange != null) {
          this.onStateChange(SignalingState.ConnectionClosed);
        }
      });

      _send('new', {
        'name': _displayName,
        'id': _selfId,
        'user_agent': 'flutter-webrtc/' + Platform.operatingSystem + '-plugin 0.0.1'
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
      //_remoteStreams.add(stream);
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
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': this._sessionId,
        'media': media,
        'from_username': fromUsername,
        'from_visible_name': fromVisibleName,
        'from_avatar_base64': fromAvatarBase64,
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
    print('send: ' + encoder.convert(data));
  }
}


const String test_image_b64 = "data:image/jpeg;base64,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";
