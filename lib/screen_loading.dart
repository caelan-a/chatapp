//  @author Caelan Anderson 2018

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/*
  Loading screen for async tasks such as network requests taking place.
  Parent widget updates loading text from outside using a global key and accessing state function
*/

class LoadingScreen extends StatefulWidget {
  final String loadingText;
  final key;

  LoadingScreen({this.loadingText, this.key});

  @override
  LoadingScreenState createState() => new LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  String _loadingText = "";
  AnimationController animationController;
  Animation animation;

  @override
  void initState() {
    _loadingText = widget.loadingText;

    animationController =  AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);

    super.initState();
  }

  @override
    void dispose() {
      animationController.dispose();
      super.dispose();
    }

  void setLoadingText(String text) {
    _loadingText = text;
    animationController.reset();
    animationController.forward();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    animationController.forward();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: null,
        body: FadeTransition(
          opacity: animation,
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("$_loadingText\n\n",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .body1
                      .copyWith(fontSize: 16.0)),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ],
          )),
        ),
      ),
    );
  }
}