import 'package:tennis_string_tune/supabase_config.dart';
import 'package:tennis_string_tune/models/cuerda.dart';

class CuerdaService {
  final _db = SupabaseConfig.client;

  // Obtener todas las cuerdas ordenadas por marca
  Future<List<Cuerda>> getAll() async {
    final response = await _db
        .from('cuerdas')
        .select()
        .order('marca', ascending: true);

    return response.map((json) => Cuerda.fromJson(json)).toList();
  }

  // Obtener solo cuerdas activas (para selectores en órdenes)
  Future<List<Cuerda>> getActivas() async {
    final response = await _db
        .from('cuerdas')
        .select()
        .eq('activo', true)
        .order('marca', ascending: true);

    return response.map((json) => Cuerda.fromJson(json)).toList();
  }

  // Obtener una cuerda por id
  Future<Cuerda?> getById(String id) async {
    final response = await _db
        .from('cuerdas')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Cuerda.fromJson(response);
  }

  // Crear una nueva cuerda
  Future<Cuerda> create(Cuerda cuerda) async {
    final response = await _db
        .from('cuerdas')
        .insert(cuerda.toJson())
        .select()
        .single();

    return Cuerda.fromJson(response);
  }

  // Actualizar una cuerda existente
  Future<Cuerda> update(Cuerda cuerda) async {
    final response = await _db
        .from('cuerdas')
        .update(cuerda.toJson())
        .eq('id', cuerda.id)
        .select()
        .single();

    return Cuerda.fromJson(response);
  }

  // Desactivar una cuerda (borrado lógico)
  Future<void> desactivar(String id) async {
    await _db
        .from('cuerdas')
        .update({'activo': false})
        .eq('id', id);
  }

  // Activar una cuerda
  Future<void> activar(String id) async {
    await _db
        .from('cuerdas')
        .update({'activo': true})
        .eq('id', id);
  }
}