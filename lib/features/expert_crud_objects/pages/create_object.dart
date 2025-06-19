import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateObjectPage extends StatefulWidget {
  const CreateObjectPage({Key? key}) : super(key: key);

  @override
  State<CreateObjectPage> createState() => _CreateObjectPageState();
}

class _CreateObjectPageState extends State<CreateObjectPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _modeEmploiController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  /// Récupère les infos utilisateur stockées localement
  Future<Map<String, dynamic>?> _getLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    final String? email = prefs.getString('user_email');
    final bool? isAdmin = prefs.getBool('is_admin');

    if (userId == null || email == null || isAdmin == null) return null;

    return {
      'id': userId,
      'email': email,
      'isAdmin': isAdmin,
    };
  }

  Future<void> _ajouterObjet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userData = await _getLocalUserData();

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté localement.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final userId = userData['id'];
    final email = userData['email'];
    final isAdmin = userData['isAdmin'];

    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accès refusé : vous n’êtes pas administrateur.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await supabase.from('ModeEmploi').insert({
        'nom': _nomController.text,
        'description': _descriptionController.text,
        'mode_emploi': _modeEmploiController.text,
        'image_url': _imageUrlController.text,
        'ajoute_par': email,
      });

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Objet ajouté avec succès par $email')),
      );
      _formKey.currentState!.reset();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inattendue : $e')),
      );
    }
  }


  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _modeEmploiController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un objet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom de l’objet'),
                validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _modeEmploiController,
                decoration: const InputDecoration(labelText: 'Mode d’emploi'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de l’image (facultatif)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _ajouterObjet,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Ajouter l’objet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
