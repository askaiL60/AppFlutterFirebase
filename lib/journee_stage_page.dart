import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JourneeStagePage extends StatefulWidget {
  const JourneeStagePage({super.key});

  @override
  State<JourneeStagePage> createState() => _JourneeStagePageState();
}

class _JourneeStagePageState extends State<JourneeStagePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController lieuController = TextEditingController();
  final TextEditingController activitesController = TextEditingController();
  final TextEditingController competencesController = TextEditingController();

  void _resetControllers() {
    dateController.clear();
    lieuController.clear();
    activitesController.clear();
    competencesController.clear();
  }

  Future<void> _addOrUpdateJournee({String? docId}) async {
    final uid = _auth.currentUser!.uid;

    final data = {
      'date': dateController.text,
      'lieu': lieuController.text,
      'activites': activitesController.text,
      'competences': competencesController.text,
      'uid': uid,
    };

    if (docId == null) {
      await _firestore.collection('journees_stage').add(data);
    } else {
      await _firestore.collection('journees_stage').doc(docId).update(data);
    }

    Navigator.pop(context);
    _resetControllers();
  }

  void _showForm({DocumentSnapshot? doc}) {
    if (doc != null) {
      dateController.text = doc['date'];
      lieuController.text = doc['lieu'];
      activitesController.text = doc['activites'];
      competencesController.text = doc['competences'];
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(doc == null ? 'Ajouter' : 'Modifier'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                  ),
                  TextField(
                    controller: lieuController,
                    decoration: InputDecoration(labelText: 'Lieu'),
                  ),
                  TextField(
                    controller: activitesController,
                    decoration: InputDecoration(labelText: 'Activités'),
                  ),
                  TextField(
                    controller: competencesController,
                    decoration: InputDecoration(labelText: 'Compétences'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetControllers();
                },
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => _addOrUpdateJournee(docId: doc?.id),
                child: Text(doc == null ? 'Ajouter' : 'Modifier'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteJournee(String docId) async {
    await _firestore.collection('journees_stage').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Journées de Stage')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('journees_stage')
                .where('uid', isEqualTo: uid)
                .orderBy('date', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final journee = docs[index];
              return Card(
                child: ListTile(
                  title: Text("${journee['date']} - ${journee['lieu']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Activités : ${journee['activites']}"),
                      Text("Compétences : ${journee['competences']}"),
                    ],
                  ),
                  onTap: () => _showForm(doc: journee),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteJournee(journee.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
