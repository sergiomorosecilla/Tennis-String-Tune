import 'package:flutter/material.dart';
import 'package:tennis_string_tune/supabase_config.dart';
import 'package:tennis_string_tune/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tennis String & Tune',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3FA34D),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}