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
  String serverIP = "192.168.1.93:8086";

  UserData(
      {this.username, this.authHeader, this.savedContacts, this.visibleName}) {}

  void deleteContact(Contact contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    print("Delete contact");
    savedContacts.remove(contact);
    List<String> strList =   savedContacts.map((c) => jsonEncode(c.toJson())).toList();  
    prefs.setStringList(username + "_contacts", strList);
  }

  void saveContact(Contact contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!savedContacts.contains(contact)) {
      savedContacts.add(contact);
    }

    print("Saving contacts");
    List<String> strList =   savedContacts.map((c) => jsonEncode(c.toJson())).toList();  
    prefs.setStringList(username + "_contacts", strList);

  }

  static Future<List<Contact>> loadContacts(String username, SharedPreferences prefs) async {
    List<String> listStr = prefs.getStringList(username + "_contacts");

    if (listStr == null) {
      return [];
    } else {
      return listStr
          .map((rawJson) => Contact.fromJson(jsonDecode(rawJson)))
          .toList();
    }
  }

  static Future<bool> localUserExists(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(username);
  }

  static void saveUserData(UserData user) {

  }

  static void registerUser(String username, String visibleName,
      String authHeader, String avatarPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(username, username);
    prefs.setString(username + "_visibleName", visibleName);
    prefs.setString(username + "_avatarPath", avatarPath);
    prefs.setString(username + "_authHeader", authHeader);

    List<Contact> contacts = [];
    prefs.setStringList(
        username + "_contacts", contacts.map((c) => jsonEncode(c.toJson())).toList());
  }

  static Future<UserData> getUser(String username, String authHeader) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String visibleName = "";
    String avatarPath = "assets/edit_image.png";
    List<Contact> contacts = [];

    //  local user exists
    if (await localUserExists(username)) {
      print("Username exists");
      visibleName = prefs.getString(username + "_visibleName");
      avatarPath = prefs.getString(username + "_avatarPath");
      contacts = await loadContacts(username, prefs);
      print(contacts);
    } else {
      print("New user");
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
