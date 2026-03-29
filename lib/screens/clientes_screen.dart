import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/models/cliente.dart';
import 'package:tennis_string_tune/services/cliente_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _service = ClienteService();
  final _searchController = TextEditingController();

  List<Cliente> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClientes() async {
    setState(() => _isLoading = true);
    try {
      final clientes = await _service.getAll();
      setState(() => _clientes = clientes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar clientes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _loadClientes();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final clientes = await _service.search(query);
      setState(() => _clientes = clientes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en búsqueda: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(Cliente cliente) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text(
          '¿Seguro que quieres eliminar a ${cliente.nombreCompleto}?',
        ),
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
      await _service.delete(cliente.id);
      _loadClientes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminado')),
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
        title: const Text('Clientes'),
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
          await context.push('/clientes/new');
          _loadClientes();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o apellidos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Listado
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _clientes.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay clientes registrados',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _clientes.length,
                        itemBuilder: (context, index) {
                          final cliente = _clientes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              onTap: () async {
                                await context.push('/clientes/${cliente.id}');
                                _loadClientes();
                              },
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF3FA34D),
                                foregroundColor: Colors.white,
                                child: Text(
                                  cliente.nombre[0].toUpperCase(),
                                ),
                              ),
                              title: Text(
                                cliente.nombreCompleto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(cliente.telefono),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _delete(cliente),
                              ),
                            ), 
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}