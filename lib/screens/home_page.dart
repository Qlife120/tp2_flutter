import 'package:flutter/material.dart'; // Import the Material package (UI)
import 'package:firebase_auth/firebase_auth.dart'; // Enable authentication in firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // allow interaction with firestore (firebase database)

// Main screen after the user logs in

class HomePage extends StatelessWidget {
  final User user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomePage({required this.user});

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      // Stream that listens to changes in the users collection
      stream: _firestore
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;
        if (documents.isEmpty) {
          return Center(child: Text('No users found.'));
        }

        return ListView(
          children: documents.map((DocumentSnapshot document) {
            final data = document.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name'] ?? 'No Name'),
              subtitle: Text(data['email'] ?? 'No Email'),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          // Logs the user by callong the signOut() method
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome, ${user.email}!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _buildUserList(),
            ),
          ],
        ),
      ),
    );
  }
}