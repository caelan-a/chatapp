import 'package:flutter/material.dart';
import 'login_background.dart';
import 'screen_contacts.dart';

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
  FocusNode emailFN = FocusNode();

  void register() {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (context) => ContactsScreen()));
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
                  decoration: InputDecoration(labelText: 'Password'),
                  keyboardType: TextInputType.emailAddress,
                  focusNode: passwordFN,
                  onFieldSubmitted: (text) {
                    FocusScope.of(context).requestFocus(emailFN);
                  }),
            ),
            Container(
              child: TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  focusNode: emailFN,
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
            top: MediaQuery.of(context).size.height/4,
              child: Text("Register",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 34.0, fontWeight: FontWeight.bold))),
          _buildRegisterForm(),
        ],
      ),
    );
  }
}
