import 'package:flutter/material.dart';
import 'login_background.dart';
import 'package:intl/intl.dart';
import 'screen_call.dart';
import 'contact.dart';
import 'user_data.dart';
import 'main.dart';
import 'package:chatapp/screen_contact_search.dart';

class ContactsScreen extends StatefulWidget {
  UserData userData;

  ContactsScreen({Key key, @required this.userData}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  void callContact(Contact contact) {
    print("Call contact");
    Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => CallScreen(contact: contact)));
  }

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
    tiles.addAll(widget.userData.savedContacts.map((Contact contact) {
      return Column(children: <Widget>[
        _buildContactTile(contact.username, contact.avatarURL,
            contact.lastContacted, () => callContact(contact)),
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

  Widget _buildContactTile(String username, String avatarPath,
      DateTime lastContacted, Function onCall) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: avatarPath != ""
                ? Image.asset(
                    avatarPath,
                    fit: BoxFit.cover,
                    // height: 60.0,
                    // width: 100.0,
                  )
                : Icon(Icons.person)),
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
            Container(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                "Last Contacted " + DateFormat('dd MMM').format(lastContacted),
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.normal),
              ),
              margin: EdgeInsets.only(left: 3.0, top: .0, bottom: 5.0),
            )
          ],
        ),
        trailing: Icon(
          Icons.videocam,
          color: Colors.grey[600],
          size: 30.0,
        ),
        onTap: () => onCall(),
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
            title: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Image.asset(
                "assets/0.jpg",
                fit: BoxFit.cover,
                height: 35.0,
                width: 35.0,
              ),
            ),
            leading: IconButton(
              iconSize: 24.0,
              icon: Icon(
                Icons.person_add,
                color: Colors.grey[600],
              ),
              onPressed: () {
                Main.toScreen(
                    context, ContactSearchScreen(userData: widget.userData));
              },
            ),
            actions: <Widget>[
              IconButton(
                iconSize: 24.0,
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
              )
            ]),
        body: widget.userData.savedContacts == []
            ? _buildContactList()
            : Container(
                padding: EdgeInsets.all(50.0),
                child: Text(
                  "You currently have no contacts\n\nTap the top left icon to search for people you know",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                )));
  }
}
