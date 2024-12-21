import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  final String userId;

  CartPage({required this.userId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _removeFromCart(String documentId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(documentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Center(child: Text('Votre panier est vide.'));
          }

          return ListView(
            children: documents.map((document) {
              final data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Text(data['category'] ?? 'No Category'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${data['price']?.toStringAsFixed(2) ?? '0.00'} €'),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeFromCart(document.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
