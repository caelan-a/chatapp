import 'package:flutter/material.dart';
import 'login_background.dart';
import 'package:intl/intl.dart';
import 'screen_call.dart';
import 'contact.dart';

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
            "https://media.licdn.com/dms/image/C5603AQEPfzcv_X-kcw/profile-displayphoto-shrink_200_200/0?e=1564012800&v=beta&t=cxHyt4d9MIFI8y2SML3cdkjdplS5Ig8AuwI7MsP5qD0",
        lastContacted: DateTime.now()),
    Contact(
        username: "Johnathon",
        avatarURL:
            "https://media.licdn.com/dms/image/C5603AQEPfzcv_X-kcw/profile-displayphoto-shrink_200_200/0?e=1564012800&v=beta&t=cxHyt4d9MIFI8y2SML3cdkjdplS5Ig8AuwI7MsP5qD0",
        lastContacted: DateTime.now()),
  ];

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
    tiles.addAll(contacts.map((Contact contact) {
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

  Widget _buildContactTile(
      String username, String avatarURL, DateTime lastContacted, Function onCall) {
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
            onPressed: () {},
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
      body: _buildContactList(),
    );
  }
}
