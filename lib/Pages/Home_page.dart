import 'package:chat_messenger/Pages/Chat_page.dart';
import 'package:chat_messenger/Services/Auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }

// build a list of user except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        if (snapshot.hasData) {
          print('=======${snapshot.data!.docs}=====');
          return ListView(
            children: snapshot.data!.docs
                .where((doc) => _auth.currentUser!.email != doc['email'])
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        } else {
          return const Text("NoDataFound");
        }
      },
    );
  }

  Widget _buildUserListItem(QueryDocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    //display all users except current users
    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chatpage(
                    receiverUserID: data['uid'],
                    recieveuserEmail: data['email'])),
          );
        },
      );
    } else {
      return Container(
        width: 150,
        height: 80,
      );
    }
  }
}
