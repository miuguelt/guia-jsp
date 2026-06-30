// =============================================================================
//  Pantalla: ProductosListScreen
//  Lista de productos con busqueda local, pull-to-refresh y FAB para crear.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/producto.dart';
import '../../providers/productos_provider.dart';

class ProductosListScreen extends ConsumerStatefulWidget {
  const ProductosListScreen({super.key});

  @override
  ConsumerState<ProductosListScreen> createState() =>
      _ProductosListScreenState();
}

class _ProductosListScreenState extends ConsumerState<ProductosListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productosAsync = ref.watch(productosProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      // -------------------------------------------------------------------
      //  FAB: Crear nuevo producto
      // -------------------------------------------------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/productos/nuevo'),
        tooltip: 'Nuevo producto',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Barra de busqueda (filtro local por nombre o codigo)
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o codigo...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // Lista de productos
          Expanded(
            child: productosAsync.when(
              // Estado: cargando
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

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
                          ref.read(productosProvider.notifier).fetchAll(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),

              // Estado: datos cargados
              data: (productos) {
                // Filtrar por busqueda local
                final filtered = _searchQuery.isEmpty
                    ? productos
                    : productos.where((p) {
                        return p.nombre.toLowerCase().contains(_searchQuery) ||
                            p.codigo.toLowerCase().contains(_searchQuery);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay productos registrados'
                              : 'Sin resultados para "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(productosProvider.notifier).fetchAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final producto = filtered[index];
                      return _ProductoListTile(producto: producto);
                    },
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

// =============================================================================
//  Widget interno: Tarjeta de producto en la lista
// =============================================================================

class _ProductoListTile extends ConsumerWidget {
  final Producto producto;

  const _ProductoListTile({required this.producto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stockColor = producto.stock <= 5
        ? Colors.red
        : producto.stock <= 20
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Text(
            producto.codigo.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          producto.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Codigo: ${producto.codigo}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${producto.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.circle, size: 8, color: stockColor),
                const SizedBox(width: 4),
                Text(
                  'Stock: ${producto.stock}',
                  style: TextStyle(color: stockColor, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/productos/${producto.id}'),
      ),
    );
  }
}
