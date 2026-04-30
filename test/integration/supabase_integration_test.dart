import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tennis_string_tune/models/cliente.dart';
import 'package:tennis_string_tune/services/cliente_service.dart';
import 'package:tennis_string_tune/services/cuerda_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// localStorage en memoria para evitar shared_preferences en tests
class InMemoryLocalStorage extends LocalStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async => _storage['access_token'];

  @override
  Future<bool> hasAccessToken() async =>
      _storage.containsKey('access_token');

  @override
  Future<void> persistSession(String persistSessionString) async =>
      _storage['access_token'] = persistSessionString;

  @override
  Future<void> removePersistedSession() async =>
      _storage.remove('access_token');
}

void main() {
  setUpAll(() async {
  // Mock de shared_preferences para entorno de test
  SharedPreferences.setMockInitialValues({});
  
  await Supabase.initialize(
      url:          'https://eopojzukwomkyekmnrpy.supabase.co',
      anonKey:      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvcG9qenVrd29ta3lla21ucnB5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MTAzMDgsImV4cCI6MjA4OTA4NjMwOH0.X1ldBDSzWJvmzm6DbANmLLnKZxoR8whxtcmrMsVsyxM',
      authOptions: FlutterAuthClientOptions(
        localStorage: InMemoryLocalStorage(),
      ),
    );
  });

  final idsALimpiar = <String>[];

  tearDownAll(() async {
    for (final id in idsALimpiar) {
      try {
        await Supabase.instance.client
            .from('clientes')
            .delete()
            .eq('id', id);
      } catch (_) {}
    }
  });

  group('IT01-IT02 — Autenticación', () {
    test('IT01 — Login con credenciales válidas activa sesión', () async {
      final response = await Supabase.instance.client.auth
          .signInWithPassword(
        email:    'sergiomoro7@icloud.com',
        password: 'Cherry_77',
      );
      expect(response.session, isNotNull);
      expect(response.user,    isNotNull);
    });

    test('IT02 — Login con credenciales inválidas da error controlado',
        () async {
      expect(
        () async => await Supabase.instance.client.auth
            .signInWithPassword(
          email:    'noexiste@test.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('IT03-IT05 — CRUD Clientes', () {
    late String clienteIdCreado;

    test('IT03 — Crear cliente persiste en base de datos', () async {
      final service = ClienteService();
      final nuevo = Cliente(
        id:        '',
        nombre:    'Test',
        apellidos: 'Integración',
        telefono:  '600000000',
        createdAt: DateTime.now(),
      );

      final creado = await service.create(nuevo);

      expect(creado.id,        isNotEmpty);
      expect(creado.nombre,    'Test');
      expect(creado.apellidos, 'Integración');

      clienteIdCreado = creado.id;
      idsALimpiar.add(creado.id);
    });

    test('IT04 — Editar cliente refleja cambios en base de datos', () async {
      final service  = ClienteService();
      final cliente  = await service.getById(clienteIdCreado);
      expect(cliente, isNotNull);

      final actualizado = cliente!.copyWith(nombre: 'TestEditado');
      final resultado   = await service.update(actualizado);

      expect(resultado.nombre, 'TestEditado');
    });

    test('IT05 — Eliminar cliente sin órdenes funciona correctamente',
        () async {
      final service = ClienteService();
      await service.delete(clienteIdCreado);
      idsALimpiar.remove(clienteIdCreado);

      final cliente = await service.getById(clienteIdCreado);
      expect(cliente, isNull);
    });
  });

  group('IT08 — Cuerdas', () {
    test('IT08 — getActivas devuelve solo cuerdas activas', () async {
      final service = CuerdaService();
      final activas = await service.getActivas();
      expect(activas.every((c) => c.activo), true);
    });
  });

  group('IT09 — Órdenes con join clientes', () {
    test('IT09 — Consultar órdenes incluye nombre del cliente', () async {
      final response = await Supabase.instance.client
          .from('ordenes_servicio')
          .select('*, clientes(nombre, apellidos)')
          .limit(1);

      if (response.isNotEmpty) {
        expect(response.first['clientes'],           isNotNull);
        expect(response.first['clientes']['nombre'], isNotEmpty);
      }
    });
  });
}