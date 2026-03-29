import 'package:tennis_string_tune/supabase_config.dart';
import 'package:tennis_string_tune/models/cliente.dart';

class ClienteService {
  final _db = SupabaseConfig.client;

  // Obtener todos los clientes ordenados por apellidos
  Future<List<Cliente>> getAll() async {
    final response = await _db.from('clientes')
        .select()
        .order('apellidos', ascending: true);

    return response.map((json) => Cliente.fromJson(json)).toList();
  }

  // Obtener un cliente por id
  Future<Cliente?> getById(String id) async {
    final response = await _db.from('clientes')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Cliente.fromJson(response);
  }

  // Crear un nuevo cliente
  Future<Cliente> create(Cliente cliente) async {
    final response = await _db.from('clientes')
        .insert(cliente.toJson())
        .select()
        .single();

    return Cliente.fromJson(response);
  }

  // Actualizar un cliente existente
  Future<Cliente> update(Cliente cliente) async {
    final response = await _db.from('clientes')
        .update(cliente.toJson())
        .eq('id', cliente.id)
        .select()
        .single();

    return Cliente.fromJson(response);
  }

  // Eliminar un cliente
  Future<void> delete(String id) async {
    await _db.from('clientes')
        .delete()
        .eq('id', id);
  }

  // Buscar clientes por nombre o apellidos
  Future<List<Cliente>> search(String query) async {
    final response = await _db.from('clientes')
        .select()
        .or('nombre.ilike.%$query%,apellidos.ilike.%$query%')
        .order('apellidos', ascending: true);

    return response.map((json) => Cliente.fromJson(json)).toList();
  }
}