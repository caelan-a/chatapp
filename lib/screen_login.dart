import 'package:chatapp/screen_register.dart';
import 'package:flutter/material.dart';
import 'login_background.dart';
import 'screen_contacts.dart';
import 'screen_loading.dart';
import 'register.dart';
import 'main.dart';
import 'database.dart';
import 'user_data.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  FocusNode noneFN = FocusNode();
  FocusNode usernameFN = FocusNode();
  FocusNode passwordFN = FocusNode();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  GlobalKey<LoadingScreenState> loadingScreenKey = GlobalKey();

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

  void login(String username, String password) {
    Main.toScreen(context,
        LoadingScreen(loadingText: "Logging in..", key: loadingScreenKey));

    Database.sendLoginRequest(username, password).then((result) async {
      if (result['status'] == LoginResponse.success) {
        UserData user = await UserData.getUser(username, result['authHeader']);
        loadingScreenKey.currentState.setLoadingText("Successfully logged in..");

        Main.toScreen(
            context,
            ContactsScreen(
              userData: user,
            ));
      } else {
        //  Failure
        Main.popScreens(context, 1);
        showErrorDialog(context, "Login Failed",
            "Username or password incorrect.\nPlease check and try again");
      }
    });

  }

  void goToSignUp() {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

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
                controller: usernameController,
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
                  controller: passwordController,
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
                      onPressed: () {
                        login(usernameController.text, passwordController.text);
                      },
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
                      onPressed: () {
                        goToSignUp();
                      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          Background(),
          _buildLoginForm(),
          // _buildRegisterForm(),
        ],
      ),
    );
  }
}
