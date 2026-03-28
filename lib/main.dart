import 'package:flutter/material.dart';
import 'package:tennis_string_tune/supabase_config.dart';
import 'package:tennis_string_tune/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tennis String & Tune',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3FA34D),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SupabaseConfig.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session != null) {
          // Usuario autenticado → home (de momento placeholder)
          return const Scaffold(
            body: Center(
              child: Text('¡Bienvenido al taller! 🎾'),
            ),
          );
        }

        // Sin sesión → login
        return const LoginScreen();
      },
    );
  }
}