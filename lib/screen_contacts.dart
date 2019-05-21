import 'package:flutter/material.dart';
import 'login_background.dart';

class Contact {
  String username;
  String avatarURL;
  int lastContacted; // Change to datetime

}

class ContactsScreen extends StatefulWidget {
  ContactsScreen({Key key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> contacts;

  Widget _buildContactList() {
    List<Widget> tiles;
    tiles.add(Text('Contacts'));
    tiles.addAll(contacts.map((Contact contact) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildContactTile(
              contact.username, contact.avatarURL, contact.lastContacted)
        ],
      );
    }));

    return ListView(children: tiles);
  }

  Widget _buildContactTile(
      String username, String avatarURL, int lastContacted) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(3.0),
          child: Image.asset(
            avatarURL,
            fit: BoxFit.cover,
            height: 60.0,
            width: 100.0,
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
        trailing: Row(
          children: <Widget>[
            Icon(
              Icons.call,
              color: Colors.grey[400],
              size: 20.0,
            ),
            Icon(
              Icons.message,
              color: Colors.grey[400],
              size: 20.0,
            ),
          ],
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
        centerTitle: true,
        title: Image.asset('assets/chat_app.png'),
        leading: Icon(Icons.add),
      ),
      body: _buildContactList(),
    );
  }
}
