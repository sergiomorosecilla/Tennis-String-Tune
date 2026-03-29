import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/models/cliente.dart';
import 'package:tennis_string_tune/services/cliente_service.dart';

class ClienteDetailScreen extends StatefulWidget {
  final String clienteId;
  const ClienteDetailScreen({super.key, required this.clienteId});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  final _service = ClienteService();
  Cliente? _cliente;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCliente();
  }

  Future<void> _loadCliente() async {
    setState(() => _isLoading = true);
    try {
      final cliente = await _service.getById(widget.clienteId);
      if (cliente == null) {
        if (mounted) context.go('/clientes');
        return;
      }
      setState(() => _cliente = cliente);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cliente?.nombreCompleto ?? 'Detalle cliente'),
        backgroundColor: const Color(0xFF3FA34D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/clientes'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _cliente == null
                ? null
                : () async {
                    await context.push(
                      '/clientes/${widget.clienteId}/edit',
                    );
                    _loadCliente();
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cliente == null
              ? const Center(child: Text('Cliente no encontrado'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabecera con avatar
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFF3FA34D),
                            foregroundColor: Colors.white,
                            child: Text(
                              _cliente!.nombre[0].toUpperCase(),
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cliente!.nombreCompleto,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2A44),
                                ),
                              ),
                              Text(
                                'Cliente desde ${_cliente!.createdAt.year}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Datos de contacto
                      const Text(
                        'Datos de contacto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2A44),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.phone,
                        label: 'Teléfono',
                        value: _cliente!.telefono,
                      ),
                      if (_cliente!.email != null)
                        _InfoRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: _cliente!.email!,
                        ),
                      if (_cliente!.notas != null)
                        _InfoRow(
                          icon: Icons.notes,
                          label: 'Notas',
                          value: _cliente!.notas!,
                        ),
                      const SizedBox(height: 24),

                      // Sección raquetas (placeholder por ahora)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Raquetas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2A44),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Color(0xFF3FA34D),
                            ),
                            onPressed: () {
                              // navegación al form de raqueta — próximamente
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Las raquetas se añadirán en el siguiente paso',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// Widget auxiliar para filas de información
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3FA34D)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1F2A44),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}