// =============================================================================
//  App: InventarioApp
//  Configuracion principal de la aplicacion: tema, enrutamiento y auth.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/productos/productos_list_screen.dart';
import 'screens/productos/producto_form_screen.dart';
import 'screens/productos/producto_detail_screen.dart';
import 'screens/usuarios/usuarios_list_screen.dart';
import 'screens/usuarios/usuario_form_screen.dart';

// =============================================================================
//  Provider del Router
// =============================================================================

/// Provider que expone la configuracion de [GoRouter].
///
/// Escucha los cambios en [authProvider] para re-evaluar las redirecciones
/// de autenticacion (si el usuario cierra sesion, redirige a /login).
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,

    // -----------------------------------------------------------------------
    //  Redirect: Proteccion de rutas
    // -----------------------------------------------------------------------
    // Si el usuario no esta autenticado, solo puede acceder a /login y /register.
    // Si esta autenticado, no puede acceder a /login ni /register.
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final location = state.matchedLocation;

      final isAuthRoute = location == '/login' || location == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/';

      return null;
    },

    // -----------------------------------------------------------------------
    //  Definicion de rutas
    // -----------------------------------------------------------------------
    routes: [
      // Autenticacion
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Inicio (Dashboard)
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // Productos
      GoRoute(
        path: '/productos',
        builder: (context, state) => const ProductosListScreen(),
        routes: [
          GoRoute(
            path: 'nuevo',
            builder: (context, state) => const ProductoFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ProductoDetailScreen(productoId: id);
            },
            routes: [
              GoRoute(
                path: 'editar',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return ProductoFormScreen(productoId: id);
                },
              ),
            ],
          ),
        ],
      ),

      // Usuarios (solo admin, protegido por backend)
      GoRoute(
        path: '/usuarios',
        builder: (context, state) => const UsuariosListScreen(),
        routes: [
          GoRoute(
            path: 'nuevo',
            builder: (context, state) => const UsuarioFormScreen(),
          ),
          GoRoute(
            path: ':id/editar',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return UsuarioFormScreen(usuarioId: id);
            },
          ),
        ],
      ),
    ],
  );
});

// =============================================================================
//  Widget raiz: InventarioApp
// =============================================================================

class InventarioApp extends ConsumerStatefulWidget {
  const InventarioApp({super.key});

  @override
  ConsumerState<InventarioApp> createState() => _InventarioAppState();
}

class _InventarioAppState extends ConsumerState<InventarioApp> {
  @override
  void initState() {
    super.initState();
    // Al iniciar la app, intentar restaurar la sesion desde
    // SharedPreferences (token JWT guardado).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Escuchar cambios en el estado de autenticacion para refrescar
    // el router y re-evaluar las redirecciones de forma reactiva.
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.isAuthenticated != next.isAuthenticated) {
        router.refresh();
      }
    });

    return MaterialApp.router(
      title: 'Inventario SENA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
