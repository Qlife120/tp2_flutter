import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart'; // For web image picking
import 'dart:convert'; // For base64 encoding
import 'dart:typed_data'; // For byte data
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clothing_item.dart';

class AddClothingItemScreen extends StatefulWidget {
  @override
  _AddClothingItemScreenState createState() => _AddClothingItemScreenState();
}

class _AddClothingItemScreenState extends State<AddClothingItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _category = 'Pantalon';
  String? _imageBase64; // Store base64 image

  // Method to pick an image
  Future<void> _pickImage() async {
    print("Picking image...");

    // Ensure that the function is called correctly
    final file = await ImagePickerWeb.getImageAsBytes();
    if (file != null) {
      print("Image selected: ${file.length} bytes");

      setState(() {
        _imageBase64 = base64Encode(file); // Store the image as base64 string
      });

      print("Image base64: $_imageBase64");
    } else {
      print("No image selected");
    }
  }

  // Method to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageBase64 == null) {
        // Show a snackbar if no image is selected
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez ajouter une image')));
        return;
      }

      // Create a ClothingItem object with the picked data
      final newClothingItem = ClothingItem(
        title: _titleController.text,
        category: _category!,
        size: _sizeController.text,
        brand: _brandController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        imageBase64: _imageBase64, // Pass the base64 string
      );

      // Save the data to Firestore
      await FirebaseFirestore.instance.collection('clothing_items').add(newClothingItem.toMap());

      // Display a confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vêtement ajouté avec succès!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez remplir tous les champs du formulaire')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un Vêtement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un titre' : null,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: ['Pantalon', 'Short', 'Haut']
                    .map((cat) => DropdownMenuItem(child: Text(cat), value: cat))
                    .toList(),
                validator: (value) => value == null ? 'Veuillez choisir une catégorie' : null,
              ),
              TextFormField(
                controller: _sizeController,
                decoration: InputDecoration(labelText: 'Taille'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer une taille' : null,
              ),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(labelText: 'Marque'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer une marque' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'Veuillez entrer un prix valide' : null,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage, // Tap to pick image
                child: _imageBase64 != null
                    ? Image.memory(Uint8List.fromList(base64Decode(_imageBase64!))) // Display the image
                    : Icon(Icons.add_a_photo, size: 100),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
