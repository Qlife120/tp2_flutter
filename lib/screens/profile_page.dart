import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordEditable = false; // Pour activer/désactiver l'édition du mot de passe

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data();
      if (data != null) {
        setState(() {
          _emailController.text = user.email!;
          _passwordController.text = "******"; // Mot de passe masqué
          _birthdayController.text = data['birthday'] ?? '';
          _addressController.text = data['address'] ?? '';
          _postalCodeController.text = data['postalCode'] ?? '';
          _cityController.text = data['city'] ?? '';
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des informations : $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePassword(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mot de passe mis à jour avec succès !")),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = "Le mot de passe est trop faible.";
          break;
        case 'requires-recent-login':
          errorMessage = "Reconnectez-vous pour modifier le mot de passe.";
          break;
        default:
          errorMessage = "Erreur : ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // Mettre à jour les informations dans Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'birthday': _birthdayController.text,
          'address': _addressController.text,
          'postalCode': _postalCodeController.text,
          'city': _cityController.text,
        });

        if (_isPasswordEditable && _passwordController.text != "******") {
          await _updatePassword(_passwordController.text);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil mis à jour avec succès !")),
        );
      } catch (e) {
        print("Erreur lors de la mise à jour du profil : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Une erreur est survenue.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Valider",
            onPressed: _updateProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Se déconnecter",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // read-only 
                    TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 16),

                    //  obfuscated password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      readOnly: !_isPasswordEditable,
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordEditable ? Icons.lock_open : Icons.lock),
                          onPressed: () {
                            setState(() {
                              _isPasswordEditable = !_isPasswordEditable;
                              if (!_isPasswordEditable) {
                                _passwordController.text = "******";
                              }
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (_isPasswordEditable && (value == null || value.isEmpty)) {
                          return "Veuillez entrer un nouveau mot de passe.";
                        }
                        if (_isPasswordEditable && value!.length < 6) {
                          return "Le mot de passe doit contenir au moins 6 caractères.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Anniversaire
                    TextFormField(
                      controller: _birthdayController,
                      decoration: const InputDecoration(labelText: "Anniversaire"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer votre anniversaire.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Adresse
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: "Adresse"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer votre adresse.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Code postal
                    TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(labelText: "Code postal"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer votre code postal.";
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return "Entrez un code postal valide.";
                        }
                        if (value.length != 5) {
                          return "Le code postal doit contenir 5 chiffres.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ville
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: "Ville"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer votre ville.";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
