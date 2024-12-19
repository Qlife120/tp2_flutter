import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // allow interaction with firestore (firebase database)

class UserList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
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
}
