import 'package:tennis_string_tune/supabase_config.dart';
import 'package:tennis_string_tune/models/raqueta.dart';

class RaquetaService {
  final _db = SupabaseConfig.client;

  // Obtener todas las raquetas de un cliente
  Future<List<Raqueta>> getByCliente(String clienteId) async {
    final response = await _db
        .from('raquetas')
        .select()
        .eq('cliente_id', clienteId)
        .order('created_at', ascending: true);

    return response.map((json) => Raqueta.fromJson(json)).toList();
  }

  // Obtener una raqueta por id
  Future<Raqueta?> getById(String id) async {
    final response = await _db
        .from('raquetas')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Raqueta.fromJson(response);
  }

  // Crear una nueva raqueta
  Future<Raqueta> create(Raqueta raqueta) async {
    final response = await _db
        .from('raquetas')
        .insert(raqueta.toJson())
        .select()
        .single();

    return Raqueta.fromJson(response);
  }

  // Actualizar una raqueta existente
  Future<Raqueta> update(Raqueta raqueta) async {
    final response = await _db
        .from('raquetas')
        .update(raqueta.toJson())
        .eq('id', raqueta.id)
        .select()
        .single();

    return Raqueta.fromJson(response);
  }

  // Eliminar una raqueta
  Future<void> delete(String id) async {
    await _db
        .from('raquetas')
        .delete()
        .eq('id', id);
  }
}