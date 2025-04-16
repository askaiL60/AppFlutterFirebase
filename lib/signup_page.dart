import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.pop(
          context,
        ); // Retour à la page de connexion après inscription
      } on FirebaseAuthException catch (e) {
        setState(() {
          // Gestion d'erreurs en fonction du code d'erreur
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'Cet email est déjà utilisé.';
              break;
            case 'invalid-email':
              errorMessage = 'L\'email entré est invalide.';
              break;
            case 'weak-password':
              errorMessage = 'Le mot de passe est trop faible.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'La création de compte est désactivée.';
              break;
            default:
              errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
          }
        });
      } catch (e) {
        setState(() {
          errorMessage =
              'Une erreur inattendue est survenue. Veuillez réessayer.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Retour à la page précédente
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: signUp,
                child: const Text('S\'inscrire'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Retour à la page de connexion
                },
                child: const Text('Déjà un compte ? Connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
