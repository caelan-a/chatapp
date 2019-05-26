import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'message.dart';
import '../contact.dart';
import 'package:flutter/scheduler.dart';

class ChatWindow extends StatefulWidget {
  TabController parentTabController;

  final String groupChatId;
  Contact peer;
  Contact localUser;

  final Color localUserColor = Colors.blue[300];
  final Color remoteUserCOlor = Colors.green[300];

  ChatWindow({@required this.groupChatId, @required this.parentTabController}) {
    localUser = Contact(username: "Caelan", avatarURL: "", lastContacted: DateTime.now());
    peer = Contact(
        username: "John",
        avatarURL:
            "https://media.licdn.com/dms/image/C5603AQEPfzcv_X-kcw/profile-displayphoto-shrink_200_200/0?e=1564012800&v=beta&t=cxHyt4d9MIFI8y2SML3cdkjdplS5Ig8AuwI7MsP5qD0",
        lastContacted: DateTime.now());
  }

  @override
  State createState() => _ChatWindowState();
}

const VIDEO_WINDOW_TAB_INDEX = 1;

class _ChatWindowState extends State<ChatWindow> with TickerProviderStateMixin {
  final FocusNode textEditFocusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isLoading = true;

  List<Message> messageList = <Message>[
    Message(
        type: MessageType.text,
        idFrom: "John",
        idTo: "me",
        timestamp: DateTime.now(),
        content: "Hello how are you")
  ];

  bool isUsersLastMessage(String userId, messageIndex) {
    bool isLastMessage = true;
    int index = messageList.length - 1 - messageIndex;
    List<Message> orderedList = messageList.reversed.toList();

    if (index < orderedList.length - 1) {
      for (int i = index + 1; i < orderedList.length; i++) {
        if (orderedList[i].idFrom == userId) {
          isLastMessage = false;
        }
      }
    }
    print("Message #$messageIndex: $isLastMessage ($userId)");
    return isLastMessage;
  }

  void sendPeerMessage(dynamic content, MessageType type) {
    if (content.trim() != '') {
      textEditingController.clear();

      setState(() {
        messageList.add(Message(
            type: type,
            idFrom: widget.peer.username,
            idTo: widget.localUser.username,
            timestamp: DateTime.now(),
            content: content));
        messageList.sort();
      });

      SchedulerBinding.instance.addPostFrameCallback((_) {
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 500), curve: Curves.easeInOutCirc);
      });
    }
  }

  void onSendMessage(dynamic content, MessageType type) {
    if (content.trim() != '') {
      textEditingController.clear();

      setState(() {
        messageList.add(Message(
            type: type,
            idFrom: widget.localUser.username,
            idTo: widget.peer.username,
            timestamp: DateTime.now(),
            content: content));
        messageList.sort();
      });

      SchedulerBinding.instance.addPostFrameCallback((_) {
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 500), curve: Curves.easeInOutCirc);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.grey[600],
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.peer.username,
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.videocam),
            color: Colors.grey[600],
            onPressed: () {
                widget.parentTabController.animateTo(VIDEO_WINDOW_TAB_INDEX);
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildMessageList(),

              // Input content
              buildInput(),
            ],
          ),

          // // Loading
          // buildLoading()
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: () {
                  sendPeerMessage(textEditingController.text, MessageType.text);
                },
                color: Colors.grey[500],
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onChanged: (s) {
                  setState(() {});
                },
                style: TextStyle(color: Colors.grey[800], fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: textEditFocusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => onSendMessage(
                      textEditingController.text, MessageType.text),
                  color: textEditingController.text.isEmpty
                      ? Colors.grey[500]
                      : widget.localUserColor),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildMessageList() {
    return Expanded(
      child: widget.groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor)))
          : ListView.builder(
              padding: EdgeInsets.all(10.0),
              controller: listScrollController,
              itemCount: messageList.length,
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (context, index) {
                DateTime timestamp = messageList[index].timestamp;
                Contact fromContact =
                    messageList[index].idFrom == widget.localUser.username
                        ? widget.localUser
                        : widget.peer;
                bool fromLocalUser =
                    fromContact.username == widget.localUser.username;
                dynamic content = messageList[index].content;
                MessageType messageType = messageList[index].type;

                return MessageTile(
                  chatWindow: widget,
                  timestamp: timestamp,
                  fromContact: fromContact,
                  fromLocalUser: fromLocalUser,
                  content: content,
                  type: messageType,
                  isUsersLastMessage:
                      isUsersLastMessage(fromContact.username, index),
                );
              },
            ),
    );
  }
}
