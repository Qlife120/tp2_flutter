import 'package:flutter/material.dart';
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

  Future<void> _submitForm() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      // Create a ClothingItem object
      final newClothingItem = ClothingItem(
        title: _titleController.text,
        category: _category!,
        size: _sizeController.text,
        brand: _brandController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
      );

      // Save the data to Firestore
      await FirebaseFirestore.instance.collection('clothing_items').add(newClothingItem.toMap());

      // A snackbar to display a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vêtement ajouté avec succès!')));
    }

    else{
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
