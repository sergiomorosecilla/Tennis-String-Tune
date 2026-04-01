import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/models/cuerda.dart';
import 'package:tennis_string_tune/services/cuerda_service.dart';

class CuerdasScreen extends StatefulWidget {
  const CuerdasScreen({super.key});

  @override
  State<CuerdasScreen> createState() => _CuerdasScreenState();
}

class _CuerdasScreenState extends State<CuerdasScreen> {
  final _service = CuerdaService();

  List<Cuerda> _cuerdas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCuerdas();
  }

  Future<void> _loadCuerdas() async {
    setState(() => _isLoading = true);
    try {
      final cuerdas = await _service.getAll();
      setState(() => _cuerdas = cuerdas);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar cuerdas: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActivo(Cuerda cuerda) async {
    try {
      if (cuerda.activo) {
        await _service.desactivar(cuerda.id);
      } else {
        await _service.activar(cuerda.id);
      }
      _loadCuerdas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar estado: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuerdas'),
        backgroundColor: const Color(0xFF3FA34D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3FA34D),
        foregroundColor: Colors.white,
        onPressed: () async {
          await context.push('/cuerdas/new');
          _loadCuerdas();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cuerdas.isEmpty
              ? const Center(
                  child: Text(
                    'No hay cuerdas en el catálogo',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _cuerdas.length,
                  itemBuilder: (context, index) {
                    final cuerda = _cuerdas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cuerda.activo
                              ? const Color(0xFF3FA34D)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.cable),
                        ),
                        title: Text(
                          cuerda.nombreCompleto,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: cuerda.activo
                                ? const Color(0xFF1F2A44)
                                : Colors.grey,
                          ),
                        ),
                        subtitle: Text(cuerda.precioDisplay),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Toggle activo/inactivo
                            Switch(
                              value: cuerda.activo,
                              activeColor: const Color(0xFF3FA34D),
                              onChanged: (_) => _toggleActivo(cuerda),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF3FA34D),
                              ),
                              onPressed: () async {
                                await context.push('/cuerdas/${cuerda.id}');
                                _loadCuerdas();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}