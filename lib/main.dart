import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thermal_touch/features/authentication/presentation/pages/login_page.dart';
import 'package:thermal_touch/features/authentication/presentation/pages/sign_up_page.dart';
import 'package:thermal_touch/features/home/pages/pages/Home.dart';
import 'package:thermal_touch/features/home/pages/pages_admin/admin_home.dart';
import 'package:thermal_touch/features/home/pages/pages_shared/loader.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!
    );
  } catch (e) {
    throw Exception('Error loading .env file: $e'); // Print error if any
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thermal Touch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

      ),
      initialRoute: '/loader',
      routes: {
        '/loader': (context) => Loader(),
        '/home': (context) => HomePage(),
        '/signup': (context) => SignUpPage(), // Route vers la page d'inscription
        '/login': (context) => LoginPage(),
        '/admin_home': (context) => AdminHomePage(),
      },
    );
  }
}




