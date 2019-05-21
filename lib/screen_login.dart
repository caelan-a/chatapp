import 'package:flutter/material.dart';
import 'login_background.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode noneFN = FocusNode();
  FocusNode usernameFN = FocusNode();
  FocusNode passwordFN = FocusNode();

  Widget _buildLoginForm() {
    return Form(
      child: Container(
        padding: EdgeInsets.fromLTRB(
            60.0, MediaQuery.of(context).size.height / 2.4, 60.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: 'Username',
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
                  decoration: InputDecoration(labelText: 'Password'),
                  keyboardType: TextInputType.emailAddress,
                  focusNode: passwordFN,
                  onFieldSubmitted: (text) {
                    FocusScope.of(context).requestFocus(noneFN);
                  }),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      child: Text("Login"),
                      onPressed: () {},
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0))),
                ),
                Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: OutlineButton(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                      shape: new RoundedRectangleBorder(
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: new BorderRadius.circular(30.0)),
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {},
                      color: Theme.of(context).primaryColor,
                      child: Text("Sign Up"),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      child: Container(
        padding: EdgeInsets.fromLTRB(
            60.0, MediaQuery.of(context).size.height / 2.4, 60.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: 'Username',
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
                  decoration: InputDecoration(labelText: 'Password'),
                  keyboardType: TextInputType.emailAddress,
                  focusNode: passwordFN,
                  onFieldSubmitted: (text) {
                    FocusScope.of(context).requestFocus(noneFN);
                  }),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      child: Text("Done"),
                      onPressed: () {},
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0))),
                ),
              ],
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
        children: <Widget>[
          Background(),
          _buildLoginForm(),
        ],
      ),
    );
  }
}
