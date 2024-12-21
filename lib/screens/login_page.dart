import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> _loginUser() async {
    if (_loginController.text.isEmpty || _passwordController.text.isEmpty) {
      // message de la console critere #5
      print("Champs vides : veuillez entrer un login et un mot de passe.");
      return; // dans le cas ou les champs sont vides  critere #6     
      }

    setState(() {
      _isLoading = true;
    });

    try {
      // Authentification avec Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _loginController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Si l'utilisateur existe, rediriger
        print("Utilisateur connecté : ${user.email}");
        Navigator.pushReplacementNamed(context, "/home");
      }
    } on FirebaseAuthException catch (e) {
      // Si l'utilisateur n'existe pas ou autre erreur
      print("Erreur lors de la connexion : ${e.code}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yc Clothes"), // Nom de l'application critere #1
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // AppBar color

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // criter #2
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: "Login"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // criter #2
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true, // Champ obfusqué critere # 3
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _loginUser,
                      child: const Text("Se connecter"), // critere #4
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
