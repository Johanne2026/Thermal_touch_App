import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final supabase = Supabase.instance.client;

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
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      await _analyzeImage(File(image.path), hits.first);
    }
  }

  Future<void> _analyzeImage(File imageFile, ArCoreHitTestResult hit) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      // Demande à Gemini de reconnaître l’objet
      final nameResp = await model.generateContent([
        Content.multi([
          TextPart("Quel est cet objet ? Donne uniquement son nom ou sa désignation."),
          DataPart('image/jpeg', imageBytes),
        ])
      ]);

      final objectName = nameResp.text?.trim() ?? "Objet non reconnu";
      String instructions = "Aucune instruction disponible.";

      if (objectName != "Objet non reconnu") {
        try {
          // Recherche dans Supabase
          final result = await supabase
              .from('ModeEmploi')
              .select('mode_emploi')
              .eq('nom', objectName)
              .limit(1)
              .single();

          if (result != null && result['mode_emploi'] != null) {
            instructions = result['mode_emploi'] as String;
          }
        } catch (e) {
          // Si non trouvé, demande à Gemini de générer
          debugPrint("Non trouvé dans Supabase, génération via Gemini : $e");

          final genResp = await model.generateContent([
            Content.text("Donne un mode d'emploi simple et clair pour utiliser un(e) $objectName.")
          ]);
          instructions = genResp.text?.trim() ?? instructions;

          // Enregistre dans Supabase pour les prochaines fois
          await supabase.from('ModeEmploi').insert({
            'nom': objectName,
            'description': '',
            'mode_emploi': instructions,
            'image_url': '',
            'ajoute_par': supabase.auth.currentUser?.id ?? 'anonyme',
          });
        }
      }

      objectInstructions[objectName] = instructions;
      _addMarkerToAR(objectName, hit);
      _showInstructionDialog(objectName, instructions);

    } catch (e) {
      debugPrint("Erreur globale d'analyse : $e");
      _showInstructionDialog("Erreur", "Une erreur est survenue lors de l’analyse.");
    }
  }

  void _addMarkerToAR(String objectName, ArCoreHitTestResult hit) {
    final color = Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );

    final shape = ArCoreSphere(
      materials: [ArCoreMaterial(color: color)],
      radius: 0.05,
    );

    final node = ArCoreNode(
      name: objectName,
      shape: shape,
      position: hit.pose.translation,
    );

    arCoreController.addArCoreNode(node);
  }

  void _handleNodeTap(String nodeName) {
    final instr = objectInstructions[nodeName] ?? "Aucune donnée enregistrée pour cet objet.";
    _showInstructionDialog(nodeName, instr);
  }

  void _showInstructionDialog(String name, String instr) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Objet : $name"),
        content: SingleChildScrollView(child: Text(instr)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("AR + Gemini : Reconnaissance")),
    body: ArCoreView(
      onArCoreViewCreated: _onArCoreViewCreated,
      enableTapRecognizer: true,
    ),
  );
}
