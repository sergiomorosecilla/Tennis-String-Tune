import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/supabase_config.dart';
import 'package:tennis_string_tune/services/orden_servicio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _ordenService = OrdenServicioService();

  int    _serviciosHoy = 0;
  int    _pendientes   = 0;
  int    _enProceso    = 0;
  double _ingresosMes  = 0;
  bool   _isLoading    = true;

  @override
  void initState() {
    super.initState();
    _loadKpis();
  }

  Future<void> _loadKpis() async {
    setState(() => _isLoading = true);
    try {
      final kpis = await _ordenService.getKpis();
      setState(() {
        _serviciosHoy = kpis['servicios_hoy'] as int;
        _pendientes   = kpis['pendientes']    as int;
        _enProceso    = kpis['en_proceso']    as int;
        _ingresosMes  = kpis['ingresos_mes']  as double;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar KPIs: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Dashboard Operativo'),
        backgroundColor: const Color(0xFF1F2A44),
        foregroundColor: Colors.white,
        actions: [
          // Avatar del operario
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF3FA34D),
              foregroundColor: Colors.white,
              radius: 16,
              child: Text(
                SupabaseConfig.client.auth.currentUser?.email
                        ?.substring(0, 2)
                        .toUpperCase() ??
                    'TS',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadKpis,
        color: const Color(0xFF3FA34D),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // KPIs
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _KpiCard(
                        label: 'Servicios hoy',
                        value: '$_serviciosHoy',
                        color: const Color(0xFF1F2A44),
                      ),
                      _KpiCard(
                        label: 'Pendientes',
                        value: '$_pendientes',
                        color: Colors.red.shade700,
                      ),
                      _KpiCard(
                        label: 'Ingresos mes',
                        value: '${_ingresosMes.toStringAsFixed(0)}€',
                        color: const Color(0xFF3FA34D),
                      ),
                      _KpiCard(
                        label: 'En proceso',
                        value: '$_enProceso',
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ),
            const SizedBox(height: 16),

            // Botón Nueva Orden
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/clientes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FA34D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Nueva Orden',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tarjetas de navegación
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _MenuCard(
                  icon: Icons.people,
                  label: 'Clientes',
                  route: '/clientes',
                ),
                _MenuCard(
                  icon: Icons.assignment,
                  label: 'Servicios',
                  route: '/ordenes',
                ),
                _MenuCard(
                  icon: Icons.bar_chart,
                  label: 'Dashboard BI',
                  route: '/dashboard',
                ),
                _MenuCard(
                  icon: Icons.cable,
                  label: 'Cuerdas',
                  route: '/cuerdas',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón logout
            TextButton.icon(
              onPressed: () async {
                await SupabaseConfig.client.auth.signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.grey),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   route;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF3FA34D)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
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