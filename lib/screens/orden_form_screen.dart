import 'package:flutter/material.dart';

class OrdenFormScreen extends StatelessWidget {
  final String? ordenId;
  const OrdenFormScreen({super.key, this.ordenId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ordenId == null ? 'Nueva orden' : 'Editar orden')),
      body: const Center(child: Text('Formulario Orden — próximamente')),
    );
  }
}