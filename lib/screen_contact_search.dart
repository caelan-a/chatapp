import 'package:flutter/material.dart';
import 'login_background.dart';
import 'package:intl/intl.dart';
import 'screen_call.dart';
import 'contact.dart';
import 'user_data.dart';
import 'database.dart';
import 'main.dart';

class ContactSearchScreen extends StatefulWidget {
  UserData userData;

  ContactSearchScreen({Key key, @required this.userData}) : super(key: key);

  @override
  _ContactSearchScreenState createState() => _ContactSearchScreenState();
}

class _ContactSearchScreenState extends State<ContactSearchScreen> {
  bool loading = false;

  TextEditingController searchController = TextEditingController();
  List<Contact> returnedContacts = [];
  List<Contact> contactsToShow = [];

  Future<void> searchContacts(String searchString) async {
    setState(() {
      loading = true;
    });
    return Database.searchContacts(searchController.text)
        .then((contacts) async {
      returnedContacts = contacts;

      contactsToShow = widget.userData.savedContacts;

      returnedContacts.forEach((Contact c) {
        String username = c.username;

        bool isNewContact = true;
        widget.userData.savedContacts.forEach((Contact savedC) {
          String usernameSavedC = savedC.username;

          if (usernameSavedC == username) {
            isNewContact = false;
          }
        });

        if (isNewContact) {
          contactsToShow.add(c);
        }
      });
    });
  }

  Widget _buildContactList() {
    List<Widget> tiles;

    tiles.addAll(contactsToShow.map((Contact contact) {
      return Column(children: <Widget>[
        _buildContactTile(contact.username, contact.avatarURL,
            contact.lastContacted, contact.requestSent),
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
      DateTime lastContacted, bool requestSent) {
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
        trailing: requestSent
            ? Icon(
                Icons.check,
                color: Colors.grey[600],
                size: 30.0,
              )
            : Icon(
                Icons.person_add,
                color: Colors.grey[600],
                size: 30.0,
              ),
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
        title: Container(
          child: TextFormField(
            textInputAction: TextInputAction.next,
            controller: searchController,
            decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                alignLabelWithHint: true,
                hintStyle: TextStyle()),
            keyboardType: TextInputType.emailAddress,
            onEditingComplete: () async {
              searchContacts(searchController.text).then((v) {
                setState(() {
                  loading = false;
                });
              });
            },
            // focusNode: usernameFN,
            // onFieldSubmitted: (text) =>
            //     FocusScope.of(context).requestFocus(passwordFN),
          ),
        ),
        leading: IconButton(
          iconSize: 24.0,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey[600],
          ),
          onPressed: () {
            Main.popScreens(context, 1);
          },
        ),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor)))
          : _buildContactList(),
    );
  }
}
