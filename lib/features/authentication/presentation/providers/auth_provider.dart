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
      final response = await suabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        // Insérer le nom dans la table "profiles"
        final insertResponse = await suabase
            .from('profiles')
            .insert({
          'id': user.id,    // utilise l'id de l'utilisateur Supabase
          'name': name,
          'email': email,
        }).select();

        if (response == null) {
          return "Erreur inconnue lors de l'insertion";
        }

        return null; // succès complet
      }
      return "Une erreur inconnue est survenue";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error: $e";
    }
  }


// login function

  Future<String?> login(String email, String password, String name) async {
    try{
      final response = await suabase.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user != null) {
        return null; //indicates sucess
      }
      return "An unknow error occured";
    } on AuthException catch (e) {
      return e.message;
    }catch (e) {
      return "Error:$e";
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
