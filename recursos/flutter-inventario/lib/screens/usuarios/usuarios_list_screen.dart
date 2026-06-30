// =============================================================================
//  Pantalla: UsuariosListScreen
//  Lista de usuarios del sistema. Solo accesible por Administradores.
//  Incluye pull-to-refresh y FAB para crear nuevo usuario.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/usuarios_provider.dart';

class UsuariosListScreen extends ConsumerWidget {
  const UsuariosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
      ),
      // FAB: Nuevo usuario
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/usuarios/nuevo'),
        tooltip: 'Nuevo usuario',
        child: const Icon(Icons.person_add),
      ),
      body: usuariosAsync.when(
        // Estado: cargando
        loading: () => const Center(child: CircularProgressIndicator()),

        // Estado: error
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $error',
                  style: TextStyle(color: Colors.red[700])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(usuariosProvider.notifier).fetchAll(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),

        // Estado: datos cargados
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay usuarios registrados',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(usuariosProvider.notifier).fetchAll(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        usuario.nombreCompleto
                            .split(' ')
                            .map((w) => w.isNotEmpty ? w[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      usuario.nombreCompleto,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@${usuario.username}'),
                        Row(
                          children: [
                            Icon(Icons.shield_outlined,
                                size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              usuario.rol?.nombre ?? 'Sin rol',
                              style: TextStyle(
                                color: usuario.rol?.nombre == 'Administrador'
                                    ? Colors.orange
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.circle,
                                size: 8,
                                color: usuario.estado
                                    ? Colors.green
                                    : Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              usuario.estado ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                color: usuario.estado
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          context.go('/usuarios/${usuario.id}/editar'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
