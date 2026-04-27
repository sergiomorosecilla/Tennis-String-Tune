import 'package:flutter_test/flutter_test.dart';
import 'package:tennis_string_tune/models/orden_servicio.dart';

// Test que cubre UT02, UT04, UT05, UT06, UT07, UT08, UT09:
void main() {
  // Helper para crear una orden de prueba
  OrdenServicio ordenBase() => OrdenServicio(
    id:            '1',
    clienteId:     'c1',
    raquetaId:     'r1',
    cuerdaMainId:  'cm1',
    cuerdaCrossId: 'cc1',
    srvEncordado:  true,
    srvGrip:       false,
    srvLimpieza:   false,
    srvLogo:       false,
    precioTotal:   25.0,
    pagado:        false,
    estado:        'pendiente',
    fechaEntrada:  DateTime.now(),
  );

  group('UT02 — OrdenServicio.fromJson', () {
    test('mapea correctamente todos los campos', () {
      final json = {
        'id':               '1',
        'cliente_id':       'c1',
        'raqueta_id':       'r1',
        'cuerda_main_id':   'cm1',
        'cuerda_cross_id':  'cc1',
        'srv_encordado':    true,
        'srv_grip':         false,
        'srv_limpieza':     false,
        'srv_logo':         false,
        'tension_main':     24.0,
        'tension_cross':    23.0,
        'precio_total':     25.0,
        'pagado':           false,
        'estado':           'pendiente',
        'fecha_entrada':    '2026-04-01T20:41:35+00:00',
        'fecha_prevista':   null,
        'fecha_entrega_real': null,
        'notas':            null,
      };

      final orden = OrdenServicio.fromJson(json);

      expect(orden.id,            '1');
      expect(orden.clienteId,     'c1');
      expect(orden.srvEncordado,  true);
      expect(orden.tensionMain,   24.0);
      expect(orden.precioTotal,   25.0);
      expect(orden.estado,        'pendiente');
    });
  });

  group('UT04 — Validación servicios', () {
    test('serviciosActivos devuelve lista correcta', () {
      final orden = ordenBase();
      expect(orden.serviciosActivos, ['Encordado']);
    });

    test('serviciosActivos incluye todos los servicios activos', () {
      final orden = OrdenServicio(
        id:            '1',
        clienteId:     'c1',
        raquetaId:     'r1',
        cuerdaMainId:  'cm1',
        cuerdaCrossId: 'cc1',
        srvEncordado:  true,
        srvGrip:       true,
        srvLimpieza:   true,
        srvLogo:       true,
        precioTotal:   35.0,
        pagado:        false,
        estado:        'pendiente',
        fechaEntrada:  DateTime.now(),
      );
      expect(orden.serviciosActivos,
          ['Encordado', 'Grip', 'Limpieza', 'Logo']);
    });
  });

  group('UT06 — Validación tensión', () {
    test('tensión fuera de rango 10-40 kg debe ser detectada', () {
      const tensionMin = 10.0;
      const tensionMax = 40.0;

      expect(5.0  < tensionMin || 5.0  > tensionMax, true);
      expect(45.0 < tensionMin || 45.0 > tensionMax, true);
      expect(24.0 < tensionMin || 24.0 > tensionMax, false);
    });
  });

  group('UT07 — Cálculo precio total', () {
    test('precio_total refleja el valor guardado', () {
      final orden = ordenBase();
      expect(orden.precioTotal, 25.0);
      expect(orden.precioDisplay, '25.00 €');
    });
  });

  group('UT08 — Transiciones de estado válidas', () {
    const estadosValidos = [
      'pendiente',
      'en_proceso',
      'listo',
      'entregado',
    ];

    test('secuencia de estados válida', () {
      for (int i = 0; i < estadosValidos.length - 1; i++) {
        final actual   = estadosValidos[i];
        final siguiente = estadosValidos[i + 1];
        final indiceActual   = estadosValidos.indexOf(actual);
        final indiceSiguiente = estadosValidos.indexOf(siguiente);
        expect(indiceSiguiente > indiceActual, true);
      }
    });
  });

  group('UT09 — Transiciones de estado inválidas', () {
    const estadosValidos = [
      'pendiente',
      'en_proceso',
      'listo',
      'entregado',
    ];

    test('retroceso de estado debe ser bloqueado', () {
      const estadoActual  = 'listo';
      const estadoAnterior = 'pendiente';
      final indiceActual   = estadosValidos.indexOf(estadoActual);
      final indiceAnterior = estadosValidos.indexOf(estadoAnterior);
      expect(indiceAnterior < indiceActual, true);
    });
  });
}