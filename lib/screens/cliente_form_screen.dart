import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/models/cliente.dart';
import 'package:tennis_string_tune/services/cliente_service.dart';

class ClienteFormScreen extends StatefulWidget {
  final String? clienteId;
  const ClienteFormScreen({super.key, this.clienteId});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _service             = ClienteService();
  final _nombreController    = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController  = TextEditingController();
  final _emailController     = TextEditingController();
  final _notasController     = TextEditingController();

  bool _isLoading = false;
  Cliente? _clienteOriginal;

  bool get _esNuevo => widget.clienteId == null;

  @override
  void initState() {
    super.initState();
    if (!_esNuevo) _loadCliente();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _loadCliente() async {
    setState(() => _isLoading = true);
    try {
      final cliente = await _service.getById(widget.clienteId!);
      if (cliente == null) {
        if (mounted) context.go('/clientes');
        return;
      }
      _clienteOriginal          = cliente;
      _nombreController.text    = cliente.nombre;
      _apellidosController.text = cliente.apellidos;
      _telefonoController.text  = cliente.telefono;
      _emailController.text     = cliente.email ?? '';
      _notasController.text     = cliente.notas ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar cliente: $e')),
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
    if (_apellidosController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los apellidos son obligatorios')),
      );
      return;
    }
    if (_telefonoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El teléfono es obligatorio')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_esNuevo) {
        final nuevo = Cliente(
          id:        '',
          nombre:    _nombreController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          telefono:  _telefonoController.text.trim(),
          email:     _emailController.text.trim().isEmpty
                       ? null
                       : _emailController.text.trim(),
          notas:     _notasController.text.trim().isEmpty
                       ? null
                       : _notasController.text.trim(),
          createdAt: DateTime.now(),
        );
        await _service.create(nuevo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente creado correctamente')),
          );
          context.pop();
        }
      } else {
        final actualizado = _clienteOriginal!.copyWith(
          nombre:    _nombreController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          telefono:  _telefonoController.text.trim(),
          email:     _emailController.text.trim().isEmpty
                       ? null
                       : _emailController.text.trim(),
          notas:     _notasController.text.trim().isEmpty
                       ? null
                       : _notasController.text.trim(),
        );
        await _service.update(actualizado);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente actualizado correctamente')),
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
        title: Text(_esNuevo ? 'Nuevo cliente' : 'Editar cliente'),
        backgroundColor: const Color(0xFF3FA34D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/clientes'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nombre *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      hintText: 'Nombre del cliente',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Apellidos *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apellidosController,
                    decoration: const InputDecoration(
                      hintText: 'Apellidos del cliente',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Teléfono *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '6XX XXX XXX',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Email',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'correo@ejemplo.com (opcional)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Notas',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notasController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Observaciones sobre el cliente (opcional)',
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
                        _esNuevo ? 'Crear cliente' : 'Guardar cambios',
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