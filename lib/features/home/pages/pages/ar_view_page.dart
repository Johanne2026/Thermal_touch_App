import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

final model = GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: '', // ← Mets ta clé API ici
);

class ARViewPage extends StatefulWidget {
  @override
  _ARViewPageState createState() => _ARViewPageState();
}

class _ARViewPageState extends State<ARViewPage> {
  late ArCoreController arCoreController;
  final Map<String, String> objectInstructions = {};
  final Random _random = Random();

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _handlePlaneTap;
    arCoreController.onNodeTap = _handleNodeTap;
  }

  void _handlePlaneTap(List<ArCoreHitTestResult> hits) async {
    if (hits.isEmpty) return;

    final image = await _pickImage();
    if (image != null) {
      await _analyzeImage(File(image.path), hits.first);
    }
  }

  Future<XFile?> _pickImage() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.camera);
  }

  Future<void> _analyzeImage(File imageFile, ArCoreHitTestResult hit) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      final nameResponse = await model.generateContent([
        Content.multi([
          TextPart("Quel est cet objet ? Donne uniquement son nom ou sa désignation."),
          DataPart('image/jpeg', imageBytes),
        ])
      ]);

      final objectName = nameResponse.text?.trim() ?? "Objet non reconnu";

      String instructions = "Aucune instruction disponible.";
      if (objectName != "Objet non reconnu") {
        final instructionResponse = await model.generateContent([
          Content.text("Donne un mode d'emploi simple et clair pour utiliser un(e) $objectName.")
        ]);
        instructions = instructionResponse.text?.trim() ?? instructions;
      }

      objectInstructions[objectName] = instructions;

      _showInstructionDialog(objectName, instructions);
      _addMarkerToAR(objectName, hit);
    } catch (e) {
      print("Erreur lors de l'analyse : $e");
      _showInstructionDialog("Erreur", "Une erreur est survenue.");
    }
  }

  void _addMarkerToAR(String objectName, ArCoreHitTestResult hit) {
    final randomColor = Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );

    final material = ArCoreMaterial(color: randomColor);
    final shape = ArCoreSphere(materials: [material], radius: 0.05);

    final node = ArCoreNode(
      name: objectName,
      shape: shape,
      position: hit.pose.translation,
    );

    arCoreController.addArCoreNode(node);
  }

  void _handleNodeTap(String nodeName) {
    final instructions = objectInstructions[nodeName];

    if (instructions != null) {
      _showInstructionDialog(nodeName, instructions);
    } else {
      _showInstructionDialog("Inconnu", "Aucune donnée enregistrée pour cet objet.");
    }
  }

  void _showInstructionDialog(String objectName, String instructions) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Objet : $objectName"),
        content: SingleChildScrollView(
          child: Text(instructions),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AR + Gemini : Reconnaissance d'objet")),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
    );
  }
}
