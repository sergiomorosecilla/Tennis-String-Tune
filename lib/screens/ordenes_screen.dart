import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/models/orden_servicio.dart';
import 'package:tennis_string_tune/services/orden_servicio_service.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({super.key});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  final _service = OrdenServicioService();

  List<OrdenServicio> _pendientes  = [];
  List<OrdenServicio> _enProceso   = [];
  List<OrdenServicio> _listas      = [];
  List<OrdenServicio> _entregadas  = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrdenes();
  }

  Future<void> _loadOrdenes() async {
    setState(() => _isLoading = true);
    try {
      final todas = await _service.getAll();
      setState(() {
        _pendientes = todas.where((o) => o.estado == 'pendiente').toList();
        _enProceso  = todas.where((o) => o.estado == 'en_proceso').toList();
        _listas     = todas.where((o) => o.estado == 'listo').toList();
        _entregadas = todas.where((o) => o.estado == 'entregado').toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar órdenes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cambiarEstado(OrdenServicio orden, String nuevoEstado) async {
    try {
      await _service.cambiarEstado(orden.id, nuevoEstado);
      _loadOrdenes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: $e')),
        );
      }
    }
  }

  Future<void> _delete(OrdenServicio orden) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar orden'),
        content: const Text('¿Seguro que quieres eliminar esta orden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.delete(orden.id);
      _loadOrdenes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden eliminada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de servicio'),
        backgroundColor: const Color(0xFF3FA34D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_pendientes.isNotEmpty) ...[
                  _GrupoHeader(
                    label: 'Pendiente',
                    count: _pendientes.length,
                    color: Colors.red.shade700,
                  ),
                  ..._pendientes.map((o) => _OrdenCard(
                    orden: o,
                    onEstado: _cambiarEstado,
                    onDelete: _delete,
                    onTap: () async {
                      await context.push('/ordenes/${o.id}');
                      _loadOrdenes();
                    },
                  )),
                  const SizedBox(height: 16),
                ],
                if (_enProceso.isNotEmpty) ...[
                  _GrupoHeader(
                    label: 'En proceso',
                    count: _enProceso.length,
                    color: Colors.orange.shade700,
                  ),
                  ..._enProceso.map((o) => _OrdenCard(
                    orden: o,
                    onEstado: _cambiarEstado,
                    onDelete: _delete,
                    onTap: () async {
                      await context.push('/ordenes/${o.id}');
                      _loadOrdenes();
                    },
                  )),
                  const SizedBox(height: 16),
                ],
                if (_listas.isNotEmpty) ...[
                  _GrupoHeader(
                    label: 'Listo para entregar',
                    count: _listas.length,
                    color: const Color(0xFF3FA34D),
                  ),
                  ..._listas.map((o) => _OrdenCard(
                    orden: o,
                    onEstado: _cambiarEstado,
                    onDelete: _delete,
                    onTap: () async {
                      await context.push('/ordenes/${o.id}');
                      _loadOrdenes();
                    },
                  )),
                  const SizedBox(height: 16),
                ],
                if (_entregadas.isNotEmpty) ...[
                  _GrupoHeader(
                    label: 'Entregado',
                    count: _entregadas.length,
                    color: Colors.grey,
                  ),
                  ..._entregadas.map((o) => _OrdenCard(
                    orden: o,
                    onEstado: _cambiarEstado,
                    onDelete: _delete,
                    onTap: () async {
                      await context.push('/ordenes/${o.id}');
                      _loadOrdenes();
                    },
                  )),
                ],
                if (_pendientes.isEmpty &&
                    _enProceso.isEmpty &&
                    _listas.isEmpty &&
                    _entregadas.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Text(
                        'No hay órdenes registradas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _GrupoHeader extends StatelessWidget {
  final String label;
  final int    count;
  final Color  color;

  const _GrupoHeader({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdenCard extends StatelessWidget {
  final OrdenServicio orden;
  final Future<void> Function(OrdenServicio, String) onEstado;
  final Future<void> Function(OrdenServicio) onDelete;
  final VoidCallback onTap;

  const _OrdenCard({
    required this.orden,
    required this.onEstado,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      orden.serviciosActivos.join(' · '),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1F2A44),
                      ),
                    ),
                  ),
                  Text(
                    orden.precioDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3FA34D),
                    ),
                  ),
                ],
              ),
              if (orden.clienteNombre != null) ...[
                const SizedBox(height: 2),
                Text(
                  orden.clienteNombre!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2A44),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 4),
              Text(
                'Entrada: ${orden.fechaEntrada.day}/${orden.fechaEntrada.month}/${orden.fechaEntrada.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              if (orden.notas != null) ...[
                const SizedBox(height: 4),
                Text(
                  orden.notas!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  // Cambio rápido de estado
                  _EstadoBtn(
                    label: 'Pendiente',
                    activo: orden.estado == 'pendiente',
                    color: Colors.red.shade700,
                    onTap: () => onEstado(orden, 'pendiente'),
                  ),
                  const SizedBox(width: 4),
                  _EstadoBtn(
                    label: 'En proceso',
                    activo: orden.estado == 'en_proceso',
                    color: Colors.orange.shade700,
                    onTap: () => onEstado(orden, 'en_proceso'),
                  ),
                  const SizedBox(width: 4),
                  _EstadoBtn(
                    label: 'Listo',
                    activo: orden.estado == 'listo',
                    color: const Color(0xFF3FA34D),
                    onTap: () => onEstado(orden, 'listo'),
                  ),
                  const SizedBox(width: 4),
                  _EstadoBtn(
                    label: 'Entregado',
                    activo: orden.estado == 'entregado',
                    color: Colors.grey,
                    onTap: () => onEstado(orden, 'entregado'),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red, size: 20),
                    onPressed: () => onDelete(orden),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoBtn extends StatelessWidget {
  final String label;
  final bool   activo;
  final Color  color;
  final VoidCallback onTap;

  const _EstadoBtn({
    required this.label,
    required this.activo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: activo ? color : Colors.transparent,
          border: Border.all(color: color, width: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: activo ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}