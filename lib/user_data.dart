import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';
import 'contact.dart';
import 'dart:io';
import 'dart:convert';

class UserData {
  String username;
  String avatarURL;
  String authHeader;

  List<Contact> savedContacts;

  UserData({this.username, password, this.authHeader, this.savedContacts}) {}

  void saveContact(Contact contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!savedContacts.contains(contact)) {
      savedContacts.add(contact);
    }
    prefs.setStringList(username + "_contacts",
        savedContacts.map((c) => jsonEncode(c.toJson())));
  }

  static Future<List<Contact>> loadContacts(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs
        .getStringList(username + "_contacts")
        .map((rawJson) => Contact.fromJson(jsonDecode(rawJson)))
        .toList();
  }

  Future<bool> localUserExists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("username");
  }

  static UserData autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //  local user exists
    if (prefs.containsKey("username")) {
      String username = prefs.getString("username");
      String password = prefs.getString("password");
      List<Contact> contacts;

      Map<String, String> response =
          await Database.sendLoginRequest(username, password);

      if (response['success'] == "true") {
        String authHeader = response['authHeader'];

        //  Load contacts
        if (prefs.containsKey(username + "_contacts")) {
          contacts = await loadContacts(username);
        } else {
          contacts = [];
        }
      }
      return UserData(
        username: username,
        authHeader: authHeader,
        savedContacts:
      );
    }
  }
}
