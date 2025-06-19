import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thermal_touch/features/authentication/presentation/pages/login_page.dart';
import 'package:thermal_touch/features/expert_crud_objects/pages/create_object.dart';
import 'package:thermal_touch/features/expert_crud_objects/pages/delete_object.dart';
import 'package:thermal_touch/features/expert_crud_objects/pages/read_object.dart';
import 'package:thermal_touch/features/expert_crud_objects/pages/update_object.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final supabase = Supabase.instance.client;

  Future<void> _logout() async {
    await supabase.auth.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3E9E9),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF3E9E9),
      body: Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bonjour mon admin',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),
              _buildButton(
                label: "Voir les modes d'emploi existants",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReadObjectPage()),
                ),
              ),
              const SizedBox(height: 40.0),
              _buildButton(
                label: "Créer un mode d'emploi",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateObjectPage()),
                ),
              ),
              const SizedBox(height: 40.0),
              _buildButton(
                label: "Mettre à jour un mode d'emploi",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateObjectPage()),
                ),
              ),
              const SizedBox(height: 40.0),
              _buildButton(
                label: "Supprimer un mode d'emploi",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteObjectPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 350,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEE826C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
