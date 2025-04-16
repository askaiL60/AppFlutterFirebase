import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RapportStagePage extends StatefulWidget {
  const RapportStagePage({super.key});

  @override
  State<RapportStagePage> createState() => _RapportStagePageState();
}

class _RapportStagePageState extends State<RapportStagePage> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController presentationController = TextEditingController();
  final TextEditingController objectifsController = TextEditingController();
  final TextEditingController missionsController = TextEditingController();
  final TextEditingController difficultesController = TextEditingController();
  final TextEditingController conclusionController = TextEditingController();

  bool isLoading = true;
  String? docId;

  @override
  void initState() {
    super.initState();
    _loadRapport();
  }

  Future<void> _loadRapport() async {
    final uid = _firebaseAuth.currentUser?.uid;
    final snapshot =
        await _firestore
            .collection('rapports_stage')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      docId = snapshot.docs.first.id;

      presentationController.text = data['presentation'] ?? '';
      objectifsController.text = data['objectifs'] ?? '';
      missionsController.text = data['missions'] ?? '';
      difficultesController.text = data['difficultes'] ?? '';
      conclusionController.text = data['conclusion'] ?? '';
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveRapport() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = _firebaseAuth.currentUser?.uid;

    final data = {
      'presentation': presentationController.text,
      'objectifs': objectifsController.text,
      'missions': missionsController.text,
      'difficultes': difficultesController.text,
      'conclusion': conclusionController.text,
      'uid': uid,
    };

    if (docId == null) {
      await _firestore.collection('rapports_stage').add(data);
    } else {
      await _firestore.collection('rapports_stage').doc(docId).update(data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapport enregistré avec succès !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Rapport de stage")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(
                "Présentation de l’entreprise",
                presentationController,
              ),
              _buildField("Objectifs du stage", objectifsController),
              _buildField("Missions réalisées", missionsController),
              _buildField("Difficultés rencontrées", difficultesController),
              _buildField("Conclusion", conclusionController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRapport,
                child: const Text('Enregistrer le rapport'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: null,
        validator:
            (value) => value == null || value.isEmpty ? 'Champ requis' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
