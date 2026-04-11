import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/models/orden_servicio.dart';
import 'package:tennis_string_tune/models/cliente.dart';
import 'package:tennis_string_tune/models/raqueta.dart';
import 'package:tennis_string_tune/models/cuerda.dart';
import 'package:tennis_string_tune/services/orden_servicio_service.dart';
import 'package:tennis_string_tune/services/cliente_service.dart';
import 'package:tennis_string_tune/services/raqueta_service.dart';
import 'package:tennis_string_tune/services/cuerda_service.dart';

class OrdenFormScreen extends StatefulWidget {
  final String? ordenId;
  final String? clienteId;

  const OrdenFormScreen({
    super.key,
    this.ordenId,
    this.clienteId,
  });

  @override
  State<OrdenFormScreen> createState() => _OrdenFormScreenState();
}

class _OrdenFormScreenState extends State<OrdenFormScreen> {
  final _ordenService   = OrdenServicioService();
  final _clienteService = ClienteService();
  final _raquetaService = RaquetaService();
  final _cuerdaService  = CuerdaService();

  final _precioController       = TextEditingController();
  final _tensionMainController  = TextEditingController();
  final _tensionCrossController = TextEditingController();
  final _notasController        = TextEditingController();

  // Datos para selectores
  List<Cliente> _clientes = [];
  List<Raqueta> _raquetas = [];
  List<Cuerda>  _cuerdas  = [];

  // Valores seleccionados
  Cliente? _clienteSeleccionado;
  Raqueta? _raquetaSeleccionada;
  Cuerda?  _cuerdaMain;
  Cuerda?  _cuerdaCross;

  // Servicios
  bool _srvGrip     = false;
  bool _srvLimpieza = false;
  bool _srvLogo     = false;

  // Misma cuerda para main y cross
  bool _mismaCuerda = true;

  bool _isLoading     = true;
  bool _isSaving      = false;
  OrdenServicio? _ordenOriginal;

  bool get _esNueva => widget.ordenId == null;

  @override
  void initState() {
    super.initState();
    _loadDatosIniciales();
  }

