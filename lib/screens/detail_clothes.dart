import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailClothes extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> clothingData;
  final String userId;

  DetailClothes({
    required this.documentId,
    required this.clothingData,
    required this.userId,
  });

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addToCart(BuildContext context) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(documentId)
          .set(clothingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${clothingData['title']} has been added to the cart!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clothingData['title'] ?? 'Clothing Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // criter n1 : Image, titre, categorie, taille, marque, prix
          children: [
            // Display the image of the clothing item
            clothingData['image'] != null
                ? Image.network(
                    clothingData['image']!,
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                  )
                : Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(child: Text('No Image Available')),
                  ),
            SizedBox(height: 16),

            // Title
            Text(
              clothingData['title'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Category
            Text(
              'Category: ${clothingData['category'] ?? 'No Category'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Size
            Text(
              'Size: ${clothingData['size'] ?? 'No Size'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Brand
            Text(
              'Brand: ${clothingData['brand'] ?? 'No Brand'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Price
            Text(
              'Price: ${clothingData['price']?.toStringAsFixed(2) ?? '0.00'} €',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            Text(
              'Category: ${clothingData['category'] ?? 'No category found'} ',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // critere n 2 : Bouton ajouter au panier et Retour a la liste des vetements
            // Add to Cart Button
            ElevatedButton(
              onPressed: () => _addToCart(context),
              child: Text('Ajouter au panier'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
