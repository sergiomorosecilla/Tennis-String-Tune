import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_string_tune/supabase_config.dart';
import 'package:tennis_string_tune/screens/home_screen.dart';
import 'package:tennis_string_tune/screens/login_screen.dart';
import 'package:tennis_string_tune/screens/clientes_screen.dart';
import 'package:tennis_string_tune/screens/cliente_form_screen.dart';
import 'package:tennis_string_tune/screens/cliente_detail_screen.dart';
import 'package:tennis_string_tune/screens/raqueta_form_screen.dart';
import 'package:tennis_string_tune/screens/cuerdas_screen.dart';
import 'package:tennis_string_tune/screens/cuerda_form_screen.dart';
import 'package:tennis_string_tune/screens/ordenes_screen.dart';
import 'package:tennis_string_tune/screens/orden_form_screen.dart';

class SupabaseAuthNotifier extends ChangeNotifier {
  SupabaseAuthNotifier() {
    SupabaseConfig.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
}

final _authNotifier = SupabaseAuthNotifier();

final router = GoRouter(
  initialLocation: '/login',
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final session = SupabaseConfig.client.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/login';

    if (session == null && !isLoggingIn) return '/login';
    if (session != null && isLoggingIn) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/clientes',
      builder: (context, state) => const ClientesScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const ClienteFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => ClienteDetailScreen(
            clienteId: state.pathParameters['id']!,
          ),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => ClienteFormScreen(
                clienteId: state.pathParameters['id'],
              ),
            ),
            GoRoute(
              path: 'raquetas/new',
              builder: (context, state) => RaquetaFormScreen(
                clienteId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'raquetas/:raquetaId',
              builder: (context, state) => RaquetaFormScreen(
                clienteId: state.pathParameters['id']!,
                raquetaId: state.pathParameters['raquetaId'],
              ),
            ),
            GoRoute(
              path: 'ordenes/new',
              builder: (context, state) => OrdenFormScreen(
                clienteId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/cuerdas',
      builder: (context, state) => const CuerdasScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const CuerdaFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => CuerdaFormScreen(
            cuerdaId: state.pathParameters['id'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/ordenes',
      builder: (context, state) => const OrdenesScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => OrdenFormScreen(
            ordenId: state.pathParameters['id'],
          ),
        ),
      ],
    ),
  ],
);