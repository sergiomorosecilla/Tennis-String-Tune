import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/supabase_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tennis String & Tune'),
        backgroundColor: const Color(0xFF3FA34D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseConfig.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(24),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _MenuCard(icon: Icons.people,       label: 'Clientes', route: '/clientes'),
          _MenuCard(icon: Icons.bar_chart,     label: 'Dashboard BI',  route: '/dashboard'),
          _MenuCard(icon: Icons.cable,         label: 'Cuerdas',  route: '/cuerdas'),
          _MenuCard(icon: Icons.assignment,    label: 'Ordenes ',  route: '/ordenes'),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF3FA34D)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2A44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}