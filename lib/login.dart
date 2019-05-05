import 'package:flutter/material.dart';
import 'auth_toolkit.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController loginEmailController , loginPassController;
  FirebaseAuthToolKit _authToolKit = FirebaseAuthToolKit();

  @override
  void initState() {
    super.initState();
    loginEmailController = TextEditingController();
    loginPassController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Text(
            "Login to your account",
            style: TextStyle(
              fontSize: 25.0
            ),
          ),
          SizedBox(height: 20,),
          TextField(
            keyboardType: TextInputType.emailAddress,
            controller: loginEmailController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFff5521),
                  width: 2.0
                ),
              ),
              labelText: "Your Email",
              labelStyle: TextStyle(
                color: Colors.blueGrey
              ),
            ),
          ),
          TextField(
            controller: loginPassController,
            obscureText: true,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFff5521),
                  width: 2.0
                ),
              ),
              labelText: "Password",
              labelStyle: TextStyle(
                color: Colors.blueGrey
              )
            ),
          ),
          SizedBox(height: 20,),
          Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(
              padding: EdgeInsets.all(10),
              onPressed: () {
                _authToolKit.firebaseLogin(
                  loginEmailController.text,
                  loginPassController.text,
                  context
                );
              },
              color: Theme.of(context).primaryColor,
              child: Text("LOGIN"),
              textColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPassController.dispose();
    super.dispose();
  }
}