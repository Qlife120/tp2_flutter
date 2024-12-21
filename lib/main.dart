import 'package:flutter/material.dart'; // Import the Material package (UI)
import 'package:firebase_auth/firebase_auth.dart'; // Enable authentication in firebase
import 'package:firebase_core/firebase_core.dart'; // Required to use firebase 
import 'screens/login_page.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure flutter is properly set up before running the app

  // Connect to firebase using the credentials
  // TODO : Change this to env variables
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDoL914iJlC05wG9bWtjyC3Vxr9T8fDgjg",
      projectId: "tpflutterchemlal",
      messagingSenderId: "147859431162",
      appId: "1:147859431162:web:c060e243c801a981e0f343",
    ),
  );
  // runs the app and loads the initial widget MyApp
  runApp(MyApp());
}

// MyApp is the root widget of the app
// It decides which page to display based on the user's authentication state
class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _handleAuth() {
    return StreamBuilder<User?>(
      // authStateChanges() provides updates when the user logs in or out
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        // if the user is logged in, display the home page
        // else display the login page
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return LoginScreen();
            //return AddClothingItemScreen();
          }
          // TODO : change this // redirect the user to the home page with 3 icons and an add button 
          //return AddClothingItemScreen();
          return HomePage(user: user);

          //return HomePage(user: user);
        }
        // Display loading indicator while checking auth state.
        // TODO : ASK ABOUT THIS
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

// The build method is called to build the widget tree
// Configure the app's theme and title
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tp2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _handleAuth(),
    );
  }
}



