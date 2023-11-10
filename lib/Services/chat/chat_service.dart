import 'package:chat_messenger/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chatservice extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //send messages
  Future<void> sendMessage(String recieverId, String message) async {
    //get user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    //create new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      recieverId: recieverId,
      timestamp: timestamp,
      message: message,
    );
    List<String> ids = [currentUserId, recieverId];
    ids.sort();
    String chatRoomId = "${recieverId}_$currentUserId";
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    //construct chat room id from the user ids
    List<String> ids = [userId, otherUserId];
    ids.sort();
    print("${otherUserId}_$userId");
    String chatRoomId = ids.join("_");
    return _firestore
        .collection('chat_rooms')
        .doc("${userId}_$otherUserId")
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
