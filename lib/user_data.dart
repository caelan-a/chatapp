import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';
import 'contact.dart';
import 'dart:io';
import 'dart:convert';

class UserData {
  String visibleName;
  String username;
  String avatarPath;
  String authHeader;
  List<Contact> savedContacts;

  UserData(
      {this.username, this.authHeader, this.savedContacts, this.visibleName}) {}

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
    print("CONTACTS");
    print(prefs.getStringList(username + "_contacts"));
    print("END");

    List<String> contacts_str = prefs.getStringList(username + "_contacts");

    if (contacts_str == null) {
      return [];
    } else {
      return contacts_str
          .map((rawJson) => Contact.fromJson(jsonDecode(rawJson)))
          .toList();
    }
  }

  static Future<bool> localUserExists(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(username);
  }

  static void saveUserData(UserData user) {}

  static void registerUser(String username, String visibleName,
      String authHeader, String avatarPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(username, username);
    prefs.setString(username + "_visibleName", visibleName);
    prefs.setString(username + "_avatarPath", avatarPath);
    prefs.setString(username + "_authHeader", authHeader);

    List<Contact> contacts = [];
    prefs.setStringList(
        username + "_contacts", contacts.map((c) => jsonEncode(c.toJson())));
  }

  static Future<UserData> getUser(String username, String authHeader) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String visibleName = "";
    String avatarPath = "assets/edit_image.png";
    List<Contact> contacts = [];
    registerUser("caelan", "Caelan Anderson", "IamcaelanUserxxxAuthxxxUnique",
        "assets/0.jpg");
    //  local user exists
    if (await localUserExists(username)) {
      visibleName = prefs.getString(username + "_visibleName");
      avatarPath = prefs.getString(username + "_avatarPath");
      contacts = await loadContacts(username);
    } else {
      //  Get visibleName from search functionality
      registerUser(username, visibleName, authHeader, avatarPath);
    }

    return UserData(
        visibleName: visibleName,
        username: username,
        authHeader: authHeader,
        savedContacts: contacts);
  }
}
