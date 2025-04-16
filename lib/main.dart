import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // importation cloud Firestore
import 'login_page.dart';
import 'home_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec les options spécifiques à la plateforme
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialisation de Firestore (déjà inclus avec Firebase)
  FirebaseFirestore
      .instance; // Cette ligne garantit que Firestore est bien initialisé.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Web',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Définir ici les routes pour la navigation
      initialRoute: '/',
      routes: {
        '/':
            (context) =>
                const AuthGate(), // La page d'authentification redirige en fonction de l'état de l'utilisateur
        '/login': (context) => const LoginPage(), // Page de connexion
        '/home':
            (context) =>
                const HomePage(), // Page d'accueil pour les utilisateurs connectés
        '/profile':
            (context) => const ProfilePage(), // Page de profil (si nécessaire)
      },
    );
  }
}

// Cette classe gère l'authentification de l'utilisateur
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const HomePage(); // Utilisateur connecté, redirection vers HomePage
        } else {
          return const LoginPage(); // Utilisateur non connecté, afficher la page de connexion
        }
      },
    );
  }
}
