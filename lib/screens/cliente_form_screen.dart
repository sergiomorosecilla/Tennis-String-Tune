import 'package:flutter/material.dart';

class ClienteFormScreen extends StatelessWidget {
  final String? clienteId;
  const ClienteFormScreen({super.key, this.clienteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(clienteId == null ? 'Nuevo cliente' : 'Editar cliente')),
      body: const Center(child: Text('Formulario Cliente — próximamente')),
    );
  }
}