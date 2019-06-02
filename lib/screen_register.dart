import 'package:flutter/material.dart';
import 'login_background.dart';
import 'screen_contacts.dart';
import 'main.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  FocusNode noneFN = FocusNode();
  FocusNode usernameFN = FocusNode();
  FocusNode passwordFN = FocusNode();
  FocusNode nameFN = FocusNode();

  String avatarPath;

  TextEditingController usernameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();

  void register() {
    
  }

  String getAvatarImagePath() {
    return "";
  }

  Widget _buildEditImage() {
    return IconButton(
      onPressed: () {
        setState(() {
          avatarPath = getAvatarImagePath();
        });
      },
      icon: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: Image.asset(
          avatarPath == "" ? "assets/edit_image.jpg" : avatarPath,
          fit: BoxFit.cover,
          height: 35.0,
          width: 35.0,
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      child: Container(
        padding: EdgeInsets.fromLTRB(
            60.0, MediaQuery.of(context).size.height / 2.8, 60.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: TextFormField(
                controller: usernameTextController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    hintText: 'Username',
                    alignLabelWithHint: true,
                    hintStyle: TextStyle()),
                keyboardType: TextInputType.emailAddress,
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
                  keyboardType: TextInputType.emailAddress,
                  focusNode: passwordFN,
                  onFieldSubmitted: (text) {
                    FocusScope.of(context).requestFocus(nameFN);
                  }),
            ),
            Container(
              child: TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: 'Name'),
                  keyboardType: TextInputType.emailAddress,
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
                  onPressed: () {},
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
              top: MediaQuery.of(context).size.height / 4,
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
