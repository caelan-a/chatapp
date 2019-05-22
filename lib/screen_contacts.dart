import 'package:flutter/material.dart';
import 'login_background.dart';

class Contact {
  String username;
  String avatarURL;
  int lastContacted; // Change to datetime

  Contact({this.username, this.avatarURL, this.lastContacted});
}

class ContactsScreen extends StatefulWidget {
  ContactsScreen({Key key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> contacts = [
    Contact(
        username: "Caelan",
        avatarURL:
            "http://gravatar.com/avatar/db3169a8e59167940a271dbd078388e8",
        lastContacted: 1),
    Contact(
        username: "Johnathon",
        avatarURL:
            "http://gravatar.com/avatar/db3169a8e59167940a271dbd078388e8",
        lastContacted: 2),
  ];

  Widget _buildContactList() {
    List<Widget> tiles = [];
    tiles.add(
      Container(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 0.0),
        child: Text(
          'CONTACTS',
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16.0,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
    tiles.addAll(contacts.map((Contact contact) {
      return Column(children: <Widget>[
        _buildContactTile(
            contact.username, contact.avatarURL, contact.lastContacted),
        Container(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
          child: Divider(
            indent: 95.0,
          ),
        )
      ]);
    }));

    return ListView(children: tiles);
  }

  Widget _buildContactTile(
      String username, String avatarURL, int lastContacted) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Image.asset(
            "assets/0.jpg",
            fit: BoxFit.cover,
            // height: 60.0,
            // width: 100.0,
          ),
        ),
        title: Text(
          username,
          style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 24.0,
              color: Colors.grey[600]),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Last called 12/04/10",
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                    color: Colors.grey[600])),
          ],
        ),
        trailing: Icon(
          Icons.videocam,
          color: Colors.grey[600],
          size: 30.0,
        ),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Image.asset(
            'assets/chat_app.png',
            scale: 0.5,
          ),
          leading: IconButton(
            iconSize: 24.0,
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.grey[600],
            ),
            onPressed: () {},
          ),
          actions: <Widget>[
            Icon(
              Icons.person_add,
              color: Colors.grey[600],
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
            )
          ]),
      body: _buildContactList(),
    );
  }
}
