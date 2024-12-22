import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // For Base64 decoding
import 'dart:typed_data'; // For working with byte data

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

  // Function to add the item to the cart
  void _addToCart(BuildContext context) async {
    try {
      // Add the clothing item to the user's cart collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(documentId)
          .set(clothingData);

      // Display a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${clothingData['title']} has been added to the cart!'),
        ),
      );
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Decode the Base64 string if it's provided
    Uint8List? imageBytes;
    if (clothingData['imageBase64'] != null) {
      try {
        imageBytes = base64Decode(clothingData['imageBase64']);
      } catch (e) {
        print('Error decoding Base64 image: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(clothingData['title'] ?? 'Clothing Detail'), // Display item title in AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Display the image, title, category, size, brand, and price
          children: [
            // Display the image of the clothing item from Base64 data
            imageBytes != null
                ? Image.memory(
                    imageBytes, // Load image from Base64 decoded bytes
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                  )
                : Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300], // Placeholder if no image is available
                    child: Center(child: Text('No Image Available')),
                  ),
            SizedBox(height: 16),

            // Display the title of the clothing item
            Text(
              clothingData['title'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Display the category of the clothing item
            Text(
              'Category: ${clothingData['category'] ?? 'No Category'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Display the size of the clothing item
            Text(
              'Size: ${clothingData['size'] ?? 'No Size'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Display the brand of the clothing item
            Text(
              'Brand: ${clothingData['brand'] ?? 'No Brand'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Display the price of the clothing item
            Text(
              'Price: ${clothingData['price']?.toStringAsFixed(2) ?? '0.00'} €',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Display the category again (extra info)
            Text(
              'Category: ${clothingData['category'] ?? 'No category found'} ',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Display the "Add to Cart" button and "Back" button
            ElevatedButton(
              onPressed: () => _addToCart(context), // Add the item to the cart
              child: Text('Ajouter au panier'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
