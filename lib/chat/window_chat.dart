import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'message.dart';
import '../contact.dart';

class ChatWindow extends StatefulWidget {
  final String groupChatId;
  Contact peer;
  Contact localUser;

  final Color localUserColor = Colors.grey;
  final Color remoteUserCOlor = Colors.blue;

  ChatWindow({@required this.groupChatId}) {
    localUser = Contact(username: "Caelan", avatarURL: "", lastContacted: 0);
    peer = Contact(username: "John", avatarURL: "", lastContacted: 0);
  }

  @override
  State createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> with TickerProviderStateMixin {
  final FocusNode textEditFocusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isLoading = true;

  List<Message> messageList = [
    Message(
        type: MessageType.text,
        idFrom: "John",
        idTo: "me",
        timestamp: DateTime.now(),
        content: "Hello how are you")
  ];

  Future<bool> onBackPress() {
    bool showWarning = true;

    if (showWarning) {
      setState(() {
        showWarning = false;
        // showWarning
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  void onSendMessage(dynamic content, MessageType type) {
    if (content.trim() != '') {
      textEditingController.clear();

      messageList.add(Message(
          type: type,
          idFrom: widget.localUser.username,
          idTo: widget.peer.username,
          timestamp: DateTime.now(),
          content: content));

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack();
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
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
                onPressed: () {},
                color: Theme.of(context).primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Theme.of(context).canvasColor),
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
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Theme.of(context).primaryColor,
              ),
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

  Widget buildListMessage() {
    return Flexible(
      child: widget.groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)))
          : ListView.builder(
              itemBuilder: (context, snapshot) {
                if (!isLoading) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
                } else {

                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                        DateTime timestamp = messageList[index].timestamp;
                        Contact fromContact = Contact(username: messageList[index].idFrom,
                        avatarURL: messageList[index].avatarURLFrom, lastContacted: 0);
                        bool fromLocalUser = fromContact.username == widget.localUser.username;
                        dynamic content = messageList[index].content;
                        MessageType messageType = messageList[index].type;

                        return MessageTile(timestamp: timestamp,fromContact: fromContact, fromLocalUser: fromLocalUser, content: content, type: messageType, );
                    }
                    itemCount: messageList.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}
