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

          double total = 0.0;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: documents.map((document) {
                    final data = document.data() as Map<String, dynamic>;
                    // critere 2 : prix total
                    final double price = data['price']?.toDouble() ?? 0.0;
                    total += price;
                    // critere 1 : image taille , prix, titre 
                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      leading: data['imageBase64'] != null
                          ? Image.network(
                              data['imageBase64'],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: Center(child: Text('No Image')),
                            ),
                      title: Text(data['title'] ?? 'No Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Size: ${data['size'] ?? 'No Size'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${price.toStringAsFixed(2)} €'),
                          IconButton(
                            // critere 3 : retirer vetement du panier
                            icon: Icon(Icons.close),
                            onPressed: () => _removeFromCart(document.id),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${total.toStringAsFixed(2)} €',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
