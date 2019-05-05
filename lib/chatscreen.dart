import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_recorder2/audio_recorder2.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:random_string/random_string.dart' as random;

class ChatScreen extends StatefulWidget {
  final String chatuserId , chatUserName , currentUserId , currentUserName;
  ChatScreen({this.chatuserId , this.chatUserName , this.currentUserId ,this.currentUserName});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _scaffoldKey2 = GlobalKey<ScaffoldState>();
  String groupChatId;

  
  Recording _recording;
  bool _isRecording = false;
  bool isPlaying = false;

  bool sendButtonVisible = false;

  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  FlutterSound flutterSound = FlutterSound();

  
  String tempFilename = "TempRecording";
  File defaultAudioFile;

  Recording recording;

  @override
  void initState() {
    super.initState();
    getUserPermissions();
    generategroupId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey2,
      appBar: AppBar(
        title: Text(widget.chatUserName),
      ),
      bottomNavigationBar: Material(
        elevation: 13.0,
        child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: stopRecording,
              color: Theme.of(context).primaryColor,
              iconSize: 20.0,
              tooltip: "Stop",
            ),
            IconButton(
              icon: Icon(Icons.fiber_manual_record),
              onPressed: startRecording,
              iconSize: 45.0,
              color: Theme.of(context).primaryColor,
              tooltip: "Tap to Record",
            ),
            Visibility(
              visible: sendButtonVisible,
              child: IconButton(
              icon: Icon(Icons.send),
              iconSize: 20.0,
              onPressed: (){
                  sendMessage();
                },
                color: Theme.of(context).primaryColor,
                tooltip: "Send",
              ),
            ),
          ],
        ),
      ),
      ),
      body: _buildBody(context),
    );
  }

  getUserPermissions() async {
    Map<PermissionGroup, PermissionStatus> permissions = 
    await PermissionHandler().requestPermissions([PermissionGroup.storage , PermissionGroup.microphone]);
    print(permissions);
  }

  startRecording() async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      String newFilePath = p.join(docDir.path, _randomString(10));
      File tempAudioFile = File(newFilePath+'.m4a');

      _scaffoldKey2.currentState
          .showSnackBar(new SnackBar(content: new Text("Recording."),
                                     duration: Duration(milliseconds: 1400), ));
      
      if (await tempAudioFile.exists()){
        await tempAudioFile.delete();
      }

      if (await AudioRecorder2.hasPermissions) {
        await AudioRecorder2.start(
            path: newFilePath, audioOutputFormat: AudioOutputFormat.AAC);
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Error! Audio recorder lacks permissions.")));
      }
      bool isRecording = await AudioRecorder2.isRecording;
      
      setState(() {
        //Tells flutter to rerun the build method
        _recording = new Recording(duration: new Duration(), path: newFilePath);
        _isRecording = isRecording;
        defaultAudioFile = tempAudioFile;
      });

    } catch (e) {
      print(e);
    }
  }

  stopRecording() async {
    // Await return of Recording object
    recording = await AudioRecorder2.stop();
    
    print("Path : ${recording.path},  Format : ${recording.audioOutputFormat},  Duration : ${recording.duration},  Extension : ${recording.extension},");

    bool isRecording = await AudioRecorder2.isRecording;

    Directory docDir = await getApplicationDocumentsDirectory();

    setState(() {
      //Tells flutter to rerun the build method
      _isRecording = isRecording;
      defaultAudioFile = File(p.join(docDir.path, this.tempFilename+'.m4a'));
      sendButtonVisible = true;
    });
  }

  Future<String> uploadPic() async {

    File file = File(recording.path);

    StorageReference reference = firebaseStorage.ref().child("rec/"+_randomString(10)+'.aac');
    
    StorageUploadTask uploadTask = reference.putFile(file);

    
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = dowurl.toString();
    
    return url;
   }

   String _randomString(int length) {
    return random.randomNumeric(length);
  }



  generategroupId(){
    var currentId = widget.currentUserId;
    var peerId = widget.chatuserId;
    if (currentId.hashCode <= peerId.hashCode) {
      this.groupChatId = '$currentId-$peerId';
    } else {
      this.groupChatId = '$peerId-$currentId';
    }
  }

  firestoreMsgUpload(content){
      var documentReference = Firestore.instance
      .collection('messages')
      .document(groupChatId)
      .collection(groupChatId)
      .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': widget.currentUserId,
            'idTo': widget.chatuserId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
          },
        ).then((value){
          setState(() {
            sendButtonVisible = false;
          });
        });
      });
  }

  sendMessage(){
    print("clicked");
    uploadPic().then((downloadUrl){
      firestoreMsgUpload(downloadUrl);
    });
  }

  Widget _buildBody(BuildContext context) {
   return StreamBuilder<QuerySnapshot>(
     stream: Firestore.instance
      .collection('messages')
      .document(groupChatId)
      .collection(groupChatId)
      .snapshots(),
      
     builder: (context, snapshot) {
       if (!snapshot.hasData) return LinearProgressIndicator();

       return _buildList(context, snapshot.data.documents);
     },
   );
 }

 Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
   return ListView(
     padding: const EdgeInsets.all(10.0),
     children: snapshot.map((data) => _buildListItem(context, data)).toList(),
   );
 }

 Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
   Message message = Message.fromSnapshot(data);
   bool isMyMessage = message.idFrom == widget.currentUserId;
   return Padding(
     padding: const EdgeInsets.all(8.0),
     child: Align(
       alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
       child: Material(
         borderRadius: BorderRadius.circular(10.0),
         elevation: 2.0,
         child: Container(
           padding: EdgeInsets.all(10.0),
           width: MediaQuery.of(context).size.width / 3,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
              CircleAvatar(
                child: 
                isMyMessage ? Text(widget.currentUserName.substring(0,1)) : Text(widget.chatUserName.substring(0,1)),
              ),
              IconButton(
                icon: Icon(Icons.play_circle_filled),
                onPressed: (){
                  isPlaying ? flutterStopPlayer(message.content) : flutterPlaySound(message.content);
                },
              ),
             ],
            ),
         ),
       )
     ),
   );
 }
 
 flutterPlaySound(url) async {

   await flutterSound.startPlayer(url);

   flutterSound.onPlayerStateChanged.listen((e){
     if(e == null){
       setState(() {
         this.isPlaying = false;
       });
     }
     else{
       print("Playing Mohan");
       setState(() {
         this.isPlaying = false;
       });
     }
   });
 }

 Future<dynamic> flutterStopPlayer(url) async{
   await flutterSound.stopPlayer().then(
     (value){
       flutterPlaySound(url);
     }
   );
 }

}


class Message {
 final String idFrom , idTo , content;
 final DocumentReference reference;

 Message.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['idFrom'] != null),
       assert(map['idTo'] != null),
       assert(map['content'] != null),
       idFrom = map['idFrom'],
       content = map['content'],
       idTo = map['idTo'];

 Message.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

 @override
 String toString() => "Message<$idFrom:$idTo:$content>";
}