// =============================================================================
//  Pantalla: ProductoFormScreen
//  Formulario para crear o editar un producto.
//  Se adapta segun si recibe un [productoId] (editar) o no (crear).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/producto.dart';
import '../../providers/productos_provider.dart';

class ProductoFormScreen extends ConsumerStatefulWidget {
  /// ID del producto a editar (null si es creacion).
  final int? productoId;

  const ProductoFormScreen({super.key, this.productoId});

  @override
  ConsumerState<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends ConsumerState<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoriaController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingProducto = false;

  /// Indica si estamos en modo edicion.
  bool get _isEditing => widget.productoId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadProducto();
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  /// Carga los datos del producto existente para edicion.
  Future<void> _loadProducto() async {
    setState(() => _isLoadingProducto = true);
    try {
      final productos = await ref.read(productosProvider.future);
      final producto = productos.firstWhere((p) => p.id == widget.productoId);
      _codigoController.text = producto.codigo;
      _nombreController.text = producto.nombre;
      _descripcionController.text = producto.descripcion ?? '';
      _precioController.text = producto.precio.toStringAsFixed(2);
      _stockController.text = producto.stock.toString();
      _categoriaController.text = producto.categoria ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar producto: $e')),
        );
        context.go('/productos');
      }
    } finally {
      if (mounted) setState(() => _isLoadingProducto = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'codigo': _codigoController.text.trim(),
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        'precio': double.parse(_precioController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'categoria': _categoriaController.text.trim().isEmpty
            ? null
            : _categoriaController.text.trim(),
      };

      if (_isEditing) {
        await ref
            .read(productosProvider.notifier)
            .update(widget.productoId!, data);
      } else {
        await ref.read(productosProvider.notifier).create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Producto actualizado correctamente'
                  : 'Producto creado correctamente',
            ),
          ),
        );
        context.go('/productos');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: _isLoadingProducto
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Codigo
                    TextFormField(
                      controller: _codigoController,
                      decoration: const InputDecoration(
                        labelText: 'Codigo',
                        hintText: 'Ej: PROD-001',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (v.trim().length < 3) return 'Minimo 3 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del producto',
                        hintText: 'Ej: Laptop HP ProBook',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripcion
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripcion (opcional)',
                        hintText: 'Descripcion del producto...',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Precio y Stock (fila)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _precioController,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                              prefixText: '\$ ',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Requerido';
                              }
                              final precio = double.tryParse(v.trim());
                              if (precio == null || precio <= 0) {
                                return 'Precio invalido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock',
                              prefixIcon: Icon(Icons.inventory),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Requerido';
                              }
                              final stock = int.tryParse(v.trim());
                              if (stock == null || stock < 0) {
                                return 'Stock invalido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Categoria
                    TextFormField(
                      controller: _categoriaController,
                      decoration: const InputDecoration(
                        labelText: 'Categoria (opcional)',
                        hintText: 'Ej: Tecnologia, Oficina',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSubmit(),
                    ),
                    const SizedBox(height: 32),

                    // Boton de envio
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'Guardar Cambios'
                                  : 'Crear Producto',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
