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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ContactSearchScreen({Key key, @required this.userData}) : super(key: key);

  @override
  _ContactSearchScreenState createState() => _ContactSearchScreenState();
}

class _ContactSearchScreenState extends State<ContactSearchScreen> {
  bool loading = false;

  TextEditingController searchController = TextEditingController();
  List<Contact> returnedContacts = [];
  List<Contact> contactsToShow = [];

  // @override
  // void initState() {

  // }

  void sendFriendRequest(Contact contact) {
    setState(() {
      contact.requestSent = true;
      widget.userData.saveContact(contact);
    });
    widget.scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text("Request sent"),
    ));
  }

  Future<void> searchContacts(String searchString) async {
    setState(() {
      loading = true;
    });
    return Database.searchContacts(searchController.text)
        .then((contacts) async {
      contactsToShow = [];
      print(contacts);
      if (contacts.isNotEmpty) {
        contactsToShow = [];

        contacts.forEach((Contact c) {
          String username = c.username;

          bool isNewContact = true;
          widget.userData.savedContacts.forEach((Contact localC) {
            String localCUsername = localC.username;

            if (localCUsername == username) {
              isNewContact = false;
              contactsToShow.add(localC);
            }
          });

          if (isNewContact) {
            contactsToShow.add(c);
          }
        });
      } else {
        returnedContacts = [];
        contactsToShow = [];
        print("No contacts");
      }
    });
  }

  Widget _buildContactList() {
    return ListView(
        children: contactsToShow.map((Contact contact) {
      return Column(children: <Widget>[
        _buildContactTile(contact.visibleName, contact.username,
            contact.avatarURL, contact.requestSent, contact),
        Container(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
          child: Divider(
            indent: 95.0,
          ),
        )
      ]);
    }).toList());
  }

  Widget _buildContactTile(String name, String username, String avatarPath,
      bool requestSent, Contact contact) {
    return Builder(
        // Create an inner BuildContext so that the onPressed methods
        // can refer to the Scaffold with Scaffold.of().
        builder: (BuildContext context) {
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
                  : Icon(
                      Icons.person,
                      size: 40.0,
                    )),
          title: Text(
            name,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 20.0,
                color: Colors.grey[600]),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  username,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                      fontStyle: FontStyle.normal),
                ),
                margin: EdgeInsets.only(left: 0.0, top: .0, bottom: 5.0),
              )
            ],
          ),
          trailing: IconButton(
            onPressed: () => !requestSent ? sendFriendRequest(contact) : null,
            icon: requestSent
                ? Icon(
                    Icons.check,
                    color: Colors.grey[400],
                    size: 30.0,
                  )
                : Icon(
                    Icons.person_add,
                    color: Colors.grey[400],
                    size: 30.0,
                  ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: widget.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Container(
          child: TextField(
            textInputAction: TextInputAction.done,
            controller: searchController,
            autofocus: true,
            onSubmitted: (d) {},
            decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                alignLabelWithHint: true,
                hintStyle: TextStyle()),
            keyboardType: TextInputType.emailAddress,

            onChanged: (text) async {
              searchContacts(text).then((v) {
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
      body: Builder(builder: (context) {
        return loading
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor)))
            : searchController.text.isNotEmpty
                ? (contactsToShow.isNotEmpty)
                    ? _buildContactList()
                    : Container(
                        padding: EdgeInsets.all(50.0),
                        child: Text(
                          "No results found\n\nPlease check spelling and try again",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.grey[600]),
                        ))
                : Container();
      }),
    );
  }
}
