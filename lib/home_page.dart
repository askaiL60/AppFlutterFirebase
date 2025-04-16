import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'journee_stage_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(
                context,
                '/login',
              ); // Retour à la page de connexion après déconnexion
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue sur la page d\'accueil!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            if (user != null)
              Text('Vous êtes connecté en tant que : ${user.email}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                ); // Redirection vers la page de profil
              },
              child: const Text('Voir le profil'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Suppression de compte
                try {
                  await user?.delete();
                  Navigator.pushReplacementNamed(
                    context,
                    '/login',
                  ); // Redirection après suppression de compte
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la suppression du compte'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer le compte'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); //Retour
              },
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page pour afficher les informations du profil utilisateur
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil utilisateur')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations du compte',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (user != null) ...[
              Text(
                'Email : ${user.email}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text('UID : ${user.uid}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JourneeStagePage()),
                );
              },
              child: Text("Voir mes journées de stage"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Retour
              },
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