  @override
  void dispose() {
    _precioController.dispose();
    _tensionMainController.dispose();
    _tensionCrossController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _loadDatosIniciales() async {
    setState(() => _isLoading = true);
    try {
      final clientes = await _clienteService.getAll();
      final cuerdas  = await _cuerdaService.getActivas();

      setState(() {
        _clientes = clientes;
        _cuerdas  = cuerdas;
      });

      // Si viene con clienteId preseleccionado
      if (widget.clienteId != null) {
        final cliente = clientes.firstWhere(
          (c) => c.id == widget.clienteId,
          orElse: () => clientes.first,
        );
        await _seleccionarCliente(cliente);
      }

      // Si es edición cargamos la orden
      if (!_esNueva) await _loadOrden();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarCliente(Cliente cliente) async {
    setState(() {
      _clienteSeleccionado = cliente;
      _raquetaSeleccionada = null;
      _raquetas = [];
    });
    try {
      final raquetas = await _raquetaService.getByCliente(cliente.id);
      setState(() {
        _raquetas = raquetas;
        if (raquetas.isNotEmpty) {
          _raquetaSeleccionada = raquetas.first;
          // Prerellenar tensiones habituales
          _tensionMainController.text  =
              raquetas.first.tensionHabitualMain?.toString()  ?? '';
          _tensionCrossController.text =
              raquetas.first.tensionHabitualCross?.toString() ?? '';
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar raquetas: $e')),
        );
      }
    }
  }

  Future<void> _loadOrden() async {
    try {
      final orden = await _ordenService.getById(widget.ordenId!);
      if (orden == null) {
        if (mounted) context.pop();
        return;
      }
      _ordenOriginal = orden;

      // Seleccionar cliente
      final cliente = _clientes.firstWhere((c) => c.id == orden.clienteId);
      await _seleccionarCliente(cliente);

      // Seleccionar raqueta
      final raqueta = _raquetas.firstWhere((r) => r.id == orden.raquetaId);
      setState(() => _raquetaSeleccionada = raqueta);

      // Seleccionar cuerdas
      final cuerdaMain  = _cuerdas.firstWhere((c) => c.id == orden.cuerdaMainId);
      final cuerdaCross = _cuerdas.firstWhere((c) => c.id == orden.cuerdaCrossId);
      final mismaCuerda = orden.cuerdaMainId == orden.cuerdaCrossId;

      setState(() {
        _cuerdaMain   = cuerdaMain;
        _cuerdaCross  = cuerdaCross;
        _mismaCuerda  = mismaCuerda;
        _srvGrip      = orden.srvGrip;
        _srvLimpieza  = orden.srvLimpieza;
        _srvLogo      = orden.srvLogo;
      });

      _tensionMainController.text  = orden.tensionMain?.toString()  ?? '';
      _tensionCrossController.text = orden.tensionCross?.toString() ?? '';
      _precioController.text       = orden.precioTotal.toString();
      _notasController.text        = orden.notas ?? '';

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar orden: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_clienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un cliente')),
      );
      return;
    }
    if (_raquetaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una raqueta')),
      );
      return;
    }
    if (_cuerdaMain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la cuerda main')),
      );
      return;
    }
    if (!_mismaCuerda && _cuerdaCross == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la cuerda cross')),
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

    setState(() => _isSaving = true);
    try {
      final cuerdaCrossId = _mismaCuerda
          ? _cuerdaMain!.id
          : _cuerdaCross!.id;

      if (_esNueva) {
        final nueva = OrdenServicio(
          id:             '',
          clienteId:      _clienteSeleccionado!.id,
          raquetaId:      _raquetaSeleccionada!.id,
          cuerdaMainId:   _cuerdaMain!.id,
          cuerdaCrossId:  cuerdaCrossId,
          srvEncordado:   true,
          srvGrip:        _srvGrip,
          srvLimpieza:    _srvLimpieza,
          srvLogo:        _srvLogo,
          tensionMain:    double.tryParse(_tensionMainController.text.trim()),
          tensionCross:   double.tryParse(_tensionCrossController.text.trim()),
          precioTotal:    precio,
          pagado:         false,
          estado:         'pendiente',
          fechaEntrada:   DateTime.now(),
          notas:          _notasController.text.trim().isEmpty
                            ? null
                            : _notasController.text.trim(),
        );
        await _ordenService.create(nueva);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Orden creada correctamente')),
          );
          context.pop();
        }
      } else {
        final actualizada = _ordenOriginal!.copyWith(
          cuerdaMainId:   _cuerdaMain!.id,
          cuerdaCrossId:  cuerdaCrossId,
          srvGrip:        _srvGrip,
          srvLimpieza:    _srvLimpieza,
          srvLogo:        _srvLogo,
          tensionMain:    double.tryParse(_tensionMainController.text.trim()),
          tensionCross:   double.tryParse(_tensionCrossController.text.trim()),
          precioTotal:    precio,
          notas:          _notasController.text.trim().isEmpty
                            ? null
                            : _notasController.text.trim(),
        );
        await _ordenService.update(actualizada);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Orden actualizada correctamente')),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esNueva ? 'Nueva orden' : 'Editar orden'),
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
                  // Cliente
                  const Text('Cliente *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Cliente>(
                    value: _clienteSeleccionado,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    hint: const Text('Selecciona un cliente'),
                    items: _clientes.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.nombreCompleto),
                    )).toList(),
                    onChanged: _esNueva
                        ? (c) { if (c != null) _seleccionarCliente(c); }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Raqueta
                  const Text('Raqueta *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Raqueta>(
                    value: _raquetaSeleccionada,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    hint: const Text('Selecciona una raqueta'),
                    items: _raquetas.map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.nombreCompleto),
                    )).toList(),
                    onChanged: _esNueva
                        ? (r) => setState(() => _raquetaSeleccionada = r)
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Servicios opcionales
                  const Text('Servicios adicionales',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Grip'),
                    value: _srvGrip,
                    activeColor: const Color(0xFF3FA34D),
                    onChanged: (v) => setState(() => _srvGrip = v ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Limpieza'),
                    value: _srvLimpieza,
                    activeColor: const Color(0xFF3FA34D),
                    onChanged: (v) => setState(() => _srvLimpieza = v ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Logo'),
                    value: _srvLogo,
                    activeColor: const Color(0xFF3FA34D),
                    onChanged: (v) => setState(() => _srvLogo = v ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // Cuerda Main
                  const Text('Cuerda Main *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Cuerda>(
                    value: _cuerdaMain,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    hint: const Text('Selecciona cuerda main'),
                    items: _cuerdas.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.nombreCompleto} — ${c.precioDisplay}'),
                    )).toList(),
                    onChanged: (c) => setState(() {
                      _cuerdaMain = c;
                      if (_mismaCuerda) _cuerdaCross = c;
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Checkbox misma cuerda
                  CheckboxListTile(
                    title: const Text('Misma cuerda para main y cross'),
                    value: _mismaCuerda,
                    activeColor: const Color(0xFF3FA34D),
                    onChanged: (v) => setState(() {
                      _mismaCuerda = v ?? true;
                      if (_mismaCuerda) _cuerdaCross = _cuerdaMain;
                    }),
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Cuerda Cross (solo si no es la misma)
                  if (!_mismaCuerda) ...[
                    const Text('Cuerda Cross *',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Cuerda>(
                      value: _cuerdaCross,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      hint: const Text('Selecciona cuerda cross'),
                      items: _cuerdas.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.nombreCompleto} — ${c.precioDisplay}'),
                      )).toList(),
                      onChanged: (c) => setState(() => _cuerdaCross = c),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 8),

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

                  // Precio
                  const Text('Precio total (€) *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _precioController,
                    keyboardType: const TextInputType
                        .numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Ej: 35.00',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notas
                  const Text('Notas',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notasController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Observaciones sobre la orden (opcional)',
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
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3FA34D),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : Text(
                              _esNueva ? 'Crear orden' : 'Guardar cambios',
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