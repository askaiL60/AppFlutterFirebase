import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  Future<void> _exportToPDF() async {
    final pdfDoc = pw.Document();

    pdfDoc.addPage(
      pw.MultiPage(
        build:
            (pw.Context context) => [
              pw.Text(
                "Rapport de Stage",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildPdfSection(
                "Présentation de l’entreprise",
                presentationController.text,
              ),
              _buildPdfSection("Objectifs du stage", objectifsController.text),
              _buildPdfSection("Missions réalisées", missionsController.text),
              _buildPdfSection(
                "Difficultés rencontrées",
                difficultesController.text,
              ),
              _buildPdfSection("Conclusion", conclusionController.text),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfDoc.save(),
    );
  }

  pw.Widget _buildPdfSection(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(content, style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 15),
      ],
    );
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
              ElevatedButton.icon(
                onPressed: _exportToPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exporter en PDF'),
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
