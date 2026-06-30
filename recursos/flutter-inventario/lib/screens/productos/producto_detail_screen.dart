// =============================================================================
//  Pantalla: ProductoDetailScreen
//  Vista detallada de un producto con opciones de editar y eliminar.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/productos_provider.dart';

class ProductoDetailScreen extends ConsumerWidget {
  final int productoId;

  const ProductoDetailScreen({super.key, required this.productoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Buscar el producto en la lista cargada
    final productosAsync = ref.watch(productosProvider);
    final producto = productosAsync.whenOrNull(
      data: (productos) {
        try {
          return productos.firstWhere((p) => p.id == productoId);
        } catch (_) {
          return null;
        }
      },
    );

    if (producto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Producto')),
        body: productosAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('Producto no encontrado',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/productos'),
                      child: const Text('Volver a productos'),
                    ),
                  ],
                ),
              ),
      );
    }

    // Determinar color del stock
    final stockColor = producto.stock <= 5
        ? Colors.red
        : producto.stock <= 20
            ? Colors.orange
            : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        actions: [
          // Boton: Editar
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => context.go('/productos/$productoId/editar'),
          ),
          // Boton: Eliminar
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            tooltip: 'Eliminar',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con codigo y estado
            Row(
              children: [
                Chip(
                  label: Text('COD: ${producto.codigo}'),
                  backgroundColor:
                      theme.colorScheme.primary.withOpacity(0.1),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: producto.estado ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    producto.estado ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: producto.estado ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Precio
            _DetailRow(
              icon: Icons.attach_money,
              label: 'Precio',
              value: '\$${producto.precio.toStringAsFixed(2)}',
              valueStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(height: 32),

            // Stock
            _DetailRow(
              icon: Icons.inventory,
              label: 'Stock disponible',
              value: '${producto.stock} unidades',
              valueStyle: TextStyle(color: stockColor, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 32),

            // Categoria
            _DetailRow(
              icon: Icons.category_outlined,
              label: 'Categoria',
              value: producto.categoria ?? 'Sin categoria',
            ),
            const Divider(height: 32),

            // Descripcion
            _DetailRow(
              icon: Icons.description_outlined,
              label: 'Descripcion',
              value: producto.descripcion ?? 'Sin descripcion',
            ),
            const Divider(height: 32),

            // Informacion adicional
            if (producto.fechaRegistro != null)
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Fecha de registro',
                value: _formatDate(producto.fechaRegistro!),
              ),
            if (producto.usuarioCreadorId != null) ...[
              const Divider(height: 32),
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Creado por usuario ID',
                value: '${producto.usuarioCreadorId}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          'Esta seguro de eliminar "${producto.nombre}"?\nEsta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(productosProvider.notifier).delete(productoId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado correctamente')),
        );
        context.go('/productos');
      }
    }
  }
}

// =============================================================================
//  Widget interno: Fila de detalle
// =============================================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ??
                    const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
