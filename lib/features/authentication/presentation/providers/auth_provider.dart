import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thermal_touch/features/authentication/presentation/pages/login_page.dart';
import 'package:thermal_touch/features/authentication/presentation/pages/sign_up_page.dart';

import '../pages/sign_up_page.dart';

class AuthService {
  final suabase = Supabase.instance.client;

  //Sign up fonction
  Future<String?> signup(String email, String password, String name) async {
    try {

      //final user = response.user;
      final response = await Supabase.instance.client
          .from('User') // Replace with your table name
          .insert({
        'email': email,
        'name': name,
        'password': password, // Note: Don't store plain passwords in production!
        'created_at': DateTime.now().toIso8601String(),
        // Add other fields as needed
      })
          .select(); // This returns the inserted record

      debugPrint('Inserted user: ${response.toString()}');
      final user = response;

      return null;
    } on AuthException catch (e) {
      print(e.message);
      return e.message;
    } catch (e) {
      print(e);
      return "Error: $e";
    }
  }


// login function

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await suabase
          .from('User')
          .select()
          .eq('email', email.trim())
          .maybeSingle();

      if (response == null) return null;

      final isValid = password == response['password'];

      if (!isValid) return null;

      return response; // Renvoie tout l'utilisateur
    } catch (e) {
      return null;
    }
  }



  //Function to logout

  Future<void> logout(BuildContext context) async {
    try{
      await suabase.auth.signOut();
      if(!context.mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    }catch (e) {
      print("Logout error $e");
    }

  }


}
