// =============================================================================
//  Pantalla: HomeScreen
//  Dashboard principal con estadisticas y acceso rapido a las secciones.
//  Incluye Drawer con navegacion completa.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/productos_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final productosAsync = ref.watch(productosProvider);
    final theme = Theme.of(context);

    final totalProductos = productosAsync.when(
      data: (productos) => productos.length,
      loading: () => null,
      error: (_, __) => null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Panel Principal')),
      // -----------------------------------------------------------------------
      //  Drawer: Menu de navegacion lateral
      // -----------------------------------------------------------------------
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Cabecera del drawer con datos del usuario
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authState.usuario?.nombreCompleto ?? 'Usuario',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authState.usuario?.rol?.nombre ?? '',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Opcion: Productos
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Productos'),
              subtitle: const Text('Gestionar inventario'),
              onTap: () {
                Navigator.pop(context);
                context.go('/productos');
              },
            ),

            // Opcion: Usuarios (solo admin)
            if (authState.isAdmin)
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Usuarios'),
                subtitle: const Text('Administrar usuarios'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/usuarios');
                },
              ),

            const Divider(),

            // Opcion: Cerrar sesion
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar Sesion',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjetas de estadisticas
            Text(
              'Resumen',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory_2,
                    label: 'Total Productos',
                    value: totalProductos?.toString() ?? '...',
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.person,
                    label: 'Mi Rol',
                    value: authState.usuario?.rol?.nombre ?? '...',
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Accesos rapidos
            Text(
              'Acceso Rapido',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _QuickActionCard(
              icon: Icons.add_circle_outline,
              title: 'Nuevo Producto',
              subtitle: 'Agregar un producto al inventario',
              onTap: () => context.go('/productos/nuevo'),
            ),
            const SizedBox(height: 8),
            _QuickActionCard(
              icon: Icons.list_alt,
              title: 'Ver Productos',
              subtitle: 'Listado completo del inventario',
              onTap: () => context.go('/productos'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  Widget interno: Tarjeta de estadistica
// =============================================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  Widget interno: Tarjeta de acceso rapido
// =============================================================================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
