import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'window_chat.dart';
import '../contact.dart';

enum MessageType { text, image }

class Message {
  final type;
  final String idFrom;
  final String avatarURLFrom;
  final String idTo;
  final String avatarURLTo;
  
  final DateTime timestamp;
  final dynamic content;

  Message({
    @required this.type,
    @required this.idFrom,
    @required this.idTo,
    @required this.timestamp,
    @required this.content,
  });
}

const textStyle = TextStyle(
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSans',
    fontWeight: FontWeight.w600);

class MessageTile extends StatelessWidget {
  final ChatWindow chatWindow;
  final Contact fromContact;

  final bool fromLocalUser;
  final bool isUsersLastMessage;

  final DateTime timestamp;

  final dynamic content;
  final type;

  MessageTile({
    @required this.chatWindow,
    @required this.type,
    @required this.fromContact,
    @required this.fromLocalUser,
    @required this.timestamp,
    @required this.content,
    this.isUsersLastMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    if (fromLocalUser) {
      // Right (my message)
      return Row(
        children: <Widget>[
          type == MessageType.text
              // Text
              ? Container(
                  child: Text(
                    content,
                    style: textStyle,
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isUsersLastMessage ? 20.0 : 10.0, right: 10.0),
                )
              : Container(
                  child: Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            width: 200.0,
                            height: 200.0,
                            padding: EdgeInsets.all(70.0),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) => Material(
                            child: Image.asset(
                              'images/img_not_available.jpeg',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                      imageUrl: content,
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  margin: EdgeInsets.only(
                      bottom: isUsersLastMessage ? 20.0 : 10.0, right: 10.0),
                )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
          child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              isUsersLastMessage
                  ? Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                              width: 35.0,
                              height: 35.0,
                              padding: EdgeInsets.all(10.0),
                            ),
                        imageUrl: fromContact.avatarURL,
                        width: 35.0,
                        height: 35.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(18.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    )
                  : Container(width: 35.0),
              type == MessageType.text
                  ? Container(
                      child: Text(
                        content,
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: 200.0,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8.0)),
                      margin: EdgeInsets.only(left: 10.0),
                    )
                  : Container(
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) => Material(
                                child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                          imageUrl: content,
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      margin: EdgeInsets.only(left: 10.0),
                    )
            ],
          ),
        ],
      ));
    }
  }
}
