import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';


import '../message_widgets/message_widget.dart';
import '../frames/frame_main_image.dart';
import '../widgets/widget_situation_info.dart';

//  Global
import '../application.dart';
import '../database.dart';

final double action_button_vertical_padding = 10.0;
final double action_button_horizontal_padding = 0.0;
final double title_font_size = 34.0;

final Color userColor = Color(Application.colourPalette['primary']);
final Color operatorColor = Color(Application.colourPalette['blue']);
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class Chat extends StatefulWidget {
  @override
  State createState() => ChatWindow();
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  bool _isChatContinued = true; // Whether to show chat or new dialog

  final TextEditingController _inputController = TextEditingController();
  bool _isWriting = false; // Used for checking if user has something to send

  Query _query; // Holds queried database from firebase

  // Create the buttons to appear from the unicorn dial
  List<UnicornButton> childButtons = [];

  @override
  void initState() {
    //  Buttons for bottom input bar
    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Take a photo",
        currentButton: FloatingActionButton(
          heroTag: "camera",
          backgroundColor: userColor,
          foregroundColor: Colors.white,
          mini: true,
          child: Icon(Icons.camera_alt),
          onPressed: () => submitImage("camera"),
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Choose from gallery",
        currentButton: FloatingActionButton(
          heroTag: "gallery",
          backgroundColor: userColor,
          foregroundColor: Colors.white,
          mini: true,
          child: Icon(Icons.image),
          onPressed: () => submitImage("gallery"),
        )));

    isChatContinued();

    super.initState();
  }

  /* Chat initialisation logic */

  void getQuery() {
    //  Get query from firebase database
    Database.queryMessages().then((Query query) {
      //  Used to scroll list to bottom
      setState(() {
        _query = query;
      });
    });
  }

  //  Check whether to resume chat or start new one
  void isChatContinued() async {
    _isChatContinued = await Database.isChatContinued();

    if (_isChatContinued) {
      print("continued");
      getQuery();
    } else {
      print("not continued");
      setState(() {});
    }
  }

  //  Used by initial situation dialog to start chat and then send situation/profile info
  Future initialiseChat(var situationInfoPayload) async {
    await Database.establishNewChat();
    await Database.sendSituationInfo(situationInfoPayload);

    setState(() {
      getQuery();
      _isChatContinued = true;
    });
  }

  //  Allows clicking off keyboard to dismiss
  bool _keyboardVisible = false;
  bool isKeyboardVisible(BuildContext context) {
    double inset = MediaQuery.of(context).viewInsets.bottom;

    if (inset == 0.0) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    Widget messageList;

    if (_query != null) {
      messageList = FirebaseAnimatedList(
          query: _query,
          reverse: true,
          sort: (a, b) => b.key.compareTo(a.key),
          duration: const Duration(
              milliseconds: 1000), //  Duration of message add/remove anim

          //  Build list of messages
          itemBuilder: (
            BuildContext context,
            DataSnapshot snapshot,
            Animation<double> animation,
            int index,
          ) {
            return MessageTile.buildMessage(context: context, snapshot: snapshot, animation: animation, userColor: userColor, operatorColor: operatorColor);
          });
    } else {
      messageList = Center(
        // alignment: Alignment.bottomCenter,
        child: CircularProgressIndicator(
          value: null,
          backgroundColor: Theme.of(context).canvasColor,
        ),
      );
    }

    if (_isChatContinued) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(child: messageList),
                Container(height: 5.0,),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.grey)],
                  ),
                  child: Row(
                    children: <Widget>[

                      // Phone button
                      Container(
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(right: 5.0),
                        child: FloatingActionButton(
                          heroTag: "Call",
                          mini: true,
                          backgroundColor: Colors.white,
                          foregroundColor: userColor,
                          onPressed: () {},
                          child: Icon(
                            Icons.phone,
                          ),
                        ),
                      ),

                      //  Input field
                      Flexible(
                        child: Container(
                          child: new ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 50.0,
                            ),
                            child: new Scrollbar(
                              child: new SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                reverse: true,
                                child: new TextField(
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10.0),
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "Start typing...",
                                    // border: OutlineInputBorder(
                                    //   borderRadius: BorderRadius.circular(50.0),
                                    // ),
                                  ),
                                  controller: _inputController,
                                  onChanged: (String txt) {
                                    setState(() {
                                      _isWriting = txt.length > 0;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      //  Submit Button
                      IconButton(
                        icon: Icon(Icons.send),
                        color: userColor,
                        onPressed: _isWriting
                            ? () => submitMessage(_inputController.text)
                            : null,
                      ),

                      //  Used to make content fit with floating unicorn dial
                      Container(
                        width: 50.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //  Camera
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.fromLTRB(5.0, 0.0, 10.0, 10.0),
                child: UnicornDialer(
                  parentHeroTag: "CameraDial",
                  backgroundColor: Colors.white70,
                  hasBackground: true,
                  parentButtonBackground: Colors.white,
                  parentButton: Icon(
                    Icons.photo_camera,
                    color: userColor,
                  ),
                  childButtons: childButtons,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SituationInfo(startChat: initialiseChat);
    }
  }

  Future submitImage(String source) async {
    File image;

    if (source.contains("gallery")) {
      // image = await ImagePicker.pickImage(source: ImageSource.gallery);
    } else {
      // image = await ImagePicker.pickImage(source: ImageSource.camera);
    }

    print("send image");

    // Database.sendImageMessage(image);
  }

  Future submitMessage(String text) async {
    // Database.sendTextMessage(text);
    _inputController.clear();
    setState(() {
      _isWriting = false;
    });
  }
}
