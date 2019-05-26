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

  UserData(String username, String password, String authHeader) {

  }

  Future<void> saveLocalUser() {

  }

  void saveContact(Contact contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!savedContacts.contains(contact)) {
      savedContacts.add(contact);
    }
    prefs.setString(username+"_contacts", jsonEncode(savedContacts));
  }

  void loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedContacts = jsonDecode(prefs.get(username+"_contacts"));
  }

  Future

  Future<bool> localUserExists() {}

  static UserData autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    //  local user exists
    if(await prefs.containsKey("username")) {
      String username = prefs.getString("username");
      String password = prefs.getString("password");

      Map<String, String> response = await Database.sendLoginRequest(username, password);

      if(response['success'] == "true") {
        String authHeader = response['authHeader'];
        List<Contact> 
      }
    }


  }

  Future<void> loadContacts() {}
}
