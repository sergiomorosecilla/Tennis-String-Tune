import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/models/raqueta.dart';
import 'package:tennis_string_tune/services/raqueta_service.dart';


class RaquetaFormScreen extends StatefulWidget {
  final String  clienteId;
  final String? raquetaId;

  const RaquetaFormScreen({
    super.key,
    required this.clienteId,
    this.raquetaId,
  });

  @override
  State<RaquetaFormScreen> createState() => _RaquetaFormScreenState();
}

class _RaquetaFormScreenState extends State<RaquetaFormScreen> {
  final _service               = RaquetaService();
  final _marcaController       = TextEditingController();
  final _modeloController      = TextEditingController();
  final _tensionMainController = TextEditingController();
  final _tensionCrossController= TextEditingController();
  final _notasController       = TextEditingController();

  bool _isLoading = false;
  Raqueta? _raquetaOriginal;

  bool get _esNueva => widget.raquetaId == null;

  @override
  void initState() {
    super.initState();
    if (!_esNueva) _loadRaqueta();
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _tensionMainController.dispose();
    _tensionCrossController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _loadRaqueta() async {
    setState(() => _isLoading = true);
    try {
      final raqueta = await _service.getById(widget.raquetaId!);
      if (raqueta == null) {
        if (mounted) context.pop();
        return;
      }
      _raquetaOriginal              = raqueta;
      _marcaController.text         = raqueta.marca;
      _modeloController.text        = raqueta.modelo;
      _tensionMainController.text   =
          raqueta.tensionHabitualMain?.toString()  ?? '';
      _tensionCrossController.text  =
          raqueta.tensionHabitualCross?.toString() ?? '';
      _notasController.text         = raqueta.notas ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar raqueta: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_marcaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La marca es obligatoria')),
      );
      return;
    }
    if (_modeloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El modelo es obligatorio')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tensionMain  = double.tryParse(_tensionMainController.text.trim());
      final tensionCross = double.tryParse(_tensionCrossController.text.trim());

      if (_esNueva) {
        final nueva = Raqueta(
          id:                   '',
          clienteId:            widget.clienteId,
          marca:                _marcaController.text.trim(),
          modelo:               _modeloController.text.trim(),
          tensionHabitualMain:  tensionMain,
          tensionHabitualCross: tensionCross,
          notas:                _notasController.text.trim().isEmpty
                                  ? null
                                  : _notasController.text.trim(),
          createdAt:            DateTime.now(),
        );
        await _service.create(nueva);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Raqueta añadida correctamente')),
          );
          context.pop();
        }
      } else {
        final actualizada = _raquetaOriginal!.copyWith(
          marca:                _marcaController.text.trim(),
          modelo:               _modeloController.text.trim(),
          tensionHabitualMain:  tensionMain,
          tensionHabitualCross: tensionCross,
          notas:                _notasController.text.trim().isEmpty
                                  ? null
                                  : _notasController.text.trim(),
        );
        await _service.update(actualizada);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Raqueta actualizada correctamente')),
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
        title: Text(_esNueva ? 'Nueva raqueta' : 'Editar raqueta'),
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
                      hintText: 'Ej: Wilson, Babolat, Head...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Modelo *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _modeloController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Pro Staff 97, Pure Drive...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tensiones en fila
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tensión Main (kg)',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _tensionMainController,
                              keyboardType: const TextInputType
                                  .numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: 'Ej: 24.0',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tensión Cross (kg)',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _tensionCrossController,
                              keyboardType: const TextInputType
                                  .numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: 'Ej: 23.0',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('Notas',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notasController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Observaciones sobre la raqueta (opcional)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
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
                        _esNueva ? 'Añadir raqueta' : 'Guardar cambios',
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