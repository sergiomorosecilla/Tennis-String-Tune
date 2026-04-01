import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/models/cuerda.dart';
import 'package:tennis_string_tune/services/cuerda_service.dart';

class CuerdaFormScreen extends StatefulWidget {
  final String? cuerdaId;
  const CuerdaFormScreen({super.key, this.cuerdaId});

  @override
  State<CuerdaFormScreen> createState() => _CuerdaFormScreenState();
}

class _CuerdaFormScreenState extends State<CuerdaFormScreen> {
  final _service          = CuerdaService();
  final _nombreController = TextEditingController();
  final _marcaController  = TextEditingController();
  final _precioController = TextEditingController();

  bool _isLoading = false;
  bool _activo    = true;
  Cuerda? _cuerdaOriginal;

  bool get _esNueva => widget.cuerdaId == null;

  @override
  void initState() {
    super.initState();
    if (!_esNueva) _loadCuerda();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _loadCuerda() async {
    setState(() => _isLoading = true);
    try {
      final cuerda = await _service.getById(widget.cuerdaId!);
      if (cuerda == null) {
        if (mounted) context.pop();
        return;
      }
      _cuerdaOriginal         = cuerda;
      _nombreController.text  = cuerda.nombre;
      _marcaController.text   = cuerda.marca;
      _precioController.text  = cuerda.precioUnitario.toString();
      setState(() => _activo  = cuerda.activo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar cuerda: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }
    if (_marcaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La marca es obligatoria')),
      );
      return;
    }
    final precio = double.tryParse(_precioController.text.trim());
    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un precio válido')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_esNueva) {
        final nueva = Cuerda(
          id:             '',
          nombre:         _nombreController.text.trim(),
          marca:          _marcaController.text.trim(),
          precioUnitario: precio,
          activo:         true,
          createdAt:      DateTime.now(),
        );
        await _service.create(nueva);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuerda añadida correctamente')),
          );
          context.pop();
        }
      } else {
        final actualizada = _cuerdaOriginal!.copyWith(
          nombre:         _nombreController.text.trim(),
          marca:          _marcaController.text.trim(),
          precioUnitario: precio,
          activo:         _activo,
        );
        await _service.update(actualizada);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuerda actualizada correctamente')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esNueva ? 'Nueva cuerda' : 'Editar cuerda'),
        backgroundColor: const Color(0xFF3FA34D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Marca *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _marcaController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Luxilon, Babolat, Solinco...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Nombre *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Alu Power 125, RPM Blast...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Precio unitario (€) *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _precioController,
                    keyboardType: const TextInputType
                        .numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Ej: 18.90',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle activo solo en modo edición
                  if (!_esNueva) ...[
                    const Divider(),
                    SwitchListTile(
                      title: const Text(
                        'Cuerda activa en catálogo',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _activo
                            ? 'Disponible para nuevas órdenes'
                            : 'No aparecerá en nuevas órdenes',
                        style: TextStyle(
                          color: _activo
                              ? const Color(0xFF3FA34D)
                              : Colors.grey,
                        ),
                      ),
                      value: _activo,
                      activeColor: const Color(0xFF3FA34D),
                      onChanged: (value) => setState(() => _activo = value),
                    ),
                  ],
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3FA34D),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _esNueva ? 'Añadir cuerda' : 'Guardar cambios',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}