import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class FirebaseAuthToolKit{
  
  UserUpdateInfo info = UserUpdateInfo();
  
  firebaseSignup(name , email , password, context){
    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password
    ).then(
      (user){
        var uid = user.uid;
        info.displayName = name;
        user.updateProfile(info).then(
          (user2){
            Firestore.instance.collection("users").document(uid).setData(
              {
                "displayName" : name,
                "uid" : uid
              }
            ).then(
              gotoHome(context)
            );
          }
        );
      }
    );
  }

  firebaseLogin(email , password , context){
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password
    ).then(
      (val){
        gotoHome(context);
      }
    );
  }

  gotoHome(context){
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Homepage())
    );
  }
}