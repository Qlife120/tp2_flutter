import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // import the cloud firestore package
import 'add_clothing_item_screen.dart'; // import the add clothing item screen
import 'detail_clothes.dart'; // import the detail clothes screen
import 'cart.dart'; // import the cart screen
import 'profile_page.dart';
import 'dart:convert'; // For base64 decoding
import 'dart:typed_data'; // For byte data

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildClothingList() {
    return StreamBuilder<QuerySnapshot>(
      // Retrieve clothing items from Firestore
      stream: _firestore.collection('clothing_items').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<DocumentSnapshot> documents = snapshot.data?.docs ?? [];
        if (documents.isEmpty) {
          return const Center(child: Text('Aucun article trouvé.'));
        }

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final data = documents[index].data() as Map<String, dynamic>? ?? {};

            // Check if the imageBase64 exists and decode it to display the image
            String? imageBase64 = data['imageBase64'];
            Uint8List? imageBytes;
            if (imageBase64 != null) {
              imageBytes = base64Decode(imageBase64);
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: imageBytes != null
                    ? Image.memory(imageBytes, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported),
                title: Text(data['title'] ?? 'Sans titre'),
                subtitle: Text(
                    'Taille: ${data['size'] ?? 'Inconnue'}\nPrix: ${(data['price'] ?? 0).toStringAsFixed(2)} €'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailClothes(
                        documentId: documents[index].id,
                        clothingData: data,
                        userId: widget.user.uid,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartPage() {
    return CartPage(userId: widget.user.uid);
  }

  Widget _buildProfilePage() {
    return ProfileScreen(); // Pass the user to ProfilePage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acheter'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildClothingList(), // Acheter page
            _buildCartPage(), // Panier page
            _buildProfilePage(), // Profil page
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Acheter'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
