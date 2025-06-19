import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateObjectPage extends StatefulWidget {
  const UpdateObjectPage({Key? key}) : super(key: key);

  @override
  _UpdateObjectPageState createState() => _UpdateObjectPageState();
}

class _UpdateObjectPageState extends State<UpdateObjectPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _objects = [];
  Map<String, dynamic>? _selectedObject;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _modeEmploiController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchObjects();
  }

  /// Charge tous les objets pour permettre la sélection
  Future<void> _fetchObjects() async {
    final data = await supabase.from('ModeEmploi').select()
        .order('created_at', ascending: false);
    setState(() {
      _objects = List<Map<String, dynamic>>.from(data);
    });
  }

  /// Charge les données dans les champs du formulaire
  void _onSelectObject(Map<String, dynamic>? obj) {
    setState(() {
      _selectedObject = obj;
      if (obj != null) {
        _nomController.text = obj['nom'] ?? '';
        _descriptionController.text = obj['description'] ?? '';
        _modeEmploiController.text = obj['mode_emploi'] ?? '';
        _imageUrlController.text = obj['image_url'] ?? '';
      }
    });
  }

  Future<void> _updateObject() async {
    if (_selectedObject == null || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await supabase.from('ModeEmploi')
          .update({
        'nom': _nomController.text,
        'description': _descriptionController.text,
        'mode_emploi': _modeEmploiController.text,
        'image_url': _imageUrlController.text,
      })
          .eq('id', _selectedObject!['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objet mis à jour avec succès')),
      );
      _fetchObjects(); // rafraîchir la liste
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inattendue : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier un objet existant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<Map<String, dynamic>>(
              hint: const Text('Choisir un objet...'),
              isExpanded: true,
              value: _selectedObject,
              items: _objects.map((obj) {
                return DropdownMenuItem(
                  value: obj,
                  child: Text(obj['nom'] ?? 'Sans nom'),
                );
              }).toList(),
              onChanged: _onSelectObject,
            ),
            const SizedBox(height: 20),
            if (_selectedObject != null)
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration:
                        const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _modeEmploiController,
                        decoration:
                        const InputDecoration(labelText: 'Mode d’emploi'),
                        maxLines: 5,
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration:
                        const InputDecoration(labelText: 'URL de l’image'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _updateObject,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
