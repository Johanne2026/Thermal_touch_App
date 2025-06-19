import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReadObjectPage extends StatefulWidget {
  const ReadObjectPage({Key? key}) : super(key: key);

  @override
  State<ReadObjectPage> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadObjectPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> _objects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchObjects();
  }

  Future<void> _fetchObjects() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('ModeEmploi')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _objects = response;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement : $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objets enregistrés'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _objects.isEmpty
          ? const Center(child: Text('Aucun objet trouvé.'))
          : ListView.builder(
        itemCount: _objects.length,
        itemBuilder: (context, index) {
          final item = _objects[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: ListTile(
              leading: item['image_url'] != null &&
                  item['image_url'].toString().isNotEmpty
                  ? Image.network(
                item['image_url'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
              )
                  : const Icon(Icons.image_not_supported),
              title: Text(item['nom'] ?? 'Sans nom'),
              subtitle: Text(item['description'] ?? ''),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(item['nom']),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['description'] != null)
                          Text('Description : ${item['description']}'),
                        const SizedBox(height: 8),
                        if (item['mode_emploi'] != null)
                          Text('Mode d’emploi :\n${item['mode_emploi']}'),
                        const SizedBox(height: 8),
                        Text('Ajouté par : ${item['ajoute_par'] ?? 'Inconnu'}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
