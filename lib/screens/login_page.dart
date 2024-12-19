import 'package:flutter/material.dart'; // Import the Material package (UI)
import 'package:firebase_auth/firebase_auth.dart'; // Enable authentication in firebase


class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Controllers to capture the user input
  // TODO:  ASK WHT THE USE OF TEXTEDITINGCONTROLLER
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Firebase function for logging in
  // TODO : ASK ABOUT The Future
  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // catches the error if the login fails and displays a snackbar with the error message
    } on FirebaseAuthException catch (e) {
      // Show error message to user using a SnackBar.
      String errorMessage = e.message ?? 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent, // A vibrant background color
        elevation: 2, // Slight shadow for subtle depth
        title: Text(
          'Zara Maroc',
          style: TextStyle(
            color: Colors.white, // Contrasting text color
            fontSize: 20, // Slightly larger font size for visibility
            fontWeight: FontWeight.bold, // Bold for emphasis
          ),
        ),
        centerTitle: true, // Centers the title in the AppBar
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Login'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signInWithEmailAndPassword(context),
                child: Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}