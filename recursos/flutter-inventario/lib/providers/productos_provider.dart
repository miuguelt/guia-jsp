// =============================================================================
//  Provider: ProductosProvider (AsyncNotifier)
//  Gestiona el CRUD de productos: listar, crear, actualizar, eliminar.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import 'auth_provider.dart';

// ---------------------------------------------------------------------------
//  Notifier asincrono de productos
// ---------------------------------------------------------------------------

class ProductosNotifier extends AsyncNotifier<List<Producto>> {
  ProductoService get _service => ref.read(productoServiceProvider);

  @override
  Future<List<Producto>> build() async {
    // Carga inicial: primera pagina de productos
    final result = await _authenticatedCall(
      () => _service.getAll(page: 1, size: 50),
    );
    return result.items;
  }

  /// Refresca la lista desde la API (primeras 50 entradas).
  Future<void> fetchAll({String? categoria}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _authenticatedCall(
        () => _service.getAll(page: 1, size: 50, categoria: categoria),
      );
      return result.items;
    });
  }

  /// Crea un nuevo producto y actualiza la lista local.
  Future<void> create(Map<String, dynamic> data) async {
    await _authenticatedCall(() => _service.create(data));
    await fetchAll();
  }

  /// Actualiza un producto existente y actualiza la lista local.
  Future<void> update(int id, Map<String, dynamic> data) async {
    await _authenticatedCall(() => _service.update(id, data));
    await fetchAll();
  }

  /// Elimina un producto y actualiza la lista local.
  Future<void> delete(int id) async {
    await _authenticatedCall(() => _service.delete(id));
    await fetchAll();
  }

  // -----------------------------------------------------------------------
  //  Metodo auxiliar: manejo de errores 401
  // -----------------------------------------------------------------------
  // Si la API responde con 401 No Autorizado, el token JWT almacenado
  // ha expirado o es invalido. Se cierra la sesion en memoria y
  // el router redirige automaticamente a la pantalla de login.
  Future<T> _authenticatedCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        ref.read(authProvider.notifier).logout();
      }
      rethrow;
    }
  }
}

// ---------------------------------------------------------------------------
//  Providers
// ---------------------------------------------------------------------------

/// Provider del servicio de productos (Dio inyectado).
final productoServiceProvider = Provider<ProductoService>((ref) {
  return ProductoService(ref.read(dioProvider));
});

/// Provider del estado de productos (AsyncNotifier).
final productosProvider =
    AsyncNotifierProvider<ProductosNotifier, List<Producto>>(
  ProductosNotifier.new,
);
