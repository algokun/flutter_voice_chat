import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatscreen.dart';

class ChatHome extends StatefulWidget {
  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  
  String currentUserid , currentUserName;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
   getCurrentUser();
   return StreamBuilder<QuerySnapshot>(
     stream: Firestore.instance.collection('users').snapshots(),
     builder: (context, snapshot) {
       if (!snapshot.hasData) return LinearProgressIndicator();

       return _buildList(context, snapshot.data.documents);
     },
   );
 }

 Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
   return ListView(
     padding: const EdgeInsets.only(top: 20.0),
     children: snapshot.map((data) => _buildListItem(context, data , currentUserid)).toList(),
   );
 }

 Widget _buildListItem(BuildContext context, DocumentSnapshot data , String currentUserid) {
   final record = Record.fromSnapshot(data);
   bool isCurrenUser = currentUserid == record.uid;
   return Visibility(
     visible: !isCurrenUser,
       child: ListTile(
         contentPadding: EdgeInsets.all(10.0),
         title: Text(
                  record.displayName ,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
           ),
         leading: CircleAvatar(
           child: Text(
                  record.displayName.substring(0,1),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
           ),
           radius: 25,
         ),
         onTap: (){
           Navigator.of(context).push(
             MaterialPageRoute(
               builder: (context) => ChatScreen(
                    chatuserId: record.uid,
                    chatUserName: record.displayName,
                    currentUserId: currentUserid,
                    currentUserName: currentUserName,
                 )
             )
           );
         },
       ),
   );
 }

 getCurrentUser(){
   FirebaseAuth.instance.currentUser().then(
      (user){
        setState(() {
          this.currentUserid = user.uid;
          this.currentUserName = user.displayName;
        });
      }
    );
 }
}

class Record {
 final String displayName,uid;
 final DocumentReference reference;

 Record.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['displayName'] != null),
       displayName = map['displayName'],
       uid = map['uid'];

 Record.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

 @override
 String toString() => "Record<$displayName:$uid>";
}