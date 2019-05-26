import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pulsating_market.dart';
import 'contact.dart';

const textStyle = TextStyle(
    fontSize: 12.0,
    color: Colors.white,
    fontFamily: 'OpenSans',
    fontWeight: FontWeight.w600);

class VideoWindow extends StatefulWidget {
  Contact contact;

  TabController tabController;

  VideoWindow({@required this.contact, @required this.tabController});

  @override
  State createState() => _VideoWindowState();
}

class _VideoWindowState extends State<VideoWindow>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  void onEndCall() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                "assets/call_background.jpg",
              ),
              fit: BoxFit.cover)),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Positioned(
            top: MediaQuery.of(context).size.height / 4.2,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                PulsatingMarker(
                  screenPosition: Offset(0, 0),
                  scale: 0.13,
                  color: Colors.white,
                  radius: 50.0,
                ),
                ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: BorderRadius.circular(150.0),
                  child: Image.network(
                    widget.contact.avatarURL,
                    fit: BoxFit.cover,
                    scale: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.55,
            child: Text(
              "Connecting with..",
              style: textStyle,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.45,
            child: Text(
              widget.contact.username,
              style: textStyle.copyWith(fontSize: 32.0),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.25,
            child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.white),
                  shape: new RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white),
                      borderRadius: new BorderRadius.circular(30.0)),
                  textColor: Colors.white,
                  onPressed: () {
                    onEndCall();
                  },
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.call_end),
                      Text("   End Call"),
                    ],
                  ),
                )),
          ),
          Positioned(
                left: 20.0,
                top: 20.0,
                child: IconButton(
                  icon: Icon(Icons.message),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      widget.tabController.animateTo(0);
                    });
                  },
                ),
              )
        ],
      ),
    );
  }
}
