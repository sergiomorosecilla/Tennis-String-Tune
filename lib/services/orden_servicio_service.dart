import 'package:tennis_string_tune/supabase_config.dart';
import 'package:tennis_string_tune/models/orden_servicio.dart';

class OrdenServicioService {
  final _db = SupabaseConfig.client;

  // Obtener todas las órdenes ordenadas por fecha de entrada
  Future<List<OrdenServicio>> getAll() async {
    final response = await _db
        .from('ordenes_servicio')
        .select('*, clientes(nombre, apellidos)')
        .order('fecha_entrada', ascending: false);

    return response.map((json) => OrdenServicio.fromJson(json)).toList();
  }

  // Obtener órdenes por estado
  Future<List<OrdenServicio>> getByEstado(String estado) async {
    final response = await _db
        .from('ordenes_servicio')
        .select()
        .eq('estado', estado)
        .order('fecha_entrada', ascending: false);

    return response.map((json) => OrdenServicio.fromJson(json)).toList();
  }

  // Obtener órdenes de un cliente
  Future<List<OrdenServicio>> getByCliente(String clienteId) async {
    final response = await _db
        .from('ordenes_servicio')
        .select()
        .eq('cliente_id', clienteId)
        .order('fecha_entrada', ascending: false);

    return response.map((json) => OrdenServicio.fromJson(json)).toList();
  }

  // Obtener una orden por id
  Future<OrdenServicio?> getById(String id) async {
    final response = await _db
        .from('ordenes_servicio')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return OrdenServicio.fromJson(response);
  }

  // Crear una nueva orden
  Future<OrdenServicio> create(OrdenServicio orden) async {
    final response = await _db
        .from('ordenes_servicio')
        .insert(orden.toJson())
        .select()
        .single();

    return OrdenServicio.fromJson(response);
  }

  // Actualizar una orden existente
  Future<OrdenServicio> update(OrdenServicio orden) async {
    final response = await _db
        .from('ordenes_servicio')
        .update(orden.toJson())
        .eq('id', orden.id)
        .select()
        .single();

    return OrdenServicio.fromJson(response);
  }

  // Cambiar solo el estado de una orden
  Future<void> cambiarEstado(String id, String nuevoEstado) async {
    await _db
        .from('ordenes_servicio')
        .update({'estado': nuevoEstado})
        .eq('id', id);
  }

  // Marcar como pagada
  Future<void> marcarPagada(String id) async {
    await _db
        .from('ordenes_servicio')
        .update({'pagado': true})
        .eq('id', id);
  }

  // Eliminar una orden
  Future<void> delete(String id) async {
    await _db
        .from('ordenes_servicio')
        .delete()
        .eq('id', id);
  }

  // Marcar como entregada (cambia estado y fecha de entrega real)
  Future<void> marcarEntregada(String id) async {
  await _db
      .from('ordenes_servicio')
      .update({
        'estado': 'entregado',
        'fecha_entrega_real': DateTime.now().toIso8601String(),
      })
      .eq('id', id);
  }

  // KPIs para el home dashboard
  Future<Map<String, dynamic>> getKpis() async {
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);

    final todas = await getAll();

    final serviciosHoy = todas.where((o) =>
        o.fechaEntrada.isAfter(inicioDia)).length;

    final pendientes = todas.where((o) =>
        o.estado == 'pendiente').length;

    final enProceso = todas.where((o) =>
        o.estado == 'en_proceso').length;

    final ingresosMes = todas
        .where((o) =>
            o.fechaEntrada.month == hoy.month &&
            o.fechaEntrada.year  == hoy.year  &&
            o.pagado)
        .fold(0.0, (sum, o) => sum + o.precioTotal);

    return {
      'servicios_hoy': serviciosHoy,
      'pendientes':    pendientes,
      'en_proceso':    enProceso,
      'ingresos_mes':  ingresosMes,
    };
  }
}