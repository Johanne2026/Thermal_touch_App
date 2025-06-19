import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteObjectPage extends StatefulWidget {
  const DeleteObjectPage({Key? key}) : super(key: key);

  @override
  State<DeleteObjectPage> createState() => _DeleteObjectPageState();
}

class _DeleteObjectPageState extends State<DeleteObjectPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _objects = [];
  Map<String, dynamic>? _selectedObject;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchObjects();
  }

  /// Charge tous les objets disponibles
  Future<void> _fetchObjects() async {
    setState(() => _isLoading = true);

    try {
      final data = await supabase
          .from('ModeEmploi')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _objects = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement : $e')),
      );
    }
  }


  Future<void> _deleteObject() async {
    if (_selectedObject == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content:
        Text('Supprimer "${_selectedObject!['nom']}" définitivement ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: const Text('Supprimer'),
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await supabase
          .from('ModeEmploi')
          .delete()
          .eq('id', _selectedObject!['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Objet supprimé avec succès")),
      );

      _selectedObject = null;
      _fetchObjects();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur suppression : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer un objet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButton<Map<String, dynamic>>(
              hint: const Text('Choisir un objet à supprimer'),
              isExpanded: true,
              value: _selectedObject,
              items: _objects.map((obj) {
                return DropdownMenuItem(
                  value: obj,
                  child: Text(obj['nom'] ?? 'Sans nom'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedObject = val);
              },
            ),
            const SizedBox(height: 20),
            if (_selectedObject != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nom : ${_selectedObject!['nom']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Description : ${_selectedObject!['description'] ?? 'Pas de description'}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _deleteObject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                      'Supprimer cet objet',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
