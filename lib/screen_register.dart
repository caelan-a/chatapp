import 'package:flutter/material.dart';
import 'login_background.dart';
import 'package:image_picker/image_picker.dart';
import 'screen_contacts.dart';
import 'main.dart';
import 'dart:io';
import 'dart:convert';
import 'user_data.dart';
import 'database.dart';
import 'screen_loading.dart';
import 'package:path_provider/path_provider.dart';
  
  
class RegisterScreen extends StatefulWidget {
  GlobalKey<LoadingScreenState> loadingScreenKey;

  RegisterScreen({Key key, this.loadingScreenKey}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  FocusNode noneFN = FocusNode();
  FocusNode usernameFN = FocusNode();
  FocusNode passwordFN = FocusNode();
  FocusNode nameFN = FocusNode();

  File avatarFile;

  TextEditingController usernameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();

  String getB64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  void register() {
    String username = usernameTextController.text;
    String password = passwordTextController.text;
    String visibleName = nameTextController.text;
    String avatarB64 = getB64(avatarFile);

    Main.toScreen(
        context,
        LoadingScreen(
            loadingText: "Registering..", key: widget.loadingScreenKey));
            

    Database.sendRegisterRequest(username, password, visibleName).then((result) async {
      if (result['status'] == LoginResponse.success) {
        UserData user = await UserData.registerUser(username, visibleName, result['authHeader'], avatarB64);
        widget.loadingScreenKey.currentState
            .setLoadingText("Successfully registered");

        Main.toScreen(
            context,
            ContactsScreen(
              userData: user,
            ));
      } else {
        //  Failure
        Main.popScreens(context, 1);
        showErrorDialog(context, "Sign Up Failed", "Please try again..");
      }
    });
  }

  static void showErrorDialog(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 00.0),
          titlePadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  Future getAvatarImageFile() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      avatarFile = image;
    });
  }

  Widget _buildEditImage() {
    return IconButton(
      onPressed: () {
        setState(() {
          getAvatarImageFile();
        });
      },
      iconSize: 120.0,
      icon: avatarFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.file(
                avatarFile,
                fit: BoxFit.cover,
                height: 100.0,
                width: 100.0,
              ))
          : Container(
              padding: EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(100.0),
                border: new Border.all(
                  width: 3.0,
                  color: Colors.grey[400],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Icon(
                  Icons.person,
                  size: 70.0,
                  color: Colors.grey[400],
                ),
              ),
            ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      child: Container(
        padding: EdgeInsets.fromLTRB(
            60.0, MediaQuery.of(context).size.height / 3.75, 60.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildEditImage(),
            Container(
              child: TextFormField(
                controller: usernameTextController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    hintText: 'Username',
                    alignLabelWithHint: true,
                    hintStyle: TextStyle()),
                keyboardType: TextInputType.text,
                focusNode: usernameFN,
                onFieldSubmitted: (text) =>
                    FocusScope.of(context).requestFocus(passwordFN),
              ),
            ),
            Container(
              child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: passwordTextController,
                  decoration: InputDecoration(labelText: 'Password'),
                  keyboardType: TextInputType.text,
                  focusNode: passwordFN,
                  onFieldSubmitted: (text) {
                    FocusScope.of(context).requestFocus(nameFN);
                  }),
            ),
            Container(
              child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: nameTextController,
                  decoration: InputDecoration(labelText: 'Name'),
                  keyboardType: TextInputType.text,
                  focusNode: nameFN,
                  onFieldSubmitted: (text) {
                    FocusScope.of(context).requestFocus(noneFN);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RaisedButton(
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  child: Text("Submit"),
                  onPressed: () {
                    register();
                  },
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Positioned(
              top: MediaQuery.of(context).size.height / 6,
              child: Text("Register",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 34.0,
                      fontWeight: FontWeight.bold))),
          _buildRegisterForm(),
        ],
      ),
    );
  }
}
