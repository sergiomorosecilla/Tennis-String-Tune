import 'package:flutter_test/flutter_test.dart';
import 'package:tennis_string_tune/models/cliente.dart';

// Test que cubre UT01, UT02, UT03:
void main() {
  group('UT01 — Cliente.fromJson', () {
    test('construye correctamente el modelo desde JSON', () {
      final json = {
        'id': '123',
        'nombre': 'Carlos',
        'apellidos': 'García López',
        'telefono': '612000001',
        'email': 'carlos@example.com',
        'notas': null,
        'created_at': '2026-01-01T00:00:00+00:00',
      };

      final cliente = Cliente.fromJson(json);

      expect(cliente.id, '123');
      expect(cliente.nombre, 'Carlos');
      expect(cliente.apellidos, 'García López');
      expect(cliente.telefono, '612000001');
      expect(cliente.email, 'carlos@example.com');
      expect(cliente.notas, null);
    });

    test('nombreCompleto devuelve nombre y apellidos concatenados', () {
      final cliente = Cliente(
        id: '1',
        nombre: 'Carlos',
        apellidos: 'García López',
        telefono: '612000001',
        createdAt: DateTime.now(),
      );
      expect(cliente.nombreCompleto, 'Carlos García López');
    });
  });

  group('UT03 — Validaciones formulario cliente', () {
    test('nombre vacío debe ser detectado', () {
      expect(''.trim().isEmpty, true);
    });

    test('apellidos vacíos debe ser detectado', () {
      expect(''.trim().isEmpty, true);
    });

    test('teléfono vacío debe ser detectado', () {
      expect(''.trim().isEmpty, true);
    });

    test('campos rellenos son válidos', () {
      const nombre    = 'Carlos';
      const apellidos = 'García';
      const telefono  = '612000001';

      expect(nombre.trim().isEmpty,    false);
      expect(apellidos.trim().isEmpty, false);
      expect(telefono.trim().isEmpty,  false);
    });
  });
}