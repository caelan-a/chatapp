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
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (context) => CallScreen(
              contact: contact,
              initialTab: 1,
            )));
  }

  void messageContact(Contact contact) {
    print("Call contact");
    Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => CallScreen(contact: contact)));
  }

  static void showLogOutWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 00.0),
          titlePadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          title: Text("Logout"),
          content: Text("Are you sure?"),
          actions: <Widget>[
            FlatButton(
              child: new Text("Back"),
              onPressed: () {
                Main.popScreens(context, 1);
              },
            ),
            FlatButton(
              child: new Text("Logout"),
              onPressed: () {
                Main.popScreens(context, 3);
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteContactWarning(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 00.0),
          titlePadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          title: Text("Delete Contact"),
          content:
              Text("Are you sure you want to delete ${contact.visibleName}"),
          actions: <Widget>[
            FlatButton(
              child: new Text("No"),
              onPressed: () {
                Main.popScreens(context, 1);
              },
            ),
            FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                widget.userData.deleteContact(contact);
                setState(() {});
                Main.popScreens(context, 1);
              },
            ),
          ],
        );
      },
    );
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
        _buildContactTile(contact, () => callContact(contact)),
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

  Widget _buildContactTile(Contact contact, Function onCall) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: ListTile(
        enabled: false,
        onLongPress: () {
          showDeleteContactWarning(context, contact);
        },
        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: contact.avatarURL != ""
                ? Image.asset(
                    contact.avatarURL,
                    fit: BoxFit.cover,
                    // height: 60.0,
                    // width: 100.0,
                  )
                : Icon(
                    Icons.person,
                    size: 40.0,
                  )),
        title: Text(
          contact.visibleName,
          style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 20.0,
              color: Colors.grey[600]),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            contact.accepted == true
                ? Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      "Last Contacted " +
                          DateFormat('dd MMM').format(contact.lastContacted),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.normal),
                    ),
                    margin: EdgeInsets.only(left: 3.0, top: .0, bottom: 5.0),
                  )
                : Container(
                    margin: EdgeInsets.only(left: 2.0, top: .0, bottom: 5.0),
                    child: Text(
                      "Pending Request",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.normal),
                    ),
                  ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              onPressed: () {
                messageContact(contact);
              },
              icon: Icon(
                Icons.message,
                color: Colors.grey[600],
                size: 30.0,
              ),
            ),
            // Padding(
            // //   padding: EdgeInsets.all(10.0),
            // // ),
            IconButton(
              onPressed: () {
                callContact(contact);
              },
              icon: Icon(
                Icons.call,
                color: Colors.grey[600],
                size: 30.0,
              ),
            ),
          ],
        ),
        onTap: () => onCall(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
                    showLogOutWarning(context);
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                )
              ]),
          body: widget.userData.savedContacts.isNotEmpty
              ? _buildContactList()
              : Container(
                  padding: EdgeInsets.all(50.0),
                  child: Text(
                    "You currently have no contacts\n\nTap the top left icon to search for people you know",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                  ))),
    );
  }
}
