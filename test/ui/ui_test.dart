import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tennis_string_tune/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    
    await Supabase.initialize(
      url:          'https://eopojzukwomkyekmnrpy.supabase.co',
      anonKey:      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvcG9qenVrd29ta3lla21ucnB5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MTAzMDgsImV4cCI6MjA4OTA4NjMwOH0.X1ldBDSzWJvmzm6DbANmLLnKZxoR8whxtcmrMsVsyxM',
      );
  });

  group('UI01 — Flujo login → home', () {
    testWidgets('pantalla login se muestra correctamente', (tester) async {
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();

      expect(find.text('Professional Stringing Management System'),
          findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('campos email y contraseña están presentes', (tester) async {
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('UI01 — login correcto navega al home', (tester) async {
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'sergiomoro7@icloud.com',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'Cherry_77',
      );

      await tester.tap(find.text('Iniciar Sesión'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Dashboard Operativo'), findsOneWidget);
    });
  });

  group('UI02 — Clientes', () {
    testWidgets('UI02 — pantalla clientes muestra listado', (tester) async {
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Clientes'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('UI04 — Órdenes', () {
    testWidgets('UI04 — pantalla órdenes muestra listado agrupado',
        (tester) async {
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Servicios'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}