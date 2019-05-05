import 'package:flutter/material.dart';
import 'chat_home.dart';
import 'start.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Voice Chat"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: (){},
            ),
            // PopupMenuButton(
            //   tooltip: "Menu",
            //   itemBuilder: (context) => [
            //     PopupMenuItem(
            //       child: Text("Settings"),
            //     ),
            //     PopupMenuItem<String>(
            //       child: Text("Logout"),
            //     ),
            //   ],
            //   onSelected: (val) => {
            //     print(val)
            //   },
            // )
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text("Logout"),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text("Settings"),
                    ),
                  ],
              initialValue: 2,
              onCanceled: () {
                print("You have canceled the menu.");
              },
              onSelected: (value) {
                if(value == 1){
                  firebaseLogOut();
                }
              },
            )
          ],
        ),
        drawer: Drawer(),
        body:  ChatHome(),
      ),
    );
  }
  
  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  firebaseLogOut(){
    FirebaseAuth.instance.signOut().then((user){
      gotoStartPage();
    });
  }

  void gotoStartPage(){
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => StartPage())
    );
  }
}