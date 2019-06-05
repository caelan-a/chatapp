import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';
import 'contact.dart';
import 'dart:io';
import 'dart:convert';
import 'webrtc/handler_webrtc.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

const String SERVER_IP = "192.168.1.89";

class UserData {
  String visibleName;
  String username;
  String avatarB64;
  String authHeader;
  List<Contact> savedContacts;

  RTCHandler rtcHandler; // used to communicate and listen to server

  UserData(
      {this.username,
      this.authHeader,
      this.savedContacts,
      this.visibleName,
      this.avatarB64}) {}

  void registerWithRTCServer(
      Function onIncomingCall, Function onEndCall, Function onCallAccepted) {
    print("Registering with server");
    rtcHandler =
        RTCHandler(SERVER_IP, this, onIncomingCall, onEndCall, onCallAccepted);
    rtcHandler.connectToServer(SERVER_IP, visibleName, "@" + username);
  }

  String getBase64Avatar() {
    return avatarB64;
  }

  Image getAvatar(double width, double height) {
    return Image.memory(
      base64Decode(avatarB64),
      fit: BoxFit.fill,
      width: width,
      height: height,
    );
  }

  static Future<void> writeBase64ToFile(
      String filePath, String avatarB64) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    return File(appDocPath + "/" + filePath).writeAsString(avatarB64);
  }

  static Future<String> getAvatarB64FromFile(String filePath) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    return new File(appDocPath + "/" + filePath)
        .readAsString()
        .then((String contents) {
      return contents;
    });
  }

  Contact acceptContact(String username, String avatarBase64) {
    Contact contact =
        savedContacts.firstWhere((Contact c) => c.username == username);
    contact.accepted = true;
    contact.avatarBase64 = avatarBase64;
    writeBase64ToFile(username, avatarBase64).then((file) {
      saveContact(contact);
    });
    return contact;
  }

  void deleteContact(Contact contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("Delete contact");
    savedContacts.remove(contact);
    List<String> strList =
        savedContacts.map((c) => jsonEncode(c.toJson())).toList();
    prefs.setStringList(username + "_contacts", strList);
  }

  void saveContact(Contact contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!savedContacts.contains(contact)) {
      savedContacts.add(contact);
    }

    print("Saving contacts");
    List<String> strList =
        savedContacts.map((c) => jsonEncode(c.toJson())).toList();
    prefs.setStringList(username + "_contacts", strList);
  }

  static Future<List<Contact>> loadContacts(
      String username, SharedPreferences prefs) async {
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

  static void saveUserData(UserData user) {}

  static Future<UserData> registerUser(String username, String visibleName,
      String authHeader, String avatarB64) async {
    //  Write avatar to b64 file
    final avatarFilePath = username + "_avatar.b64";
    writeBase64ToFile(avatarFilePath, avatarB64);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(username, username);
    prefs.setString(username + "_visibleName", visibleName);
    prefs.setString(username + "_avatarPath", avatarFilePath);
    prefs.setString(username + "_authHeader", authHeader);

    List<Contact> contacts = [];
    prefs.setStringList(username + "_contacts",
        contacts.map((c) => jsonEncode(c.toJson())).toList());

    return UserData(
        visibleName: visibleName,
        username: username,
        authHeader: authHeader,
        avatarB64: avatarB64,
        savedContacts: contacts);
  }

  static Future<UserData> getUser(String username, String authHeader) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String visibleName = "";
    String avatarPath = username + "_avatar.b64";
    String avatarB64 = "";
    List<Contact> contacts = [];

    //  local user exists
    if (await localUserExists(username)) {
      print("Username exists");
      visibleName = prefs.getString(username + "_visibleName");
      avatarB64 = await getAvatarB64FromFile(avatarPath);
      contacts = await loadContacts(username, prefs);
      print("User: $username");
      print("Name: $visibleName");
    } else {
      print("New user");
      //  Get visibleName from search functionality
      return await registerUser(username, visibleName, authHeader, avatarPath);
    }

    return UserData(
        visibleName: visibleName,
        username: username,
        authHeader: authHeader,
        avatarB64: avatarB64,
        savedContacts: contacts);
  }
}
