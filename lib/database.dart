import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:meta/meta.dart'; //for @required annotation
import 'contact.dart';

/*
  Functions and keys for communicating with BBH API
*/

enum LoginResponse {
  success,
  failure,
}

class Database {
  static const int timeout = 30; //  s

  static const String URL_REGISTER =
      "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/register/auth";
  static const String URL =
      "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/api";
  static const String URL_LOGIN =
      "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/my/auth";

  static const String URL_SEARCH =  "http://ec2-18-237-100-56.us-west-2.compute.amazonaws.com/api";

  //  Used for simulating network lag
  static void justWait({@required int numberOfSeconds}) async {
    await Future.delayed(Duration(seconds: numberOfSeconds));
  }

  //  Return authHeader
  static Future<Map<String, dynamic>> sendLoginRequest(
      String username, String password) async {
    // Map<String, dynamic> json_data = {
    //   "Username": username,
    //   "Password": password,
    // };

    // var response = json.decode(json.decode(await _post(URL_LOGIN, "", jsonEncode(json_data))));

    await justWait(numberOfSeconds: 2);
    Map<String, dynamic> result = {"status" : LoginResponse.success, "authHeader" : "IamcaelanUserxxxAuthxxxUnique"};
    return result;
  }

  static Future<List<Contact>> searchContacts(String searchString) async {
    print("Search contacts");
    var response = json.decode(await _get(URL_SEARCH, {"Username" : searchString}));

    List<Contact> returnedContacts = [];

    (response['users'] as List).forEach((dynamic contact) {
      returnedContacts.add(Contact(username: contact['Username'], visibleName: contact['Name']));
    });
    print(response["users"]);
    
    return returnedContacts;
  }

  static Future<dynamic> sendRegisterRequest(
      String username, String password, String email) async {
    Map<String, dynamic> json_data = {
      "Username": username,
      "Password": password,
      "Email": email,
    };

    var response = json.decode(
        json.decode(await _post(URL_REGISTER, "", jsonEncode(json_data))));
    print(response);
  }

  static Future<String> _post(String url, String authHeader, var body) async {
    return await http.post(Uri.encodeFull(url), body: body, headers: {
      "Content-Type": "application/json",
      "AuthHeader": authHeader,
    }).then((http.Response response) {
      // print(response.body);
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return response.body;
    }).timeout(Duration(seconds: timeout));
  }


  static Future<String> _get(String url, Map<String, String> queryParams) async {
    String queryString = "?";

    queryParams.forEach((key, value){
      queryString += key + "=" + value + "&";
    });

    return await http.get(Uri.encodeFull(url + queryString), headers: {
      "Content-Type": "application/json",
    }).then((http.Response response) {
      // print(response.body);
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return response.body;
    }).timeout(Duration(seconds: timeout));
  }

  static onError(BuildContext context, dynamic error, dynamic stackTrace,
      Function retryFunction) async {
    int errno;
    if (error is SocketException) {
      errno = error.osError.errorCode;
    } else {
      errno = 0;
    }
    print(errno);
  }
}
