import 'package:flutter/material.dart';
import 'auth_toolkit.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  
  FirebaseAuthToolKit authToolKit = FirebaseAuthToolKit();

  TextEditingController signupEmailController , signupPassController , signupNameController;

  @override
  void initState() {
    signupEmailController = TextEditingController();
    signupPassController = TextEditingController();
    signupNameController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Account"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Text(
            "Create a new Account",
            style: TextStyle(
              fontSize: 25.0
            ),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: signupNameController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFff5521),
                  width: 2.0
                ),
              ),
              labelText: "Display Name",
              labelStyle: TextStyle(
                color: Colors.blueGrey
              )
            ),
          ),
          TextField(
            keyboardType: TextInputType.emailAddress,
            controller: signupEmailController,
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
              )
            ),
          ),
          TextField(
            controller: signupPassController,
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
                authToolKit.firebaseSignup(
                  signupNameController.text,
                  signupEmailController.text,
                  signupPassController.text,
                  context
                  );              
              },
              color: Color(0xFFff5521),
              child: Text("CREATE ACCOUNT"),
              textColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }
  
  

  @override
  void dispose() {
    super.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPassController.dispose();
  }
}